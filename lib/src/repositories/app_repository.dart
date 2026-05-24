import 'dart:typed_data';

import '../models/app_models.dart';

abstract class AppRepository {
  Stream<AppUser?> authStateChanges();

  Future<AppUser?> signInWithEmail({required String email, required String password});
  Future<AppUser?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });
  Future<AppUser?> signInWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();

  Future<List<AppUser>> getUsers();
  Future<List<CreativeProject>> getProjects();
  Stream<List<ChatThread>> watchChats(String uid);
  Stream<List<CreativeMessage>> watchMessages(String chatId);

  Future<AppUser> updateProfile(AppUser user);
  Future<AppUser> updateAccessibility(AppUser user);
  Future<String> uploadProfileImage({required String userId, required Uint8List bytes, required String fileName});
  Future<String> uploadPortfolioMedia({required String userId, required Uint8List bytes, required String fileName});
  Future<CreativeProject> createProject(CreativeProject project);
  Future<CreativeProject> updateProject(CreativeProject project);
  Future<void> deleteProject(String projectId);
  Future<void> saveProject({required String projectId, required String userId});
  Future<void> applyToProject({required String projectId, required String userId, required bool blindMode});
  Future<void> sendMessage(CreativeMessage message);
  Future<String> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
    required String title,
  });
  Future<DashboardAnalytics> getAnalytics(String userId);
  Future<List<CreativeProject>> getRecentProjects(String userId);
  Future<void> setVerified({required String userId, required bool verified});
}