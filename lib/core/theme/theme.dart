import 'package:flutter/material.dart';

class OneDarkTheme {
  static const Color background = Color(0xFF1E222A); // Sidebar / Outer Background
  static const Color surface = Color(0xFF282C34);    // Center Panel / Editor Background
  static const Color cardBg = Color(0xFF21252B);     // Inner Cards / Elements Background
  
  static const Color primary = Color(0xFF61AFEF);    // Accent Cyan-Blue
  static const Color success = Color(0xFF98C379);    // Accent Green
  static const Color error = Color(0xFFE06C75);      // Accent Red
  static const Color warning = Color(0xFFD19A66);    // Accent Orange
  static const Color purple = Color(0xFFC678DD);     // Accent Purple
  static const Color cyan = Color(0xFF56B6C2);       // Accent Cyan
  
  static const Color textMain = Color(0xFFABB2BF);   // Medium Gray Body
  static const Color textLight = Color(0xFFFFFFFF);  // White Heading
  static const Color textDark = Color(0xFF5C6370);   // Darker Gray / Disabled
  
  static const Color border = Color(0xFF3E4451);     // Boundary Line

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: cyan,
        surface: surface,
        error: error,
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        space: 1,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        hintStyle: const TextStyle(color: textDark, fontSize: 14),
        labelStyle: const TextStyle(color: textMain, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: textLight, fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: textMain, fontSize: 15, height: 1.4),
        bodyMedium: TextStyle(color: textMain, fontSize: 13, height: 1.4),
        labelLarge: TextStyle(color: textLight, fontWeight: FontWeight.w500, fontSize: 14),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(border),
        radius: const Radius.circular(4),
      ),
    );
  }
}
