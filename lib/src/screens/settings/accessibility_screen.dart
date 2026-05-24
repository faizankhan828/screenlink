import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';
import '../../widgets/scene_link_widgets.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  String _textSizeLabel(double scale) {
    if (scale <= 0.88) return 'Small';
    if (scale <= 1.02) return 'Normal';
    if (scale <= 1.22) return 'Large';
    return 'X-Large';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final settings = controller.accessibility;
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
        title: Text('Accessibility', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SceneCard(
            color: scheme.primaryContainer.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Live preview', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  'Changes apply instantly across SceneLink.',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.outlineVariant, width: settings.highContrast ? 2 : 1),
                  ),
                  child: Text(
                    'Sample text at ${_textSizeLabel(settings.textScaleFactor).toLowerCase()} size.',
                    style: TextStyle(
                      fontSize: 15 * settings.textScaleFactor,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SceneCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Text size', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        min: 0.85,
                        max: 1.4,
                        divisions: 11,
                        value: settings.textScaleFactor.clamp(0.85, 1.4),
                        label: _textSizeLabel(settings.textScaleFactor),
                        onChanged: (v) => controller.updateAccessibility(
                          settings.copyWith(textScaleFactor: v),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _textSizeLabel(settings.textScaleFactor),
                      style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _AccessibilityToggleCard(
            title: 'High contrast',
            subtitle: 'Stronger colours and borders for better legibility.',
            icon: Icons.contrast_rounded,
            value: settings.highContrast,
            onChanged: (v) => controller.updateAccessibility(settings.copyWith(highContrast: v)),
          ),
          const SizedBox(height: 12),
          _AccessibilityToggleCard(
            title: 'Screen reader support',
            subtitle: 'Add stronger semantic hints to controls.',
            icon: Icons.record_voice_over_rounded,
            value: settings.screenReaderFriendly,
            onChanged: (v) => controller.updateAccessibility(settings.copyWith(screenReaderFriendly: v)),
          ),
          const SizedBox(height: 12),
          _AccessibilityToggleCard(
            title: 'Reduced motion',
            subtitle: 'Minimize transitions and motion effects.',
            icon: Icons.motion_photos_off_rounded,
            value: settings.reducedMotion,
            onChanged: (v) => controller.updateAccessibility(settings.copyWith(reducedMotion: v)),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/app');
              }
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text('Done'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessibilityToggleCard extends StatelessWidget {
  const _AccessibilityToggleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SceneCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
