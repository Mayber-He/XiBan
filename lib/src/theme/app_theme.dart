import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const ink = Color(0xFF342821);
  static const mutedInk = Color(0xFF86756A);
  static const canvas = Color(0xFFFBF7F1);
  static const surface = Color(0xFFFFFDF9);
  static const blush = Color(0xFFF2E6DA);
  static const coral = Color(0xFFAE634D);
  static const border = Color(0xFFE9DED2);

  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: canvas,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: coral,
          brightness: Brightness.light,
          surface: surface,
        ).copyWith(
          primary: coral,
          onPrimary: Colors.white,
          secondary: const Color(0xFF776258),
          onSecondary: Colors.white,
          surface: surface,
          onSurface: ink,
          outline: border,
          outlineVariant: border,
          surfaceContainerLow: const Color(0xFFF6EFE7),
          surfaceContainerHighest: const Color(0xFFF1E8DE),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: ink,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: ink,
        fontFamily: 'serif',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.7,
      ),
      headlineMedium: TextStyle(
        color: ink,
        fontFamily: 'serif',
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(
        color: ink,
        fontFamily: 'serif',
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: ink,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: ink, fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(color: mutedInk, fontSize: 14, height: 1.45),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: border),
      ),
    ),
    dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFCF8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: mutedInk),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: coral, width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: canvas,
      surfaceTintColor: Colors.transparent,
      indicatorColor: blush,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          color: states.contains(WidgetState.selected) ? coral : mutedInk,
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
        );
      }),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: canvas,
      selectedIconTheme: IconThemeData(color: coral),
      unselectedIconTheme: IconThemeData(color: mutedInk),
      selectedLabelTextStyle: TextStyle(
        color: coral,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(color: mutedInk),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
