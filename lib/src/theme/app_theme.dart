import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const ink = Color(0xFF302825);
  static const mutedInk = Color(0xFF766963);
  static const canvas = Color(0xFFFFF9F6);
  static const surface = Color(0xFFFFFFFF);
  static const blush = Color(0xFFF8E7E2);
  static const coral = Color(0xFFB95148);
  static const border = Color(0xFFEFE3DE);

  static final light = ThemeData(
    useMaterial3: true,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: coral,
          brightness: Brightness.light,
          surface: surface,
        ).copyWith(
          primary: coral,
          onPrimary: Colors.white,
          secondary: const Color(0xFF7E6558),
          onSecondary: Colors.white,
          surface: surface,
          onSurface: ink,
          outlineVariant: border,
        ),
    scaffoldBackgroundColor: canvas,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: ink,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.7,
      ),
      headlineMedium: TextStyle(
        color: ink,
        fontSize: 25,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(
        color: ink,
        fontSize: 18,
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
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: border),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: canvas,
      indicatorColor: blush,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
