import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayfulTheme {
  // Concept 3 Color Palette
  static const Color primaryRed = Color(0xFFFF6B6B);
  static const Color primaryTeal = Color(0xFF4ECDC4);
  static const Color primaryYellow = Color(0xFFFFE66D);
  static const Color primaryDark = Color(0xFF1A535C);
  static const Color primaryPink = Color(0xFFFF99C8);
  static const Color primaryOrange = Color(0xFFFF9F1C);
  
  // Accent color aliases for compatibility
  static const Color accentOrange = primaryOrange;
  static const Color accentPink = primaryPink;
  static const Color accentPurple = Color(0xFF9B59B6);
  
  static const Color bgColor = Color(0xFFF7F9FC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF888888);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: primaryPink,
        surface: cardBg,
        background: bgColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: bgColor,
      
      // Typography - Nunito font
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textMain,
        ).copyWith(inherit: true),
        displayMedium: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textMain,
        ).copyWith(inherit: true),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textMain,
        ).copyWith(inherit: true),
        titleLarge: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textMain,
        ).copyWith(inherit: true),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textMain,
        ).copyWith(inherit: true),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textMain,
        ).copyWith(inherit: true),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: cardBg,
        shadowColor: Colors.black.withOpacity(0.05),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textMain,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textMain,
        ).copyWith(inherit: true),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ).copyWith(inherit: true),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          side: const BorderSide(color: primaryDark, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ).copyWith(inherit: true),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: primaryTeal.withOpacity(0.1),
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryTeal,
        ).copyWith(inherit: true),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardBg,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12).copyWith(inherit: true),
        unselectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 12).copyWith(inherit: true),
      ),
    );
  }

  static ThemeData get darkTheme {
    const Color darkBg = Color(0xFF0F172A);
    const Color darkCard = Color(0xFF1E293B);
    const Color darkText = Color(0xFFF1F5F9);
    const Color darkTextSecondary = Color(0xFF94A3B8);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: primaryPink,
        surface: darkCard,
        background: darkBg,
        onBackground: darkText,
        onSurface: darkText,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      dividerColor: darkTextSecondary.withOpacity(0.2),
      
      // Typography
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w800, color: darkText).copyWith(inherit: true),
        displayMedium: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w700, color: darkText).copyWith(inherit: true),
        headlineMedium: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w700, color: darkText).copyWith(inherit: true),
        titleLarge: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w600, color: darkText).copyWith(inherit: true),
        bodyLarge: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w400, color: darkText).copyWith(inherit: true),
        bodyMedium: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400, color: darkText).copyWith(inherit: true),
        bodySmall: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400, color: darkTextSecondary).copyWith(inherit: true),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: darkCard,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: darkText,
        titleTextStyle: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700, color: darkText).copyWith(inherit: true),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary),
        hintStyle: const TextStyle(color: darkTextSecondary),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: primaryTeal,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }


  // Helper method to get color by index (for variety)
  static Color getColorByIndex(int index) {
    final colors = [primaryRed, primaryTeal, primaryYellow, primaryPink, primaryOrange];
    return colors[index % colors.length];
  }
}
