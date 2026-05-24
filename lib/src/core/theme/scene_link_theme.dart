import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SceneLinkTheme {
  static ThemeData light({required bool highContrast, required bool reducedMotion}) {
    final scheme = highContrast
        ? const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF000000),
            onPrimary: Color(0xFFFFFFFF),
            secondary: Color(0xFF1A1A1A),
            onSecondary: Color(0xFFFFFFFF),
            tertiary: Color(0xFF333333),
            onTertiary: Color(0xFFFFFFFF),
            error: Color(0xFFB00020),
            onError: Color(0xFFFFFFFF),
            surface: Color(0xFFFFFFFF),
            onSurface: Color(0xFF000000),
            surfaceContainerHighest: Color(0xFFF0F0F0),
            onSurfaceVariant: Color(0xFF1A1A1A),
            outline: Color(0xFF000000),
            outlineVariant: Color(0xFF000000),
          )
        : ColorScheme.fromSeed(
            seedColor: const Color(0xFF3846A6),
            brightness: Brightness.light,
            surface: const Color(0xFFF6F7FB),
          ).copyWith(
            primary: const Color(0xFF1F2A63),
            secondary: const Color(0xFF6677C8),
            tertiary: const Color(0xFF6AA7C8),
            surfaceContainerHighest: const Color(0xFFE9ECF5),
          );

    return _buildTheme(scheme, highContrast: highContrast, reducedMotion: reducedMotion);
  }

  static ThemeData dark({required bool highContrast, required bool reducedMotion}) {
    final scheme = highContrast
        ? const ColorScheme(
            brightness: Brightness.dark,
            primary: Color(0xFFFFFFFF),
            onPrimary: Color(0xFF000000),
            secondary: Color(0xFFE0E0E0),
            onSecondary: Color(0xFF000000),
            tertiary: Color(0xFFCCCCCC),
            onTertiary: Color(0xFF000000),
            error: Color(0xFFFF6B6B),
            onError: Color(0xFF000000),
            surface: Color(0xFF000000),
            onSurface: Color(0xFFFFFFFF),
            surfaceContainerHighest: Color(0xFF1A1A1A),
            onSurfaceVariant: Color(0xFFE8E8E8),
            outline: Color(0xFFFFFFFF),
            outlineVariant: Color(0xFFFFFFFF),
          )
        : ColorScheme.fromSeed(
            seedColor: const Color(0xFF7A8CFF),
            brightness: Brightness.dark,
            surface: const Color(0xFF151923),
          ).copyWith(
            primary: const Color(0xFF9FAEFF),
            secondary: const Color(0xFF8FA7FF),
            tertiary: const Color(0xFF6ED3E5),
            surfaceContainerHighest: const Color(0xFF1B2230),
          );

    return _buildTheme(scheme, highContrast: highContrast, reducedMotion: reducedMotion);
  }

  static ThemeData _buildTheme(ColorScheme scheme, {required bool highContrast, required bool reducedMotion}) {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();
    final pageTransitions = reducedMotion
        ? const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: _NoPageTransitionsBuilder(),
              TargetPlatform.iOS: _NoPageTransitionsBuilder(),
              TargetPlatform.macOS: _NoPageTransitionsBuilder(),
              TargetPlatform.windows: _NoPageTransitionsBuilder(),
              TargetPlatform.linux: _NoPageTransitionsBuilder(),
              TargetPlatform.fuchsia: _NoPageTransitionsBuilder(),
            },
          )
        : const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            },
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      pageTransitionsTheme: pageTransitions,
      textTheme: baseTextTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest.withValues(alpha: highContrast ? 1.0 : 0.95),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer.withValues(alpha: 0.75),
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: scheme.onSurfaceVariant)),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface.withValues(alpha: highContrast ? 1 : 0.95),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.outlineVariant, width: highContrast ? 2 : 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.primary, width: highContrast ? 2.5 : 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    );
  }
}

class _NoPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}