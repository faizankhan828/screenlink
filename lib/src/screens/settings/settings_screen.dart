import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';
import '../../widgets/scene_link_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/app');
            }
          },
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Appearance ───────────────────────────────────────────────
          _SettingsSection(
            title: 'Appearance',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.palette_rounded, color: scheme.onPrimaryContainer, size: 20),
                ),
                title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Light, dark, or follow system'),
                trailing: DropdownButton<ThemeMode>(
                  value: controller.themeMode,
                  underline: const SizedBox.shrink(),
                  onChanged: (v) {
                    if (v != null) controller.setThemeMode(v);
                  },
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _SettingsSection(
            title: 'Premium',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.workspace_premium_rounded, color: Colors.indigo.shade700, size: 20),
                ),
                title: const Text('Upgrade to Premium', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Unlock analytics, visibility, and portfolio boosts'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/premium'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Accessibility ────────────────────────────────────────────
          _SettingsSection(
            title: 'Accessibility',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.accessibility_new_rounded,
                      color: scheme.onSecondaryContainer, size: 20),
                ),
                title: const Text('Accessibility settings',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Text size, contrast, screen reader, motion'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/accessibility'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Analytics ────────────────────────────────────────────────
          _SettingsSection(
            title: 'Analytics',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: Colors.orange, size: 20),
                ),
                title: const Text('Premium analytics',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Profile views, engagement, and more'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/premium-dashboard'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Sign out ─────────────────────────────────────────────────
          FilledButton.tonal(
            onPressed: () async {
              await controller.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, size: 18),
                SizedBox(width: 8),
                Text('Sign out', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SceneCard(
          child: Column(children: children),
        ),
      ],
    );
  }
}
