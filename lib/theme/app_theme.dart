import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vibrant Lagos-inspired luxury color palette
  static const Color nightObsidian = Color(0xFF090D16);
  static const Color cardSurface = Color(0xFF131926);
  static const Color cardBorder = Color(0xFF222C42);
  static const Color brandCoral = Color(0xFFFF4D6D);
  static const Color electricPink = Color(0xFFFF1B6B);
  static const Color neonEmerald = Color(0xFF00E676);
  static const Color lagosYellow = Color(0xFFFFD027);
  static const Color skyCyan = Color(0xFF00D4FF);
  static const Color purpleRoyal = Color(0xFF8A2BE2);
  static const Color darkShimmer = Color(0xFF1A2235);
  static const Color textMuted = Color(0xFF8A99B0);
  static const Color textLight = Color(0xFFF1F5F9);

  // SparkSync Star Rank Colors
  static const Color rankNovice = Color(0xFF8E8E93);
  static const Color rankAmateur = Color(0xFFCD7F32);
  static const Color rankSenior = Color(0xFFC0C0C0);
  static const Color rankMaster = Color(0xFFFFD700);
  static const Color rankProfessional = Color(0xFFE0115F);
  static const Color rankExpert = Color(0xFF00E5FF);
  static const Color rankVeteran = Color(0xFFFF5722);
  static const Color rankUltimate = Color(0xFFA855F7);

  static Color getRankColor(String rankName) {
    switch (rankName.toLowerCase()) {
      case 'novice':
        return rankNovice;
      case 'amateur':
        return rankAmateur;
      case 'senior':
        return rankSenior;
      case 'master':
        return rankMaster;
      case 'professional':
        return rankProfessional;
      case 'expert':
        return rankExpert;
      case 'veteran':
        return rankVeteran;
      case 'ultimate':
        return rankUltimate;
      default:
        return rankMaster;
    }
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: nightObsidian,
      primaryColor: brandCoral,
      colorScheme: const ColorScheme.dark(
        primary: brandCoral,
        secondary: neonEmerald,
        surface: cardSurface,
        tertiary: lagosYellow,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textLight,
        displayColor: textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
    );
  }
}
