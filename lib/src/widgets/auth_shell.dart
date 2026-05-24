import 'package:flutter/material.dart';

import '../core/theme/auth_text_styles.dart';

/// Shared gradient layout for login and signup screens.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.child,
    this.tagline = 'Connect with creatives across the West Midlands',
  });

  final Widget child;
  final String tagline;

  static const _gradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF3730A3), Color(0xFF7C3AED), Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxContent = size.width > 720 ? 440.0 : size.width - 32;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BrandHeader(tagline: tagline),
                    const SizedBox(height: 24),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.tagline});

  final String tagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFF59E0B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          'SceneLink',
          textAlign: TextAlign.center,
          style: AuthTextStyles.brandTitle.copyWith(color: Colors.white, fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: AuthTextStyles.brandSubtitle.copyWith(color: Colors.white.withValues(alpha: 0.85)),
        ),
      ],
    );
  }
}
