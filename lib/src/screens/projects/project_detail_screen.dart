import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/scene_link_widgets.dart';
import 'create_project_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final CreativeProject project;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  bool _blindMode = true;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final currentUser = controller.currentUser;
    final project = controller.projects.firstWhere(
      (item) => item.projectId == widget.project.projectId,
      orElse: () => widget.project,
    );
    final scheme = Theme.of(context).colorScheme;
    final daysLeft = project.deadline.difference(DateTime.now()).inDays;
    final isOwner = currentUser?.uid == project.creatorId;
    final hasApplied = currentUser != null && project.applicants.contains(currentUser.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project details'),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Edit project',
              onPressed: () => context.push('/projects/${project.projectId}/edit'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Title card ──────────────────────────────────────────────
          SceneCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            project.category,
                            style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SceneTag(label: project.status.label, filled: true),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  project.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant, height: 1.6),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      project.requiredRoles.map((role) => SceneTag(label: role)).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Meta card ───────────────────────────────────────────────
          SceneCard(
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.place_rounded,
                  iconColor: Colors.blue,
                  label: 'Location',
                  value: project.location,
                ),
                const Divider(height: 20),
                _DetailRow(
                  icon: Icons.schedule_rounded,
                  iconColor: daysLeft < 7 ? Colors.red : Colors.green,
                  label: 'Deadline',
                  value: DateFormat('MMM d, yyyy').format(project.deadline),
                  valueColor: daysLeft < 7 ? Colors.red : null,
                ),
                const Divider(height: 20),
                _DetailRow(
                  icon: Icons.groups_rounded,
                  iconColor: Colors.orange,
                  label: 'Total applicants',
                  value: '${project.applicants.length}',
                ),
                const Divider(height: 20),
                _DetailRow(
                  icon: Icons.visibility_off_rounded,
                  iconColor: Colors.purple,
                  label: 'Blind applicants',
                  value: '${project.blindApplications.length}',
                ),
                if (project.budget != null) ...[
                  const Divider(height: 20),
                  _DetailRow(
                    icon: Icons.payments_rounded,
                    iconColor: Colors.teal,
                    label: 'Budget',
                    value: '£${project.budget!.toStringAsFixed(0)}',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Creator card ────────────────────────────────────────────
          SceneCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Posted by',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: scheme.primaryContainer,
                      backgroundImage: project.creatorImage.isNotEmpty
                          ? NetworkImage(project.creatorImage)
                          : null,
                      child: project.creatorImage.isEmpty
                          ? Text(
                              project.creatorName.isNotEmpty ? project.creatorName[0] : '?',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: scheme.onPrimaryContainer,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.creatorName,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            project.creatorRole.label,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (controller.users
                        .any((u) => u.uid == project.creatorId && u.verified))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, color: Colors.green, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Apply card ──────────────────────────────────────────────
          if (currentUser != null && !isOwner)
            SceneCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apply to this project',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Blind collaboration mode',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Your name and photo are hidden during first review.',
                    ),
                    value: _blindMode,
                    onChanged: (v) => setState(() => _blindMode = v),
                  ),
                  const SizedBox(height: 12),
                  if (hasApplied)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'You have already applied',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ScenePillButton(
                            label: 'Save project',
                            filled: false,
                            icon: Icons.bookmark_add_rounded,
                            onPressed: () async {
                              await controller.saveProject(project.projectId);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Project saved'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ScenePillButton(
                            label: 'Apply now',
                            icon: Icons.send_rounded,
                            onPressed: () async {
                              await controller.applyToProject(
                                project.projectId,
                                blindMode: _blindMode,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _blindMode
                                        ? 'Applied anonymously ✓'
                                        : 'Application submitted ✓',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: iconColor ?? scheme.onSurfaceVariant, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: valueColor ?? scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
