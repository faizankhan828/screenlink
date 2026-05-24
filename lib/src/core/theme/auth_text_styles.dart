import 'package:flutter/material.dart';

/// Lightweight text styles for splash/auth — no network font fetch on navigation.
abstract final class AuthTextStyles {
  static const brandTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static const brandSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const heroHeadline = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w800,
    height: 1.08,
    letterSpacing: -1.0,
  );

  static const heroBody = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const featureLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const formTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );

  static const buttonLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const buttonLabelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );
}
