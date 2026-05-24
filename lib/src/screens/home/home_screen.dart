import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/data/seed_data.dart';
import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/scene_link_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final user = controller.currentUser;
    final projects = controller.visibleProjects.take(5).toList();
    final creatives = controller.trendingUsers.take(6).toList();
    final reviews = SeedData.reviews();
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user != null ? 'Hello, ${user.name.split(' ').first} 👋' : 'SceneLink',
                              style: GoogleFonts.plusJakartaSans(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              'Discover collaborators and new work.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: SceneCachedAvatar(
                          imageUrl: user?.profileImage ?? '',
                          name: user?.name ?? 'S',
                          radius: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search people, projects, roles…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: scheme.surface.withValues(alpha: 0.95),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    style: TextStyle(color: scheme.onSurface),
                    onChanged: controller.setSearchQuery,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SceneSectionHeader(
                    title: 'Trending creatives',
                    actionLabel: 'See all',
                    onAction: () => context.push('/friends'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: creatives.isEmpty
                        ? const SceneEmptyState(
                            title: 'No creatives yet',
                            message: 'Invite collaborators to get started.',
                            icon: Icons.people_rounded,
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: creatives.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) => SizedBox(
                              width: 230,
                              child: _CreativeCard(user: creatives[index]),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SceneSectionHeader(
                    title: 'Latest projects',
                    actionLabel: 'Browse all',
                    onAction: () => context.push('/projects'),
                  ),
                  const SizedBox(height: 12),
                  if (projects.isEmpty)
                    const SceneEmptyState(
                      title: 'No projects yet',
                      message: 'Use the Projects tab to create the first collaboration brief.',
                      icon: Icons.folder_copy_rounded,
                    )
                  else
                    ...projects.map(
                      (project) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ProjectFeedCard(
                          project: project,
                          onTap: () => context.push('/projects/${project.projectId}'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.visibility_off_rounded, color: scheme.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Blind collaboration mode',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Names and photos are hidden during the first review stage, so collaborators can focus purely on skills and portfolio evidence.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 14),
                    ScenePillButton(
                      label: 'Learn more',
                      onPressed: () => context.push('/accessibility'),
                      filled: false,
                      icon: Icons.arrow_forward_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SceneSectionHeader(title: 'Explore features'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 130,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FeatureCard(
                          icon: Icons.people_rounded,
                          label: 'Discover',
                          subtitle: 'Find creatives',
                          color: const Color(0xFF6D3FDA),
                          onTap: () => context.push('/friends'),
                        ),
                        _FeatureCard(
                          icon: Icons.map_rounded,
                          label: 'Nearby',
                          subtitle: 'Projects & hubs',
                          color: const Color(0xFF35B0AB),
                          onTap: () => context.push('/maps'),
                        ),
                        _FeatureCard(
                          icon: Icons.workspace_premium_rounded,
                          label: 'Premium',
                          subtitle: 'Boost visibility',
                          color: const Color(0xFF2C8C7D),
                          onTap: () => context.push('/premium'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SceneSectionHeader(title: 'Collaborator reviews'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: reviews.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => SizedBox(
                        width: 280,
                        child: _ReviewCard(review: reviews[i]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 110,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final UserReview review;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SceneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SceneCachedAvatar(imageUrl: review.reviewerImage, name: review.reviewerName, radius: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.reviewerName,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              '"${review.reviewText}"',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreativeCard extends StatelessWidget {
  const _CreativeCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return SceneCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SceneCachedAvatar(imageUrl: user.profileImage, name: user.name, radius: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${user.role.label} • ${user.location}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (user.verified)
                const Icon(Icons.verified_rounded, color: Colors.green, size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user.bio,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: user.skills.take(2).map((skill) => SceneTag(label: skill)).toList(),
          ),
        ],
      ),
    );
  }
}

class _ProjectFeedCard extends StatelessWidget {
  const _ProjectFeedCard({required this.project, required this.onTap});

  final CreativeProject project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final daysLeft = project.deadline.difference(DateTime.now()).inDays;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: SceneCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      Text(project.category, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                SceneTag(label: project.status.label, filled: true),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: project.requiredRoles.map((role) => SceneTag(label: role)).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.place_rounded, size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    project.location,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: daysLeft < 7 ? Colors.red.withValues(alpha: 0.12) : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    daysLeft <= 0 ? 'Closed' : '$daysLeft days left',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: daysLeft < 7 ? Colors.red : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
