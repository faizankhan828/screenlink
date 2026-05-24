enum UserRole { student, freelancer, professional }

enum ExperienceLevel { beginner, intermediate, advanced }

enum ProjectStatus { open, inProgress, completed }

extension LabelledUserRole on UserRole {
  String get label => switch (this) {
        UserRole.student => 'Student',
        UserRole.freelancer => 'Freelancer',
        UserRole.professional => 'Professional',
      };
}

extension LabelledExperienceLevel on ExperienceLevel {
  String get label => switch (this) {
        ExperienceLevel.beginner => 'Beginner',
        ExperienceLevel.intermediate => 'Intermediate',
        ExperienceLevel.advanced => 'Advanced',
      };
}

extension LabelledProjectStatus on ProjectStatus {
  String get label => switch (this) {
        ProjectStatus.open => 'Open',
        ProjectStatus.inProgress => 'In Progress',
        ProjectStatus.completed => 'Completed',
      };
}

class AccessibilitySettings {
  const AccessibilitySettings({
    required this.textScaleFactor,
    required this.highContrast,
    required this.screenReaderFriendly,
    required this.reducedMotion,
  });

  final double textScaleFactor;
  final bool highContrast;
  final bool screenReaderFriendly;
  final bool reducedMotion;

  AccessibilitySettings copyWith({
    double? textScaleFactor,
    bool? highContrast,
    bool? screenReaderFriendly,
    bool? reducedMotion,
  }) {
    return AccessibilitySettings(
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      highContrast: highContrast ?? this.highContrast,
      screenReaderFriendly: screenReaderFriendly ?? this.screenReaderFriendly,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.bio,
    required this.skills,
    required this.industry,
    required this.location,
    required this.experienceLevel,
    required this.verified,
    required this.profileImage,
    required this.portfolio,
    required this.socialLinks,
    required this.savedProjectIds,
    required this.recentProjectIds,
    required this.profileViews,
    required this.projectEngagement,
    required this.collaborationRequests,
    required this.portfolioClicks,
    required this.accessibilitySettings,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String bio;
  final List<String> skills;
  final String industry;
  final String location;
  final ExperienceLevel experienceLevel;
  final bool verified;
  final String profileImage;
  final List<String> portfolio;
  final Map<String, String> socialLinks;
  final List<String> savedProjectIds;
  final List<String> recentProjectIds;
  final int profileViews;
  final int projectEngagement;
  final int collaborationRequests;
  final int portfolioClicks;
  final AccessibilitySettings accessibilitySettings;

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    String? bio,
    List<String>? skills,
    String? industry,
    String? location,
    ExperienceLevel? experienceLevel,
    bool? verified,
    String? profileImage,
    List<String>? portfolio,
    Map<String, String>? socialLinks,
    List<String>? savedProjectIds,
    List<String>? recentProjectIds,
    int? profileViews,
    int? projectEngagement,
    int? collaborationRequests,
    int? portfolioClicks,
    AccessibilitySettings? accessibilitySettings,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      industry: industry ?? this.industry,
      location: location ?? this.location,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      verified: verified ?? this.verified,
      profileImage: profileImage ?? this.profileImage,
      portfolio: portfolio ?? this.portfolio,
      socialLinks: socialLinks ?? this.socialLinks,
      savedProjectIds: savedProjectIds ?? this.savedProjectIds,
      recentProjectIds: recentProjectIds ?? this.recentProjectIds,
      profileViews: profileViews ?? this.profileViews,
      projectEngagement: projectEngagement ?? this.projectEngagement,
      collaborationRequests: collaborationRequests ?? this.collaborationRequests,
      portfolioClicks: portfolioClicks ?? this.portfolioClicks,
      accessibilitySettings: accessibilitySettings ?? this.accessibilitySettings,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.values.byName(json['role'] as String? ?? UserRole.freelancer.name),
      bio: json['bio'] as String? ?? '',
      skills: List<String>.from(json['skills'] as List? ?? const []),
      industry: json['industry'] as String? ?? '',
      location: json['location'] as String? ?? '',
      experienceLevel: ExperienceLevel.values.byName(json['experienceLevel'] as String? ?? ExperienceLevel.intermediate.name),
      verified: json['verified'] as bool? ?? false,
      profileImage: json['profileImage'] as String? ?? '',
      portfolio: List<String>.from(json['portfolio'] as List? ?? const []),
      socialLinks: Map<String, String>.from(json['socialLinks'] as Map? ?? const {}),
      savedProjectIds: List<String>.from(json['savedProjectIds'] as List? ?? const []),
      recentProjectIds: List<String>.from(json['recentProjectIds'] as List? ?? const []),
      profileViews: json['profileViews'] as int? ?? 0,
      projectEngagement: json['projectEngagement'] as int? ?? 0,
      collaborationRequests: json['collaborationRequests'] as int? ?? 0,
      portfolioClicks: json['portfolioClicks'] as int? ?? 0,
      accessibilitySettings: AccessibilitySettings(
        textScaleFactor: (json['textScaleFactor'] as num?)?.toDouble() ?? 1,
        highContrast: json['highContrast'] as bool? ?? false,
        screenReaderFriendly: json['screenReaderFriendly'] as bool? ?? true,
        reducedMotion: json['reducedMotion'] as bool? ?? false,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.name,
      'bio': bio,
      'skills': skills,
      'industry': industry,
      'location': location,
      'experienceLevel': experienceLevel.name,
      'verified': verified,
      'profileImage': profileImage,
      'portfolio': portfolio,
      'socialLinks': socialLinks,
      'savedProjectIds': savedProjectIds,
      'recentProjectIds': recentProjectIds,
      'profileViews': profileViews,
      'projectEngagement': projectEngagement,
      'collaborationRequests': collaborationRequests,
      'portfolioClicks': portfolioClicks,
      'textScaleFactor': accessibilitySettings.textScaleFactor,
      'highContrast': accessibilitySettings.highContrast,
      'screenReaderFriendly': accessibilitySettings.screenReaderFriendly,
      'reducedMotion': accessibilitySettings.reducedMotion,
    };
  }
}

class CreativeProject {
  const CreativeProject({
    required this.projectId,
    required this.creatorId,
    required this.creatorName,
    required this.creatorRole,
    required this.creatorImage,
    required this.title,
    required this.description,
    required this.category,
    required this.requiredRoles,
    required this.deadline,
    required this.status,
    required this.applicants,
    required this.blindApplications,
    required this.location,
    required this.budget,
    required this.createdAt,
    required this.savedByIds,
  });

  final String projectId;
  final String creatorId;
  final String creatorName;
  final UserRole creatorRole;
  final String creatorImage;
  final String title;
  final String description;
  final String category;
  final List<String> requiredRoles;
  final DateTime deadline;
  final ProjectStatus status;
  final List<String> applicants;
  final List<String> blindApplications;
  final String location;
  final double? budget;
  final DateTime createdAt;
  final List<String> savedByIds;

  CreativeProject copyWith({
    String? projectId,
    String? creatorId,
    String? creatorName,
    UserRole? creatorRole,
    String? creatorImage,
    String? title,
    String? description,
    String? category,
    List<String>? requiredRoles,
    DateTime? deadline,
    ProjectStatus? status,
    List<String>? applicants,
    List<String>? blindApplications,
    String? location,
    double? budget,
    DateTime? createdAt,
    List<String>? savedByIds,
  }) {
    return CreativeProject(
      projectId: projectId ?? this.projectId,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorRole: creatorRole ?? this.creatorRole,
      creatorImage: creatorImage ?? this.creatorImage,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      requiredRoles: requiredRoles ?? this.requiredRoles,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      applicants: applicants ?? this.applicants,
      blindApplications: blindApplications ?? this.blindApplications,
      location: location ?? this.location,
      budget: budget ?? this.budget,
      createdAt: createdAt ?? this.createdAt,
      savedByIds: savedByIds ?? this.savedByIds,
    );
  }

  factory CreativeProject.fromJson(Map<String, dynamic> json) {
    return CreativeProject(
      projectId: json['projectId'] as String,
      creatorId: json['creatorId'] as String? ?? '',
      creatorName: json['creatorName'] as String? ?? '',
      creatorRole: UserRole.values.byName(json['creatorRole'] as String? ?? UserRole.freelancer.name),
      creatorImage: json['creatorImage'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      requiredRoles: List<String>.from(json['requiredRoles'] as List? ?? const []),
      deadline: DateTime.tryParse(json['deadline'] as String? ?? '') ?? DateTime.now(),
      status: ProjectStatus.values.byName(json['status'] as String? ?? ProjectStatus.open.name),
      applicants: List<String>.from(json['applicants'] as List? ?? const []),
      blindApplications: List<String>.from(json['blindApplications'] as List? ?? const []),
      location: json['location'] as String? ?? '',
      budget: (json['budget'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      savedByIds: List<String>.from(json['savedByIds'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorRole': creatorRole.name,
      'creatorImage': creatorImage,
      'title': title,
      'description': description,
      'category': category,
      'requiredRoles': requiredRoles,
      'deadline': deadline.toIso8601String(),
      'status': status.name,
      'applicants': applicants,
      'blindApplications': blindApplications,
      'location': location,
      'budget': budget,
      'createdAt': createdAt.toIso8601String(),
      'savedByIds': savedByIds,
    };
  }
}

class ChatThread {
  const ChatThread({
    required this.chatId,
    required this.participants,
    required this.title,
    required this.avatarUrl,
    required this.lastMessage,
    required this.updatedAt,
    required this.unreadCount,
  });

  final String chatId;
  final List<String> participants;
  final String title;
  final String avatarUrl;
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount;

  ChatThread copyWith({
    String? chatId,
    List<String>? participants,
    String? title,
    String? avatarUrl,
    String? lastMessage,
    DateTime? updatedAt,
    int? unreadCount,
  }) {
    return ChatThread(
      chatId: chatId ?? this.chatId,
      participants: participants ?? this.participants,
      title: title ?? this.title,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class CreativeMessage {
  const CreativeMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.read,
    required this.chatId,
    required this.imageUrl,
  });

  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool read;
  final String chatId;
  final String? imageUrl;

  CreativeMessage copyWith({
    String? senderId,
    String? receiverId,
    String? message,
    DateTime? timestamp,
    bool? read,
    String? chatId,
    String? imageUrl,
  }) {
    return CreativeMessage(
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      chatId: chatId ?? this.chatId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

// ── Social Models ─────────────────────────────────────────────────────────────

class CreativePost {
  const CreativePost({
    required this.postId,
    required this.creatorId,
    required this.creatorName,
    required this.creatorImage,
    required this.creatorRole,
    required this.content,
    required this.mediaUrls,
    required this.createdAt,
    required this.likes,
    required this.commentCount,
  });

  final String postId;
  final String creatorId;
  final String creatorName;
  final String creatorImage;
  final UserRole creatorRole;
  final String content;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final List<String> likes;
  final int commentCount;

  CreativePost copyWith({List<String>? likes}) {
    return CreativePost(
      postId: postId, creatorId: creatorId, creatorName: creatorName,
      creatorImage: creatorImage, creatorRole: creatorRole, content: content,
      mediaUrls: mediaUrls, createdAt: createdAt,
      likes: likes ?? this.likes, commentCount: commentCount,
    );
  }
}

class UserReview {
  const UserReview({
    required this.reviewId,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerImage,
    required this.targetUserId,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
  });

  final String reviewId;
  final String reviewerId;
  final String reviewerName;
  final String reviewerImage;
  final String targetUserId;
  final double rating;
  final String reviewText;
  final DateTime createdAt;
}

enum FriendStatus { pending, accepted, rejected }

class FriendConnection {
  const FriendConnection({
    required this.connectionId,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  final String connectionId;
  final String fromUserId;
  final String toUserId;
  final FriendStatus status;
  final DateTime createdAt;
}

class MapLocation {
  const MapLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.description = '',
  });

  final String id;
  final String name;
  final String type; // 'studio' | 'park' | 'venue' | 'hub' | 'project'
  final double latitude;
  final double longitude;
  final String description;
}

class DashboardAnalytics {
  const DashboardAnalytics({
    required this.profileViews,
    required this.projectEngagement,
    required this.collaborationRequests,
    required this.portfolioClicks,
  });

  final int profileViews;
  final int projectEngagement;
  final int collaborationRequests;
  final int portfolioClicks;
}