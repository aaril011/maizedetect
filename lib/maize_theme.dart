import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from Stitch project `2432233940897518350` (Agri-Intelligence).
abstract final class MaizeColors {
  static const Color background = Color(0xFFF9FAF5);
  static const Color primary = Color(0xFF03271A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1B3D2F);
  static const Color onPrimaryContainer = Color(0xFF84A895);
  static const Color secondary = Color(0xFF386934);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFB6EEAB);
  static const Color onSecondaryContainer = Color(0xFF3C6E37);
  static const Color tertiaryFixed = Color(0xFFE0EB78);
  static const Color tertiaryContainer = Color(0xFF353A00);
  static const Color onTertiaryFixed = Color(0xFF1A1D00);
  static const Color surface = Color(0xFFF9FAF5);
  static const Color surfaceContainer = Color(0xFFEDEEE9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE2E3DE);
  static const Color onSurface = Color(0xFF1A1C19);
  static const Color onSurfaceVariant = Color(0xFF414844);
  static const Color primaryFixed = Color(0xFFC5EBD7);
  static const Color onPrimaryFixedVariant = Color(0xFF2C4D3F);
  static const Color inverseOnSurface = Color(0xFFF0F1EC);
  static const Color outlineVariant = Color(0xFFC1C8C2);
  static const Color error = Color(0xFFBA1A1A);
  static const Color navActiveBackground = Color(0xFFE8F5E9);
}

ThemeData buildMaizeTheme() {
  final colorScheme = ColorScheme.light(
    primary: MaizeColors.primary,
    onPrimary: MaizeColors.onPrimary,
    primaryContainer: MaizeColors.primaryContainer,
    onPrimaryContainer: MaizeColors.onPrimaryContainer,
    secondary: MaizeColors.secondary,
    onSecondary: MaizeColors.onSecondary,
    secondaryContainer: MaizeColors.secondaryContainer,
    onSecondaryContainer: MaizeColors.onSecondaryContainer,
    tertiary: MaizeColors.tertiaryContainer,
    onTertiary: MaizeColors.onPrimary,
    surface: MaizeColors.surface,
    onSurface: MaizeColors.onSurface,
    onSurfaceVariant: MaizeColors.onSurfaceVariant,
    error: MaizeColors.error,
    onError: Colors.white,
    outlineVariant: MaizeColors.outlineVariant,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: MaizeColors.background,
  );
  return base.copyWith(
    textTheme: GoogleFonts.manropeTextTheme(base.textTheme),
  );
}
