import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color purple = Color(0xFF8E44AD);
  static const Color purpleAccent = Color(0xFFD291F3);
  static const Color beige = Color(0xFFF5E6DC);
  static const Color secondaryColor = Color(0xfff0ecb4);
  static const Color offWhite = Color(0xFFFFFDF9);

  static const Color darkBackground = Color(0xFF1C1C2E);
  static const Color glassWhite = Colors.white24;
  static const Color textLight = Colors.white;
  static const Color textSecondary = Colors.white70;
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.purple,
    scaffoldBackgroundColor: AppColors.offWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.purple,
      foregroundColor: Colors.white,
    ),
    textTheme: GoogleFonts.cairoTextTheme(),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.purple,
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    textTheme: GoogleFonts.cairoTextTheme(
      ThemeData.dark().textTheme,
    ),
    cardColor: AppColors.glassWhite,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: AppColors.glassWhite,
    ),
  );
}
