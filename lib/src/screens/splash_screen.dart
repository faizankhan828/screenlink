import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/auth_text_styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const _gradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF312E81), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compact = size.height < 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFF59E0B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SceneLink',
                            style: AuthTextStyles.brandTitle.copyWith(
                              color: Colors.white,
                              fontSize: compact ? 32 : 38,
                            ),
                          ),
                          Text(
                            'West Midlands creative network',
                            style: AuthTextStyles.brandSubtitle.copyWith(
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 28 : 48),
                Text(
                  'Where creative\ncollaboration\nstarts',
                  style: AuthTextStyles.heroHeadline.copyWith(
                    color: Colors.white,
                    fontSize: compact ? 34 : 42,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Discover projects, connect with filmmakers, and grow your portfolio across Birmingham and beyond.',
                  style: AuthTextStyles.heroBody.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
                const Spacer(),
                const _FeatureRow(icon: Icons.people_alt_rounded, label: 'Find collaborators'),
                const SizedBox(height: 10),
                const _FeatureRow(icon: Icons.map_rounded, label: 'Explore nearby studios'),
                const SizedBox(height: 10),
                const _FeatureRow(icon: Icons.chat_bubble_rounded, label: 'Message in real time'),
                SizedBox(height: compact ? 24 : 36),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: () => context.go('/signup'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5B21B6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Get started free',
                      style: AuthTextStyles.buttonLabelLarge.copyWith(color: const Color(0xFF5B21B6)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => context.go('/login'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Sign in',
                      style: AuthTextStyles.buttonLabel.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFBBF24), size: 20),
        const SizedBox(width: 10),
        Text(
          label,
          style: AuthTextStyles.featureLabel.copyWith(color: Colors.white.withValues(alpha: 0.9)),
        ),
      ],
    );
  }
}
