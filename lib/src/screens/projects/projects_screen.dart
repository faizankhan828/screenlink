import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/scene_link_widgets.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  ProjectStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final projects = controller.visibleProjects
        .where((p) => _statusFilter == null || p.status == _statusFilter)
        .toList();
    final currentUser = controller.currentUser;
    final scheme = Theme.of(context).colorScheme;

    // Material is required so that Chip, InkWell, and PopupMenuButton can
    // paint ink effects when this screen is pushed as a standalone route
    // (i.e. outside the AppShell Scaffold).
    return Material(
      color: Colors.transparent,
      child: SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Projects',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  ScenePillButton(
                    label: 'New project',
                    icon: Icons.add_rounded,
                    onPressed: () => context.push('/projects/new'),
                  ),
                ],
              ),
            ),
          ),

          // ── Status filter chips ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _statusFilter == null,
                      onSelected: (_) => setState(() => _statusFilter = null),
                    ),
                    const SizedBox(width: 8),
                    ...ProjectStatus.values.map((status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(status.label),
                            selected: _statusFilter == status,
                            onSelected: (_) => setState(() => _statusFilter = status),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),

          // ── Project list ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            sliver: projects.isEmpty
                ? SliverToBoxAdapter(
                    child: SceneEmptyState(
                      title: 'No matching projects',
                      message: 'Create a project brief to start a new collaboration.',
                      icon: Icons.folder_open_rounded,
                      actionLabel: 'Create project',
                      onAction: () => context.push('/projects/new'),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project = projects[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SceneCard(
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
                                                .titleMedium
                                                ?.copyWith(fontWeight: FontWeight.w900),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${project.category} • ${project.location}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SceneTag(label: project.status.label, filled: true),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  project.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: project.requiredRoles
                                      .map((role) => SceneTag(label: role))
                                      .toList(),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.people_outline_rounded,
                                        size: 16, color: scheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${project.applicants.length} applicants',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () => context.push('/projects/${project.projectId}'),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('View details'),
                                    ),
                                    if (currentUser?.uid == project.creatorId)
                                      PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          if (value == 'edit') {
                                            await context.push('/projects/${project.projectId}/edit');
                                          } else if (value == 'delete') {
                                            await controller.deleteProject(project.projectId);
                                          }
                                        },
                                        itemBuilder: (_) => const [
                                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                                          PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete',
                                                  style: TextStyle(color: Colors.red))),
                                        ],
                                        icon: const Icon(Icons.more_vert_rounded),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: projects.length,
                    ),
                  ),
          ),
        ],
      ),
      ), // SafeArea
    ); // Material
  }
}
