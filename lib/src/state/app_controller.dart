import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/data/seed_data.dart';
import '../core/routing/scene_link_router.dart';
import '../core/services/local_preferences_service.dart';
import '../models/app_models.dart';
import '../repositories/app_repository.dart';

class AppController extends ChangeNotifier {
  AppController({required this.repository, required this.preferences});

  final AppRepository repository;
  final LocalPreferencesService preferences;

  bool _isReady = false;
  bool get isReady => _isReady;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  AccessibilitySettings _accessibility = const AccessibilitySettings(
    textScaleFactor: 1.0,
    highContrast: false,
    screenReaderFriendly: true,
    reducedMotion: false,
  );
  AccessibilitySettings get accessibility => _accessibility;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  List<AppUser> _users = const [];
  List<AppUser> get users => _users;

  List<CreativeProject> _projects = const [];
  List<CreativeProject> get projects => _projects;

  List<CreativeProject> _recentProjects = const [];
  List<CreativeProject> get recentProjects => _recentProjects;

  DashboardAnalytics _analytics = const DashboardAnalytics(
    profileViews: 0,
    projectEngagement: 0,
    collaborationRequests: 0,
    portfolioClicks: 0,
  );
  DashboardAnalytics get analytics => _analytics;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String? _selectedLocation;
  String? get selectedLocation => _selectedLocation;

  UserRole? _selectedRoleFilter;
  UserRole? get selectedRoleFilter => _selectedRoleFilter;

  ExperienceLevel? _selectedExperienceFilter;
  ExperienceLevel? get selectedExperienceFilter => _selectedExperienceFilter;

  StreamSubscription<AppUser?>? _authSubscription;
  GoRouter? _router;
  final Map<String, List<CreativeMessage>> _localMessages = {};

  /// Cached router instance — must not be recreated on every [notifyListeners].
  GoRouter get router => _router ??= buildSceneLinkRouter(this);

  /// Users available for messaging (Firestore list + demo seed fallback).
  List<AppUser> get messageableUsers {
    final currentId = _currentUser?.uid;
    if (currentId == null) return const [];

    final fromCloud = _users.where((u) => u.uid != currentId).toList();
    if (fromCloud.isNotEmpty) return fromCloud;

    return SeedData.users().where((u) => u.uid != currentId).toList();
  }

  Future<void> bootstrap() async {
    _themeMode = await preferences.loadThemeMode();
    _accessibility = await preferences.loadAccessibilitySettings();
    _authSubscription = repository.authStateChanges().listen((user) async {
      if (user != null) {
        _currentUser = user;
        _accessibility = user.accessibilitySettings;
        await preferences.saveAccessibilitySettings(_accessibility);
        await _refreshDashboard();
        _projects = await repository.getProjects();
        _users = await repository.getUsers();
        _mergeCurrentUserIntoUsers();
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
    // Allow splash → login/signup immediately; fetch catalog in background.
    _isReady = true;
    notifyListeners();
    _loadCatalogData();
  }

  Future<void> _loadCatalogData() async {
    try {
      final results = await Future.wait([
        repository.getUsers(),
        repository.getProjects(),
      ]);
      _users = _mergeUsers(results[0] as List<AppUser>);
      _projects = _mergeProjects(results[1] as List<CreativeProject>);
      _mergeCurrentUserIntoUsers();
    } catch (_) {
      _users = _mergeUsers(const []);
      _projects = _mergeProjects(const []);
    }
    notifyListeners();
  }

  List<AppUser> _mergeUsers(List<AppUser> remote) {
    final map = <String, AppUser>{for (final u in SeedData.users()) u.uid: u};
    for (final u in remote) {
      map[u.uid] = u;
    }
    return map.values.toList();
  }

  List<CreativeProject> _mergeProjects(List<CreativeProject> remote) {
    final map = <String, CreativeProject>{for (final p in SeedData.projects()) p.projectId: p};
    for (final p in remote) {
      map[p.projectId] = p;
    }
    final merged = map.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  List<ChatThread> displayChatsFor(String uid) {
    return SeedData.chatsForUser(uid);
  }

  Stream<List<ChatThread>> watchDisplayChats(String uid) {
    return repository.watchChats(uid).map((cloud) {
      if (cloud.isNotEmpty) return cloud;
      return displayChatsFor(uid);
    }).handleError((_) => displayChatsFor(uid));
  }

  List<CreativeMessage> messagesForChatDisplay(String chatId) {
    final uid = _currentUser?.uid ?? '';
    final seed = SeedData.messagesForChat(chatId, uid);
    final local = _localMessages[chatId] ?? const <CreativeMessage>[];
    return [...seed, ...local]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  List<CreativeMessage> mergeCloudMessages(String chatId, List<CreativeMessage> cloud) {
    final base = messagesForChatDisplay(chatId);
    final keys = base.map((m) => '${m.senderId}_${m.timestamp.millisecondsSinceEpoch}_${m.message}').toSet();
    final extra = cloud.where((m) => !keys.contains('${m.senderId}_${m.timestamp.millisecondsSinceEpoch}_${m.message}')).toList();
    return [...base, ...extra]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> _refreshDashboard() async {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    try {
      _analytics = await repository.getAnalytics(user.uid);
      _recentProjects = await repository.getRecentProjects(user.uid);
    } catch (_) {
      _analytics = const DashboardAnalytics(
        profileViews: 0,
        projectEngagement: 0,
        collaborationRequests: 0,
        portfolioClicks: 0,
      );
      _recentProjects = const [];
    }
  }

  List<AppUser> get trendingUsers {
    final query = _searchQuery.trim().toLowerCase();
    return _users.where((user) {
      final matchesQuery = query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.skills.any((skill) => skill.toLowerCase().contains(query)) ||
          user.industry.toLowerCase().contains(query) ||
          user.location.toLowerCase().contains(query);
      final matchesRole = _selectedRoleFilter == null || user.role == _selectedRoleFilter;
      final matchesExperience = _selectedExperienceFilter == null || user.experienceLevel == _selectedExperienceFilter;
      return matchesQuery && matchesRole && matchesExperience;
    }).toList();
  }

  List<CreativeProject> get visibleProjects {
    final query = _searchQuery.trim().toLowerCase();
    return _projects.where((project) {
      final matchesQuery = query.isEmpty ||
          project.title.toLowerCase().contains(query) ||
          project.description.toLowerCase().contains(query) ||
          project.requiredRoles.any((role) => role.toLowerCase().contains(query)) ||
          project.category.toLowerCase().contains(query);
      final matchesCategory = _selectedCategory == null || project.category == _selectedCategory;
      final matchesLocation = _selectedLocation == null || project.location == _selectedLocation;
      return matchesQuery && matchesCategory && matchesLocation;
    }).toList();
  }

  List<String> get categories => _projects.map((project) => project.category).toSet().toList()..sort();
  List<String> get locations => _projects.map((project) => project.location).toSet().toList()..sort();

  Future<String?> signIn(String email, String password) async {
    try {
      await repository.signInWithEmail(email: email, password: password);
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      await repository.signUpWithEmail(name: name, email: email, password: password, role: role);
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      await repository.signInWithGoogle();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> sendResetEmail(String email) async {
    try {
      await repository.sendPasswordResetEmail(email);
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> signOut() => repository.signOut();

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await preferences.saveThemeMode(mode);
    notifyListeners();
  }

  Future<void> updateAccessibility(AccessibilitySettings settings) async {
    _accessibility = settings;
    await preferences.saveAccessibilitySettings(settings);
    notifyListeners();
    final user = _currentUser;
    if (user == null) {
      return;
    }
    try {
      final updatedUser = user.copyWith(accessibilitySettings: settings);
      _currentUser = await repository.updateAccessibility(updatedUser);
      notifyListeners();
    } catch (_) {
      // Local accessibility prefs still apply even if cloud sync fails.
    }
  }

  void _mergeCurrentUserIntoUsers() {
    final user = _currentUser;
    if (user == null) return;
    final others = _users.where((u) => u.uid != user.uid).toList();
    _users = [user, ...others];
  }

  Future<String?> updateProfile(AppUser updatedUser) async {
    _currentUser = updatedUser;
    _mergeCurrentUserIntoUsers();
    notifyListeners();
    try {
      _currentUser = await repository.updateProfile(updatedUser);
      _mergeCurrentUserIntoUsers();
      notifyListeners();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> uploadProfileImage({required Uint8List bytes, required String fileName}) async {
    final user = _currentUser;
    if (user == null) {
      return 'You must be signed in to upload a profile photo.';
    }

    final preview = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    _currentUser = user.copyWith(profileImage: preview);
    notifyListeners();

    try {
      final url = await repository
          .uploadProfileImage(userId: user.uid, bytes: bytes, fileName: fileName)
          .timeout(const Duration(seconds: 15));
      return await updateProfile(_currentUser!.copyWith(profileImage: url));
    } catch (error) {
      return 'Photo saved on this device. Cloud sync: ${error.toString()}';
    }
  }

  Future<String?> addPortfolioMedia({required Uint8List bytes, required String fileName}) async {
    final user = _currentUser;
    if (user == null) {
      return 'You must be signed in to upload portfolio media.';
    }

    try {
      final url = await repository.uploadPortfolioMedia(userId: user.uid, bytes: bytes, fileName: fileName);
      return await updateProfile(user.copyWith(portfolio: [...user.portfolio, url]));
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> toggleVerified(String userId, bool verified) async {
    await repository.setVerified(userId: userId, verified: verified);
    _users = _users.map((user) => user.uid == userId ? user.copyWith(verified: verified) : user).toList();
    if (_currentUser?.uid == userId) {
      _currentUser = _currentUser!.copyWith(verified: verified);
    }
    notifyListeners();
  }

  Future<String?> createProject(CreativeProject project) async {
    final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = project.copyWith(projectId: localId);
    _projects = [optimistic, ..._projects.where((p) => p.projectId != project.projectId)];
    notifyListeners();

    try {
      final created = await repository
          .createProject(project)
          .timeout(const Duration(seconds: 12));
      _projects = [
        created,
        ..._projects.where((p) => p.projectId != localId && p.projectId != project.projectId),
      ];
      notifyListeners();
      return null;
    } on TimeoutException {
      return null;
    } catch (error) {
      return 'Saved locally. Cloud sync failed: $error';
    }
  }

  Future<String?> updateProject(CreativeProject project) async {
    try {
      final updated = await repository.updateProject(project);
      _projects = _projects.map((item) => item.projectId == updated.projectId ? updated : item).toList();
      notifyListeners();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> startChatWithUser({required String otherUserId, required String title}) async {
    final user = _currentUser;
    if (user == null) {
      return null;
    }
    try {
      return await repository
          .getOrCreateChat(
            currentUserId: user.uid,
            otherUserId: otherUserId,
            title: title,
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      return SeedData.chatIdFor(user.uid, otherUserId);
    }
  }

  Future<void> deleteProject(String projectId) async {
    await repository.deleteProject(projectId);
    _projects = _projects.where((project) => project.projectId != projectId).toList();
    notifyListeners();
  }

  Future<void> saveProject(String projectId) async {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    await repository.saveProject(projectId: projectId, userId: user.uid);
    _currentUser = user.copyWith(savedProjectIds: {...user.savedProjectIds, projectId}.toList());
    notifyListeners();
  }

  Future<void> applyToProject(String projectId, {required bool blindMode}) async {
    final user = _currentUser;
    if (user == null) {
      return;
    }
    await repository.applyToProject(projectId: projectId, userId: user.uid, blindMode: blindMode);
    _projects = _projects.map((project) {
      if (project.projectId != projectId) {
        return project;
      }
      final applicants = {...project.applicants, user.uid}.toList();
      final blindApplications = blindMode ? {...project.blindApplications, user.uid}.toList() : project.blindApplications;
      return project.copyWith(applicants: applicants, blindApplications: blindApplications);
    }).toList();
    notifyListeners();
  }

  Future<String?> sendMessage(CreativeMessage message) async {
    final local = [...(_localMessages[message.chatId] ?? const <CreativeMessage>[]), message];
    _localMessages[message.chatId] = local;
    notifyListeners();

    try {
      await repository.sendMessage(message).timeout(const Duration(seconds: 10));
      return null;
    } catch (error) {
      return 'Message shown locally. Sync pending: $error';
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setCategoryFilter(String? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  void setLocationFilter(String? value) {
    _selectedLocation = value;
    notifyListeners();
  }

  void setRoleFilter(UserRole? value) {
    _selectedRoleFilter = value;
    notifyListeners();
  }

  void setExperienceFilter(ExperienceLevel? value) {
    _selectedExperienceFilter = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}