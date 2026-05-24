import 'dart:typed_data';
import 'dart:async';

import '../core/data/seed_data.dart';
import '../models/app_models.dart';
import 'app_repository.dart';

class MockAppRepository implements AppRepository {
  MockAppRepository() {
    _users = SeedData.users();
    _projects = SeedData.projects();
    _threads = SeedData.chats();
    _messages = SeedData.messages();
  }

  late List<AppUser> _users;
  late List<CreativeProject> _projects;
  late List<ChatThread> _threads;
  late Map<String, List<CreativeMessage>> _messages;
  AppUser? _currentUser;

  final StreamController<AppUser?> _authController = StreamController<AppUser?>.broadcast();
  final Map<String, StreamController<List<ChatThread>>> _chatControllers = {};
  final Map<String, StreamController<List<CreativeMessage>>> _messageControllers = {};

  void _emitAuth() {
    _authController.add(_currentUser);
  }

  void _refreshChats() {
    for (final entry in _chatControllers.entries) {
      final uid = entry.key;
      entry.value.add(_threads.where((thread) => thread.participants.contains(uid)).toList());
    }
  }

  void _refreshMessages(String chatId) {
    final controller = _messageControllers[chatId];
    if (controller != null) {
      controller.add(List.unmodifiable(_messages[chatId] ?? const <CreativeMessage>[]));
    }
  }

  @override
  Stream<AppUser?> authStateChanges() {
    Future.microtask(_emitAuth);
    return _authController.stream;
  }

  @override
  Future<AppUser?> signInWithEmail({required String email, required String password}) async {
    final user = _users.firstWhere((item) => item.email.toLowerCase() == email.toLowerCase(), orElse: () => _users.first);
    _currentUser = user.copyWith(profileViews: user.profileViews + 1);
    _users = _users.map((item) => item.uid == user.uid ? _currentUser! : item).toList();
    _emitAuth();
    return _currentUser;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    final user = _users.firstWhere((item) => item.email.contains('google'), orElse: () => _users.first);
    _currentUser = user;
    _emitAuth();
    return _currentUser;
  }

  @override
  Future<AppUser?> signUpWithEmail({required String name, required String email, required String password, required UserRole role}) async {
    final user = AppUser(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
      bio: 'Creative storyteller based in the West Midlands.',
      skills: const ['Storyboarding', 'Editing'],
      industry: 'Film & TV',
      location: 'Birmingham',
      experienceLevel: ExperienceLevel.beginner,
      verified: false,
      profileImage: '',
      portfolio: const [],
      socialLinks: const {'Website': 'https://scenelink.app'},
      savedProjectIds: const [],
      recentProjectIds: const [],
      profileViews: 0,
      projectEngagement: 0,
      collaborationRequests: 0,
      portfolioClicks: 0,
      accessibilitySettings: const AccessibilitySettings(textScaleFactor: 1, highContrast: false, screenReaderFriendly: true, reducedMotion: false),
    );
    _users = [..._users, user];
    _currentUser = user;
    _emitAuth();
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _emitAuth();
  }

  @override
  Future<List<AppUser>> getUsers() async => List.unmodifiable(_users);

  @override
  Future<List<CreativeProject>> getProjects() async => List.unmodifiable(_projects);

  @override
  Stream<List<ChatThread>> watchChats(String uid) {
    final controller = _chatControllers.putIfAbsent(uid, () => StreamController<List<ChatThread>>.broadcast());
    Future.microtask(() => controller.add(_threads.where((thread) => thread.participants.contains(uid)).toList()));
    return controller.stream;
  }

  @override
  Stream<List<CreativeMessage>> watchMessages(String chatId) {
    final controller = _messageControllers.putIfAbsent(chatId, () => StreamController<List<CreativeMessage>>.broadcast());
    Future.microtask(() => controller.add(List.unmodifiable(_messages[chatId] ?? const [])));
    return controller.stream;
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    _users = _users.map((entry) => entry.uid == user.uid ? user : entry).toList();
    if (_currentUser?.uid == user.uid) {
      _currentUser = user;
      _emitAuth();
    }
    return user;
  }

  @override
  Future<AppUser> updateAccessibility(AppUser user) async {
    return updateProfile(user);
  }

  @override
  Future<String> uploadProfileImage({required String userId, required Uint8List bytes, required String fileName}) async {
    final url = 'https://mock.scene.link/users/$userId/profile/$fileName';
    _users = _users.map((user) => user.uid == userId ? user.copyWith(profileImage: url) : user).toList();
    if (_currentUser?.uid == userId) {
      _currentUser = _currentUser!.copyWith(profileImage: url);
      _emitAuth();
    }
    return url;
  }

  @override
  Future<String> uploadPortfolioMedia({required String userId, required Uint8List bytes, required String fileName}) async {
    return 'https://mock.scene.link/users/$userId/portfolio/$fileName';
  }

  @override
  Future<CreativeProject> createProject(CreativeProject project) async {
    _projects = [project, ..._projects];
    return project;
  }

  @override
  Future<CreativeProject> updateProject(CreativeProject project) async {
    _projects = _projects.map((item) => item.projectId == project.projectId ? project : item).toList();
    return project;
  }

  @override
  Future<void> deleteProject(String projectId) async {
    _projects = _projects.where((item) => item.projectId != projectId).toList();
  }

  @override
  Future<void> saveProject({required String projectId, required String userId}) async {
    _projects = _projects.map((project) {
      if (project.projectId != projectId) {
        return project;
      }
      return project.copyWith(savedByIds: {...project.savedByIds, userId}.toList());
    }).toList();

    _users = _users.map((user) {
      if (user.uid != userId) {
        return user;
      }
      return user.copyWith(savedProjectIds: {...user.savedProjectIds, projectId}.toList());
    }).toList();
  }

  @override
  Future<void> applyToProject({required String projectId, required String userId, required bool blindMode}) async {
    _projects = _projects.map((project) {
      if (project.projectId != projectId) {
        return project;
      }
      final updatedApplicants = {...project.applicants, userId}.toList();
      final updatedBlindApplications = blindMode ? {...project.blindApplications, userId}.toList() : project.blindApplications;
      return project.copyWith(applicants: updatedApplicants, blindApplications: updatedBlindApplications);
    }).toList();
  }

  static String _chatIdFor(String userA, String userB) {
    final ids = [userA, userB]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  Future<String> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
    required String title,
  }) async {
    final chatId = _chatIdFor(currentUserId, otherUserId);
    final exists = _threads.any((thread) => thread.chatId == chatId);
    if (!exists) {
      _threads = [
        ChatThread(
          chatId: chatId,
          participants: [currentUserId, otherUserId],
          title: title,
          avatarUrl: '',
          lastMessage: '',
          updatedAt: DateTime.now(),
          unreadCount: 0,
        ),
        ..._threads,
      ];
      _messages[chatId] = const [];
      _refreshChats();
    }
    return chatId;
  }

  @override
  Future<void> sendMessage(CreativeMessage message) async {
    final threadMessages = [...(_messages[message.chatId] ?? const <CreativeMessage>[]), message];
    _messages[message.chatId] = threadMessages;
    _threads = _threads.map((thread) {
      if (thread.chatId != message.chatId) {
        return thread;
      }
      return thread.copyWith(
        lastMessage: message.message,
        updatedAt: message.timestamp,
        unreadCount: thread.unreadCount + 1,
      );
    }).toList();
    _refreshChats();
    _refreshMessages(message.chatId);
  }

  @override
  Future<DashboardAnalytics> getAnalytics(String userId) async {
    final user = _users.firstWhere((item) => item.uid == userId);
    return DashboardAnalytics(
      profileViews: user.profileViews,
      projectEngagement: user.projectEngagement,
      collaborationRequests: user.collaborationRequests,
      portfolioClicks: user.portfolioClicks,
    );
  }

  @override
  Future<List<CreativeProject>> getRecentProjects(String userId) async {
    return _projects.where((project) => project.creatorId == userId).take(3).toList();
  }

  @override
  Future<void> setVerified({required String userId, required bool verified}) async {
    _users = _users.map((user) => user.uid == userId ? user.copyWith(verified: verified) : user).toList();
    if (_currentUser?.uid == userId) {
      _currentUser = _users.firstWhere((user) => user.uid == userId);
      _emitAuth();
    }
  }
}