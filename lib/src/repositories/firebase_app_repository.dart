import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_models.dart';
import 'app_repository.dart';

class FirebaseAppRepository implements AppRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  AppUser _defaultUserFromAuth(User user) {
    return AppUser(
      uid: user.uid,
      name: user.displayName ?? 'SceneLink Creator',
      email: user.email ?? '',
      role: UserRole.freelancer,
      bio: 'Creative professional on SceneLink.',
      skills: const [],
      industry: 'Film & TV',
      location: 'West Midlands',
      experienceLevel: ExperienceLevel.intermediate,
      verified: false,
      profileImage: user.photoURL ?? '',
      portfolio: const [],
      socialLinks: const {},
      savedProjectIds: const [],
      recentProjectIds: const [],
      profileViews: 0,
      projectEngagement: 0,
      collaborationRequests: 0,
      portfolioClicks: 0,
      accessibilitySettings: const AccessibilitySettings(
        textScaleFactor: 1,
        highContrast: false,
        screenReaderFriendly: true,
        reducedMotion: false,
      ),
    );
  }

  Future<AppUser?> _loadUserProfile(User? user) async {
    if (user == null) {
      return null;
    }
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data['uid'] = doc.id;
        return AppUser.fromJson(data);
      }
    } catch (_) {
      // Fall back to auth-derived profile when Firestore is unavailable.
    }
    return _defaultUserFromAuth(user);
  }

  Map<String, dynamic> _projectPayload(CreativeProject project) {
    final data = Map<String, dynamic>.from(project.toJson());
    data.remove('projectId');
    data['createdAt'] = Timestamp.fromDate(project.createdAt);
    data['deadline'] = Timestamp.fromDate(project.deadline);
    return data;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static String _chatIdFor(String userA, String userB) {
    final ids = [userA, userB]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap(_loadUserProfile);
  }

  @override
  Future<AppUser?> signInWithEmail({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return _loadUserProfile(_auth.currentUser);
  }

  @override
  Future<AppUser?> signUpWithEmail({required String name, required String email, required String password, required UserRole role}) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await credential.user?.updateDisplayName(name);
    final user = AppUser(
      uid: credential.user!.uid,
      name: name,
      email: email,
      role: role,
      bio: 'Creative storyteller based in the West Midlands.',
      skills: const ['Collaboration', 'Storytelling'],
      industry: 'Film & TV',
      location: 'Birmingham',
      experienceLevel: ExperienceLevel.beginner,
      verified: false,
      profileImage: credential.user?.photoURL ?? '',
      portfolio: const [],
      socialLinks: const {},
      savedProjectIds: const [],
      recentProjectIds: const [],
      profileViews: 0,
      projectEngagement: 0,
      collaborationRequests: 0,
      portfolioClicks: 0,
      accessibilitySettings: const AccessibilitySettings(
        textScaleFactor: 1,
        highContrast: false,
        screenReaderFriendly: true,
        reducedMotion: false,
      ),
    );
    await _firestore.collection('users').doc(user.uid).set(user.toJson(), SetOptions(merge: true));
    return user;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    if (kIsWeb) {
      // On web, use Firebase Auth's signInWithPopup — no google_sign_in needed
      final provider = GoogleAuthProvider();
      final result = await _auth.signInWithPopup(provider);
      final firebaseUser = result.user;
      if (firebaseUser == null) {
        return null;
      }
      final existing = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!existing.exists) {
        final user = _defaultUserFromAuth(firebaseUser).copyWith(
          name: firebaseUser.displayName ?? 'SceneLink Creator',
          profileImage: firebaseUser.photoURL ?? '',
        );
        await _firestore.collection('users').doc(firebaseUser.uid).set(user.toJson(), SetOptions(merge: true));
      }
      return _loadUserProfile(firebaseUser);
    }

    // Mobile (Android / iOS) flow via google_sign_in package
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return null;
    }
    final auth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    final firebaseUser = result.user;
    if (firebaseUser == null) {
      return null;
    }
    final existing = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!existing.exists) {
      final user = _defaultUserFromAuth(firebaseUser).copyWith(
        name: firebaseUser.displayName ?? googleUser.displayName ?? 'SceneLink Creator',
        profileImage: firebaseUser.photoURL ?? '',
      );
      await _firestore.collection('users').doc(firebaseUser.uid).set(user.toJson(), SetOptions(merge: true));
    }
    return _loadUserProfile(firebaseUser);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) => _auth.sendPasswordResetEmail(email: email);

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<List<AppUser>> getUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return AppUser.fromJson(data);
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<CreativeProject>> getProjects() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await _firestore.collection('projects').orderBy('createdAt', descending: true).get();
      } catch (_) {
        snapshot = await _firestore.collection('projects').get();
      }
      final projects = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['projectId'] = doc.id;
        data['createdAt'] = _parseDate(data['createdAt']).toIso8601String();
        data['deadline'] = _parseDate(data['deadline']).toIso8601String();
        return CreativeProject.fromJson(data);
      }).toList();
      projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return projects;
    } catch (_) {
      return const [];
    }
  }

  @override
  Stream<List<ChatThread>> watchChats(String uid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
          final chats = snapshot.docs.map((doc) {
            final data = doc.data();
            return ChatThread(
              chatId: doc.id,
              participants: List<String>.from(data['participants'] as List? ?? const []),
              title: data['title'] as String? ?? 'Creative Chat',
              avatarUrl: data['avatarUrl'] as String? ?? '',
              lastMessage: data['lastMessage'] as String? ?? '',
              updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              unreadCount: data['unreadCount'] as int? ?? 0,
            );
          }).toList();
          chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return chats;
        });
  }

  @override
  Stream<List<CreativeMessage>> watchMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return CreativeMessage(
                senderId: data['senderId'] as String? ?? '',
                receiverId: data['receiverId'] as String? ?? '',
                message: data['message'] as String? ?? '',
                timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                read: data['read'] as bool? ?? false,
                chatId: chatId,
                imageUrl: data['imageUrl'] as String?,
              );
            }).toList());
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson(), SetOptions(merge: true));
    return user;
  }

  @override
  Future<AppUser> updateAccessibility(AppUser user) => updateProfile(user);

  String _contentTypeForFile(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    return 'application/octet-stream';
  }

  String _dataUrlForBytes(Uint8List bytes, String fileName) {
    final mime = _contentTypeForFile(fileName);
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  @override
  Future<String> uploadProfileImage({required String userId, required Uint8List bytes, required String fileName}) async {
    try {
      final storageRef = _storage.ref().child('users/$userId/profile/${DateTime.now().millisecondsSinceEpoch}_$fileName');
      await storageRef
          .putData(bytes, SettableMetadata(contentType: _contentTypeForFile(fileName)))
          .timeout(const Duration(seconds: 12));
      final downloadUrl = await storageRef.getDownloadURL().timeout(const Duration(seconds: 8));
      await _firestore.collection('users').doc(userId).set({
        'profileImage': downloadUrl,
      }, SetOptions(merge: true));
      return downloadUrl;
    } catch (_) {
      // Fallback when Storage rules block upload — store inline image in Firestore.
      final dataUrl = _dataUrlForBytes(bytes, fileName);
      await _firestore.collection('users').doc(userId).set({
        'profileImage': dataUrl,
      }, SetOptions(merge: true));
      return dataUrl;
    }
  }

  @override
  Future<String> uploadPortfolioMedia({required String userId, required Uint8List bytes, required String fileName}) async {
    try {
      final storageRef = _storage.ref().child('users/$userId/portfolio/${DateTime.now().millisecondsSinceEpoch}_$fileName');
      await storageRef.putData(bytes, SettableMetadata(contentType: _contentTypeForFile(fileName)));
      return storageRef.getDownloadURL();
    } catch (_) {
      return _dataUrlForBytes(bytes, fileName);
    }
  }

  @override
  Future<CreativeProject> createProject(CreativeProject project) async {
    final docRef = project.projectId.startsWith('p_') || project.projectId.startsWith('local_')
        ? _firestore.collection('projects').doc()
        : _firestore.collection('projects').doc(project.projectId);
    await docRef
        .set(_projectPayload(project))
        .timeout(const Duration(seconds: 12), onTimeout: () => throw TimeoutException('Project save timed out'));
    return project.copyWith(projectId: docRef.id);
  }

  @override
  Future<CreativeProject> updateProject(CreativeProject project) async {
    await _firestore.collection('projects').doc(project.projectId).set(_projectPayload(project), SetOptions(merge: true));
    return project;
  }

  @override
  Future<void> deleteProject(String projectId) => _firestore.collection('projects').doc(projectId).delete();

  @override
  Future<void> saveProject({required String projectId, required String userId}) async {
    await _firestore.collection('users').doc(userId).update({
      'savedProjectIds': FieldValue.arrayUnion([projectId]),
    });
  }

  @override
  Future<void> applyToProject({required String projectId, required String userId, required bool blindMode}) async {
    await _firestore.collection('projects').doc(projectId).update({
      'applicants': FieldValue.arrayUnion([userId]),
      if (blindMode) 'blindApplications': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<String> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
    required String title,
  }) async {
    final chatId = _chatIdFor(currentUserId, otherUserId);
    final doc = _firestore.collection('chats').doc(chatId);
    final existing = await doc.get();
    if (!existing.exists) {
      await doc.set({
        'participants': [currentUserId, otherUserId],
        'title': title,
        'avatarUrl': '',
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCount': 0,
      });
    }
    return chatId;
  }

  @override
  Future<void> sendMessage(CreativeMessage message) async {
    final participants = <String>{message.senderId, message.receiverId}.toList();
    await _firestore.collection('chats').doc(message.chatId).collection('messages').add({
      'senderId': message.senderId,
      'receiverId': message.receiverId,
      'message': message.message,
      'timestamp': FieldValue.serverTimestamp(),
      'read': message.read,
      'imageUrl': message.imageUrl,
    });
    await _firestore.collection('chats').doc(message.chatId).set({
      'participants': participants,
      'lastMessage': message.message,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<DashboardAnalytics> getAnalytics(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).get();
    final data = snapshot.data() ?? const {};
    return DashboardAnalytics(
      profileViews: data['profileViews'] as int? ?? 0,
      projectEngagement: data['projectEngagement'] as int? ?? 0,
      collaborationRequests: data['collaborationRequests'] as int? ?? 0,
      portfolioClicks: data['portfolioClicks'] as int? ?? 0,
    );
  }

  @override
  Future<List<CreativeProject>> getRecentProjects(String userId) async {
    final snapshot = await _firestore.collection('projects').where('creatorId', isEqualTo: userId).limit(3).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['projectId'] = doc.id;
      return CreativeProject.fromJson(data);
    }).toList();
  }

  @override
  Future<void> setVerified({required String userId, required bool verified}) {
    return _firestore.collection('users').doc(userId).update({'verified': verified});
  }
}