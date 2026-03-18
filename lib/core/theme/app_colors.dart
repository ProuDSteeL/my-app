import 'package:flutter/material.dart';

abstract class AppColors {
  // Light theme
  static const Color primaryLight = Color(0xFFC05621);       // Terracotta
  static const Color primaryVariantLight = Color(0xFF9C4221); // Dark clay
  static const Color secondaryLight = Color(0xFFD69E2E);      // Warm yellow
  static const Color backgroundLight = Color(0xFFFFFAF0);     // Cream
  static const Color surfaceLight = Color(0xFFFEFCF3);        // Sandy
  static const Color onBackgroundLight = Color(0xFF1A202C);    // Near black
  static const Color onSurfaceLight = Color(0xFF718096);       // Warm gray
  static const Color cardBorderLight = Color(0xFFE2D8C3);      // Sand border

  // Dark theme
  static const Color backgroundDark = Color(0xFF1A1A2E);      // Dark graphite
  static const Color surfaceDark = Color(0xFF232340);
  static const Color primaryDark = Color(0xFFED8936);          // Light terracotta
  static const Color onBackgroundDark = Color(0xFFFEFCF3);     // Cream
  static const Color onSurfaceDark = Color(0xFFA0AEC0);        // Muted gray
  static const Color cardBorderDark = Color(0xFF3D3D5C);       // Dark border

  // Shared
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);

  // Shimmer colors
  static const Color shimmerBaseLight = Color(0xFFF5EFE0);     // Warm sandy base
  static const Color shimmerHighlightLight = Color(0xFFFEFCF3); // Sandy highlight
  static const Color shimmerBaseDark = Color(0xFF2D2D45);       // Dark shimmer base
  static const Color shimmerHighlightDark = Color(0xFF3D3D5C);  // Dark shimmer highlight
}
