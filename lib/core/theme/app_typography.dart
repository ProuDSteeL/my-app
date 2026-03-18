import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final Color onBg = brightness == Brightness.light
        ? AppColors.onBackgroundLight
        : AppColors.onBackgroundDark;

    final Color onSurface = brightness == Brightness.light
        ? AppColors.onSurfaceLight
        : AppColors.onSurfaceDark;

    return TextTheme(
      // Playfair Display for headings
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: onBg,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: onBg,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      // Source Sans 3 for body text
      titleLarge: GoogleFonts.sourceSans3(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      titleMedium: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      titleSmall: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onBg,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onBg,
      ),
      bodySmall: GoogleFonts.sourceSans3(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      labelMedium: GoogleFonts.sourceSans3(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      labelSmall: GoogleFonts.sourceSans3(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
    );
  }
}
