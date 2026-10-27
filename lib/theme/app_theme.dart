import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Apple Minimalist Aesthetic - Dark Palette (OLED Black, Space Gray, Pure Accents)
  static const Color nightObsidian = Color(0xFF000000); // Apple Pure OLED Black
  static const Color cardSurface = Color(0xFF161618);   // Apple Space Gray System Background
  static const Color cardBorder = Color(0xFF2C2C2E);    // Apple System Fill / Hairline Separator
  static const Color brandCoral = Color(0xFF0071E3);    // Apple Signature Blue Accent (#0071E3)
  static const Color electricPink = Color(0xFFFF2D55);  // Apple System Pink
  static const Color neonEmerald = Color(0xFF34C759);   // Apple System Green
  static const Color lagosYellow = Color(0xFFFFD60A);   // Apple System Yellow
  static const Color skyCyan = Color(0xFF32ADE6);       // Apple System Teal / Cyan
  static const Color purpleRoyal = Color(0xFFAF52DE);   // Apple System Purple
  static const Color darkShimmer = Color(0xFF1C1C1E);   // Apple Secondary System Background
  static const Color textMuted = Color(0xFF86868B);     // Apple San Francisco Body Gray (#86868B)
  static const Color textLight = Color(0xFFF5F5F7);     // Apple High-Contrast White-Gray (#F5F5F7)

  // Apple Minimalist Aesthetic - Light Palette (Pure White, Crisp Gray, Graphite Text)
  static const Color lightBg = Color(0xFFF5F5F7);        // Apple System Gray 6 Background
  static const Color lightCardSurface = Colors.white;   // Apple Pure White Card Surface
  static const Color lightCardBorder = Color(0xFFE5E5EA);// Apple Light Hairline Separator
  static const Color textDark = Color(0xFF1D1D1F);       // Apple San Francisco Dark Graphite (#1D1D1F)

  // Dynamic Theme Helpers
  static Color getCardSurface(bool isDark) => isDark ? cardSurface : lightCardSurface;
  static Color getCardBorder(bool isDark) => isDark ? cardBorder : lightCardBorder;
  static Color getTextColor(bool isDark) => isDark ? Colors.white : textDark;
  static Color getSubtextColor(bool isDark) => isDark ? textMuted : const Color(0xFF86868B);
  static Color getSecondarySurface(bool isDark) => isDark ? darkShimmer : const Color(0xFFF2F2F7);
  static List<BoxShadow>? getCardShadow(bool isDark) => isDark ? null : const [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // SparkSync Star Rank Colors (Apple Minimalist Tuned)
  static const Color rankNovice = Color(0xFF8E8E93);
  static const Color rankAmateur = Color(0xFFB08359);
  static const Color rankSenior = Color(0xFFC7C7CC);
  static const Color rankMaster = Color(0xFFFFD60A);
  static const Color rankProfessional = Color(0xFFFF375F);
  static const Color rankExpert = Color(0xFF64D2FF);
  static const Color rankVeteran = Color(0xFFFF9F0A);
  static const Color rankUltimate = Color(0xFFBF5AF2);

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

  /// Apple Minimalist Dark Theme
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
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textLight,
        displayColor: textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: nightObsidian,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 0.5),
        ),
      ),
      dividerColor: cardBorder,
    );
  }

  /// Apple Minimalist Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: brandCoral,
      colorScheme: const ColorScheme.light(
        primary: brandCoral,
        secondary: neonEmerald,
        surface: lightCardSurface,
        tertiary: lagosYellow,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightCardBorder, width: 0.5),
        ),
      ),
      dividerColor: lightCardBorder,
    );
  }
}
