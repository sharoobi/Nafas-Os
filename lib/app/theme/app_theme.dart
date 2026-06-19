import 'package:flutter/material.dart';
import 'package:nafas_os/core/design/app_palette.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get darkTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      brightness: Brightness.dark,
      surface: AppPalette.surface,
      primary: AppPalette.primary,
      secondary: AppPalette.secondary,
    );

    final TextTheme baseTextTheme =
        ThemeData(brightness: Brightness.dark).textTheme;
    final TextTheme textTheme = baseTextTheme
        .copyWith(
          displayLarge: baseTextTheme.displayLarge?.copyWith(
            letterSpacing: -0.8,
            height: 1.02,
          ),
          displayMedium: baseTextTheme.displayMedium?.copyWith(
            letterSpacing: -0.6,
            height: 1.08,
          ),
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            letterSpacing: -0.3,
            height: 1.12,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            letterSpacing: -0.2,
          ),
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.36),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.34),
          labelLarge: baseTextTheme.labelLarge?.copyWith(letterSpacing: 0.1),
        )
        .apply(
          bodyColor: AppPalette.textPrimary,
          displayColor: AppPalette.textPrimary,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme.copyWith(
        surfaceContainerHighest: AppPalette.surfaceElevated,
        outlineVariant: AppPalette.stroke,
      ),
      scaffoldBackgroundColor: AppPalette.background,
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surface.withValues(alpha: 0.78),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surface.withValues(alpha: 0.84),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppPalette.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppPalette.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppPalette.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppPalette.primary, width: 1.4),
        ),
      ),
    );
  }
}
