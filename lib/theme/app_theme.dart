import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta principal — verde esmeralda moderno
  static const Color primaryGreen = Color(0xFF1B8A5A);
  static const Color primaryGreenLight = Color(0xFF2ECC89);
  static const Color primaryGreenDark = Color(0xFF0D5C3A);

  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentAmber = Color(0xFFFFC535);

  static const Color surface = Color(0xFFF7FAF8);
  static const Color surfaceDark = Color(0xFF121A15);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E2D24);

  static const Color textPrimary = Color(0xFF1A2420);
  static const Color textSecondary = Color(0xFF5A7068);
  static const Color textPrimaryDark = Color(0xFFECF5EF);
  static const Color textSecondaryDark = Color(0xFF8BB59A);

  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32, fontWeight: FontWeight.w800, color: primary),
        displayMedium: GoogleFonts.outfit(
          fontSize: 26, fontWeight: FontWeight.w700, color: primary),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w700, color: primary),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w600, color: primary),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w400, color: primary),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w400, color: secondary),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: primaryGreen,
          secondary: accentOrange,
          tertiary: accentAmber,
          surface: surface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimary,
        ),
        scaffoldBackgroundColor: surface,
        textTheme: _textTheme(textPrimary, textSecondary),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: cardLight,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w600),
            elevation: 2,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryGreen,
            side: const BorderSide(color: primaryGreen, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          labelStyle: GoogleFonts.inter(color: textSecondary),
          prefixIconColor: primaryGreen,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: primaryGreen.withOpacity(0.1),
          labelStyle: GoogleFonts.inter(
            color: primaryGreen, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        dividerColor: Colors.grey.shade200,
        tabBarTheme: TabBarThemeData(
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w400),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      );

  // -- Mock Theme Colors --
  static const Color bgDeep = Color(0xFF0A1810);
  static const Color bgDark = Color(0xFF0D1F18);
  static const Color bgMid = Color(0xFF132B1E);
  static const Color bgCard = Color(0xFF0F2218);
  static const Color border = Color(0xFF1D3A2A);
  static const Color borderLight = Color(0xFF2A5438);
  
  static const Color accent = Color(0xFF1DE993);
  static const Color textPrimaryNew = Color(0xFFE8F5EE);
  static const Color textMuted = Color(0xFF7FC4A0);
  static const Color textFaint = Color(0xFF4A8060);
  
  static const Color danger = Color(0xFFFF7B7B);
  static const Color dangerBg = Color(0x1FCC3F3F); // rgba(204, 63, 63, 0.12)
  static const Color dangerBorder = Color(0x59CC3F3F); // rgba(204, 63, 63, 0.35)

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.dmSans().fontFamily,
        scaffoldBackgroundColor: bgDeep,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: danger,
          surface: bgDark,
          onPrimary: bgDeep,
          onSecondary: Colors.white,
          onSurface: textPrimaryNew,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: bgDark,
          foregroundColor: textPrimaryNew,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.dmSans(
            fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryNew),
          iconTheme: const IconThemeData(color: textPrimaryNew),
        ),
        cardTheme: CardThemeData(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: borderLight, width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: bgDeep,
          selectedItemColor: accent,
          unselectedItemColor: textFaint,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: bgDeep,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
            textStyle: GoogleFonts.dmSans(
              fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent, width: 2),
          ),
          labelStyle: GoogleFonts.dmSans(color: textMuted),
          prefixIconColor: accent,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerColor: border,
      );
}
