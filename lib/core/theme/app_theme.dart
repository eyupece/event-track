import 'package:flutter/material.dart';

class AppTheme {
  // MVP.md'de tanımlanan renk paleti
  static const Color concertColor = Color(0xFF9C27B0); // Mor
  static const Color techColor = Color(0xFF2196F3); // Mavi
  static const Color cinemaColor = Color(0xFFE91E63); // Pembe
  static const Color theaterColor = Color(0xFFFF9800); // Turuncu
  static const Color sportsColor = Color(0xFF4CAF50); // Yeşil

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: concertColor,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
      ),
    );
  }
}
