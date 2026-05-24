import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/scene_link_widgets.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final users = controller.trendingUsers;
    final projects = controller.visibleProjects;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Search header ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search users, skills, projects…',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onChanged: controller.setSearchQuery,
                  ),
                ],
              ),
            ),
          ),

          // ── Filter chips ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilterSection(
                    label: 'Role',
                    chips: [
                      _FilterChip(
                        label: 'All roles',
                        selected: controller.selectedRoleFilter == null,
                        onTap: () => controller.setRoleFilter(null),
                      ),
                      ...UserRole.values.map((role) => _FilterChip(
                            label: role.label,
                            selected: controller.selectedRoleFilter == role,
                            onTap: () => controller.setRoleFilter(role),
                          )),
                    ],
                  ),
                  _FilterSection(
                    label: 'Category',
                    chips: [
                      _FilterChip(
                        label: 'All',
                        selected: controller.selectedCategory == null,
                        onTap: () => controller.setCategoryFilter(null),
                      ),
                      ...controller.categories.map((cat) => _FilterChip(
                            label: cat,
                            selected: controller.selectedCategory == cat,
                            onTap: () => controller.setCategoryFilter(cat),
                          )),
                    ],
                  ),
                  _FilterSection(
                    label: 'Location',
                    chips: [
                      _FilterChip(
                        label: 'Anywhere',
                        selected: controller.selectedLocation == null,
                        onTap: () => controller.setLocationFilter(null),
                      ),
                      ...controller.locations.map((loc) => _FilterChip(
                            label: loc,
                            selected: controller.selectedLocation == loc,
                            onTap: () => controller.setLocationFilter(loc),
                          )),
                    ],
                  ),
                  _FilterSection(
                    label: 'Experience',
                    chips: [
                      _FilterChip(
                        label: 'Any level',
                        selected: controller.selectedExperienceFilter == null,
                        onTap: () => controller.setExperienceFilter(null),
                      ),
                      ...ExperienceLevel.values.map((level) => _FilterChip(
                            label: level.label,
                            selected: controller.selectedExperienceFilter == level,
                            onTap: () => controller.setExperienceFilter(level),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Users ─────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverToBoxAdapter(
              child: SceneSectionHeader(title: 'People (${users.length})'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            sliver: users.isEmpty
                ? SliverToBoxAdapter(
                    child: const SceneEmptyState(
                      title: 'No people found',
                      message: 'Adjust the filters or try a broader keyword.',
                      icon: Icons.person_search_rounded,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final user = users[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: scheme.surfaceContainerHighest.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => context.push('/profile/${user.uid}'),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: scheme.primaryContainer,
                                      backgroundImage: user.profileImage.isNotEmpty
                                          ? NetworkImage(user.profileImage)
                                          : null,
                                      child: user.profileImage.isEmpty
                                          ? Text(user.name[0],
                                              style: TextStyle(
                                                  color: scheme.onPrimaryContainer,
                                                  fontWeight: FontWeight.w800))
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  user.name,
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.w800),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (user.verified)
                                                const Icon(Icons.verified_rounded,
                                                    color: Colors.green, size: 16),
                                            ],
                                          ),
                                          Text(
                                            '${user.role.label} • ${user.skills.take(2).join(' · ')}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right_rounded,
                                        color: scheme.onSurfaceVariant),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: users.length,
                    ),
                  ),
          ),

          // ── Projects ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: SceneSectionHeader(title: 'Projects (${projects.length})'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            sliver: projects.isEmpty
                ? SliverToBoxAdapter(
                    child: const SceneEmptyState(
                      title: 'No projects found',
                      message: 'Try different keywords or remove filters.',
                      icon: Icons.folder_copy_rounded,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project = projects[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SceneCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                project.title,
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                              subtitle: Text(
                                project.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: SceneTag(label: project.category, filled: true),
                              onTap: () => context.push('/projects/${project.projectId}'),
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
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.label, required this.chips});

  final String label;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chips
                .map((chip) => Padding(padding: const EdgeInsets.only(right: 8), child: chip))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
