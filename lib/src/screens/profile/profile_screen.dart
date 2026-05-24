import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/scene_link_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final user = userId == null
        ? controller.currentUser
        : controller.users.where((item) => item.uid == userId).cast<AppUser?>().firstOrNull;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isSelf = userId == null;
    final recentProjects =
        controller.projects.where((p) => p.creatorId == user.uid).take(3).toList();
    final scheme = Theme.of(context).colorScheme;

    return isSelf
        ? _buildSelfView(context, user, recentProjects, controller, scheme)
        : Scaffold(
            appBar: AppBar(title: Text(user.name)),
            body: _buildContent(context, user, false, recentProjects, controller, scheme),
          );
  }

  // ── Self-profile: gradient header + content ───────────────────────────────
  Widget _buildSelfView(
    BuildContext context,
    AppUser user,
    List<CreativeProject> recentProjects,
    AppController controller,
    ColorScheme scheme,
  ) {
    return Scaffold(
      body: SafeArea(
        child: _buildContent(
          context, user, true, recentProjects, controller, scheme,
        ),
      ),
    );
  }

  // ── Main scrollable content ───────────────────────────────────────────────
  Widget _buildContent(
    BuildContext context,
    AppUser user,
    bool isSelf,
    List<CreativeProject> recentProjects,
    AppController controller,
    ColorScheme scheme,
  ) {
    return ListView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: isSelf ? 0 : 20,
        bottom: 32,
      ),
      children: [
        // ── Gradient header text (self only) ────────────────────────
        if (isSelf) ...[
          const SizedBox(height: 12),
          SceneCard(
            color: scheme.primaryContainer.withValues(alpha: 0.35),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Profile',
                        style: GoogleFonts.plusJakartaSans(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user.name,
                        style: GoogleFonts.plusJakartaSans(
                          color: scheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Accessibility settings',
                  child: ScenePillButton(
                    label: 'Access.',
                    filled: false,
                    icon: Icons.accessibility_new_rounded,
                    onPressed: () => context.push('/accessibility'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Profile header card ──────────────────────────────────────
        SceneCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: scheme.primaryContainer,
                        backgroundImage: sceneProfileImageProvider(user.profileImage),
                        child: user.profileImage.isEmpty
                            ? Text(
                                user.name.isNotEmpty ? user.name[0] : 'S',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onPrimaryContainer,
                                ),
                              )
                            : null,
                      ),
                      if (user.verified)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: scheme.surface, width: 2),
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.role.label,
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.place_rounded, size: 14, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                '${user.industry} • ${user.location}',
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            user.experienceLevel.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(user.bio, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.skills.map((skill) => SceneTag(label: skill)).toList(),
              ),
              if (isSelf) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // ── Quick actions ────────────────────────────────────
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ScenePillButton(
                      label: 'Edit profile',
                      icon: Icons.edit_rounded,
                      filled: false,
                      onPressed: () => _showEditProfile(context, user, controller),
                    ),
                    ScenePillButton(
                      label: 'Upload photo',
                      icon: Icons.photo_camera_rounded,
                      filled: false,
                      onPressed: () => _uploadProfilePhoto(context, controller),
                    ),
                    ScenePillButton(
                      label: 'Add media',
                      icon: Icons.collections_rounded,
                      filled: false,
                      onPressed: () => _uploadPortfolioMedia(context, controller),
                    ),
                    ScenePillButton(
                      label: 'Analytics',
                      icon: Icons.bar_chart_rounded,
                      onPressed: () => context.push('/premium'),
                    ),
                    // ── Accessibility shortcut ────────────────────────
                    ScenePillButton(
                      label: 'Accessibility',
                      icon: Icons.accessibility_new_rounded,
                      filled: false,
                      onPressed: () => context.push('/accessibility'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Stats grid ───────────────────────────────────────────────
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.25,
          children: [
            SceneMetricCard(
              label: 'Profile views',
              value: '${user.profileViews}',
              icon: Icons.visibility_rounded,
              accentColor: Colors.blue,
            ),
            SceneMetricCard(
              label: 'Engagement',
              value: '${user.projectEngagement}',
              icon: Icons.handshake_rounded,
              accentColor: Colors.orange,
            ),
            SceneMetricCard(
              label: 'Collaboration requests',
              value: '${user.collaborationRequests}',
              icon: Icons.request_page_rounded,
              accentColor: Colors.green,
            ),
            SceneMetricCard(
              label: 'Portfolio clicks',
              value: '${user.portfolioClicks}',
              icon: Icons.link_rounded,
              accentColor: Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Portfolio ────────────────────────────────────────────────
        const SceneSectionHeader(title: 'Portfolio'),
        const SizedBox(height: 10),
        SceneCard(
          child: user.portfolio.isEmpty
              ? const SceneEmptyState(
                  title: 'No portfolio items',
                  message: 'Upload images or links to showcase your work.',
                  icon: Icons.collections_rounded,
                )
              : Column(
                  children: user.portfolio
                      .map((item) => _PortfolioEntryTile(url: item))
                      .toList(),
                ),
        ),
        const SizedBox(height: 20),

        // ── Recent projects ──────────────────────────────────────────
        const SceneSectionHeader(title: 'Recent projects'),
        const SizedBox(height: 10),
        if (recentProjects.isEmpty)
          SceneEmptyState(
            title: 'No projects yet',
            message: isSelf
                ? 'Create a project from the Projects tab.'
                : 'This creator has no public projects.',
            icon: Icons.folder_copy_rounded,
          )
        else
          ...recentProjects.map(
            (project) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SceneCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            project.category,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    SceneTag(label: project.status.label, filled: true),
                  ],
                ),
              ),
            ),
          ),

        // ── Settings button (self only) ──────────────────────────────
        if (isSelf) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ScenePillButton(
                  label: 'Settings',
                  filled: false,
                  icon: Icons.settings_rounded,
                  onPressed: () => context.push('/settings'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  // ── Edit profile bottom sheet ─────────────────────────────────────────────
  void _showEditProfile(BuildContext context, AppUser user, AppController controller) {
    final nameCtrl = TextEditingController(text: user.name);
    final bioCtrl = TextEditingController(text: user.bio);
    final skillsCtrl = TextEditingController(text: user.skills.join(', '));
    final locationCtrl = TextEditingController(text: user.location);
    final industryCtrl = TextEditingController(text: user.industry);
    var experience = user.experienceLevel;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Edit profile',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      prefixIcon: Icon(Icons.info_outline_rounded),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: skillsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Skills',
                      hintText: 'Comma separated',
                      prefixIcon: Icon(Icons.stars_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: industryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Industry',
                      prefixIcon: Icon(Icons.business_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ExperienceLevel>(
                    initialValue: experience,
                    items: ExperienceLevel.values
                        .map((l) => DropdownMenuItem(value: l, child: Text(l.label)))
                        .toList(),
                    onChanged: (v) => setState(() => experience = v ?? experience),
                    decoration: const InputDecoration(
                      labelText: 'Experience level',
                      prefixIcon: Icon(Icons.workspace_premium_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ScenePillButton(
                    label: 'Save changes',
                    icon: Icons.check_rounded,
                    onPressed: () async {
                      final error = await controller.updateProfile(
                        user.copyWith(
                          name: nameCtrl.text.trim(),
                          bio: bioCtrl.text.trim(),
                          skills: skillsCtrl.text
                              .split(',')
                              .map((s) => s.trim())
                              .where((s) => s.isNotEmpty)
                              .toList(),
                          industry: industryCtrl.text.trim(),
                          location: locationCtrl.text.trim(),
                          experienceLevel: experience,
                        ),
                      );
                      if (!ctx.mounted) return;
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(error ?? 'Profile updated'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      if (error == null) Navigator.of(ctx).pop();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _uploadProfilePhoto(BuildContext context, AppController controller) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final Uint8List bytes = await picked.readAsBytes();
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    String? error;
    try {
      error = await controller
          .uploadProfileImage(
            bytes: bytes,
            fileName: picked.name.isEmpty ? 'profile.jpg' : picked.name,
          )
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      error = e.toString();
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Profile photo updated'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _uploadPortfolioMedia(BuildContext context, AppController controller) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'gif', 'webp', 'mp4', 'mov'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;
    final file = result.files.single;
    final error =
        await controller.addPortfolioMedia(bytes: file.bytes!, fileName: file.name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Media added to portfolio'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

class _PortfolioEntryTile extends StatelessWidget {
  const _PortfolioEntryTile({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final isImage = ['png', 'jpg', 'jpeg', 'gif', 'webp']
        .any((ext) => url.toLowerCase().endsWith('.$ext'));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: isImage
              ? Image.network(url, width: 48, height: 48, fit: BoxFit.cover)
              : Container(
                  width: 48,
                  height: 48,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.link_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
        ),
        title: Text(
          url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(isImage ? 'Uploaded media' : 'Portfolio link'),
      ),
    );
  }
}
