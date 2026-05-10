import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF2CB9A8);
  static const Color primaryLight = Color(0xFF7DE2D1);
  static const Color primaryDark = Color(0xFF159A8A);

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF5ED3E8);
  static const Color secondaryLight = Color(0xFFA7EAF3);
  static const Color secondaryDark = Color(0xFF2AAFC6);

  // Accent Colors
  static const Color accentColor = Color(0xFFF2B66D);
  static const Color errorColor = Color(0xFFE76F7A);
  static const Color successColor = Color(0xFF36B37E);
  static const Color warningColor = Color(0xFFF2B66D);

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF5FBFA);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF173236);
  static const Color textSecondary = Color(0xFF6A7E80);
  static const Color dividerColor = Color(0xFFE4EFEE);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successColor, Color(0xFF8AE3B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFFE7FBF7), Color(0xFFDDF8F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFFE8FBFF), Color(0xFFD9F5FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
      surface: surfaceColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.15,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondary,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondary,
        height: 1.35,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 0,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: dividerColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FCFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: const Color(0xFF091A1A),
    colorScheme: ColorScheme.dark(
      primary: primaryLight,
      secondary: secondaryLight,
      tertiary: accentColor,
      error: errorColor,
      surface: const Color(0xFF102525),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF102525),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF102525),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );
}
