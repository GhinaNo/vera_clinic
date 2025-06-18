import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color purple = Color(0xFF8E44AD);
  static const Color beige = Color(0xFFF5E6DC);
  static const Color secondaryColor = Color(0xfff0ecb4);
  static const Color offWhite = Color(0xFFFFFDF9);
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
}
