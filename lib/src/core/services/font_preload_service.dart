import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Preloads fonts used on splash and auth screens so navigation feels instant.
Future<void> preloadSceneLinkFonts() async {
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.plusJakartaSans(),
      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
    ]);
  } catch (_) {
    // Offline or blocked network — system fonts will be used as fallback.
  }
}
