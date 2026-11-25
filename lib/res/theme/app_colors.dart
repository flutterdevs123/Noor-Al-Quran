import 'package:flutter/material.dart';

/// Centralized color palette for the entire application.
/// No hex color values are permitted outside this file.
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. CORE BRAND COLORS (Deep Islamic Emerald & Royal Gold)
  // ===========================================================================
  static const Color primaryLight = Color(0xFF0F5132); // Deep Emerald Green
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFD1E7DD);
  static const Color onPrimaryContainerLight = Color(0xFF052E1B);

  static const Color primaryDark = Color(0xFF4ADE80); // Luminous Emerald for Dark UI
  static const Color onPrimaryDark = Color(0xFF042616);
  static const Color primaryContainerDark = Color(0xFF14452F);
  static const Color onPrimaryContainerDark = Color(0xFFD1FAE5);

  static const Color accentLight = Color(0xFFC9A227); // Royal Islamic Gold
  static const Color onAccentLight = Color(0xFF1F1700);
  static const Color accentContainerLight = Color(0xFFF6ECC9);
  static const Color onAccentContainerLight = Color(0xFF3A2C00);

  static const Color accentDark = Color(0xFFE0B93B); // Warm Gold for Dark UI
  static const Color onAccentDark = Color(0xFF241B00);
  static const Color accentContainerDark = Color(0xFF473706);
  static const Color onAccentContainerDark = Color(0xFFFAEFCA);

  // High-contrast foreground colors specifically for dark emerald hero & share cards
  static const Color onHeroPrimary = Color(0xFFFAF6EC);
  static const Color onHeroSecondary = Color(0xFFE0B93B);
  static const Color onHeroMuted = Color(0xFFD8E6DF);

  // ===========================================================================
  // 2. BACKGROUNDS, SURFACES & MUSHAF READING PAPER
  // ===========================================================================
  // Light Mode (Warm Parchment Cream)
  static const Color backgroundLight = Color(0xFFFAF6EC);
  static const Color surfaceLight = Color(0xFFFFFDF8);
  static const Color surfaceVariantLight = Color(0xFFF1EBDC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color elevatedCardLight = Color(0xFFF7F2E4);
  static const Color mushafPaperLight = Color(0xFFFDF9EE);
  static const Color mushafBorderLight = Color(0xFFD8C99B);

  // Dark Mode (Deep Forest Night)
  static const Color backgroundDark = Color(0xFF0B1F17);
  static const Color surfaceDark = Color(0xFF102A20);
  static const Color surfaceVariantDark = Color(0xFF17382B);
  static const Color cardDark = Color(0xFF133024);
  static const Color elevatedCardDark = Color(0xFF193D2E);
  static const Color mushafPaperDark = Color(0xFF0E251C);
  static const Color mushafBorderDark = Color(0xFF3A4D3F);

  // ===========================================================================
  // 3. TEXT & TYPOGRAPHY COLORS
  // ===========================================================================
  static const Color textPrimaryLight = Color(0xFF14241C);
  static const Color textSecondaryLight = Color(0xFF43574D);
  static const Color textTertiaryLight = Color(0xFF6E8278);
  static const Color textDisabledLight = Color(0xFF9EB0A7);
  static const Color quranArabicLight = Color(0xFF0D1B14);
  static const Color urduTranslationLight = Color(0xFF24382E);

  static const Color textPrimaryDark = Color(0xFFF5F0E1); // Soft Cream Text
  static const Color textSecondaryDark = Color(0xFFC7C2B2);
  static const Color textTertiaryDark = Color(0xFF939B94);
  static const Color textDisabledDark = Color(0xFF5B6B63);
  static const Color quranArabicDark = Color(0xFFFAF6EC);
  static const Color urduTranslationDark = Color(0xFFDAD4C4);

  // ===========================================================================
  // 4. SEMANTIC & STATUS COLORS (Alerts, Validation & Tilawat Word States)
  // ===========================================================================
  static const Color successLight = Color(0xFF15803D);
  static const Color onSuccessLight = Color(0xFFFFFFFF);
  static const Color successContainerLight = Color(0xFFDCFCE7);

  static const Color successDark = Color(0xFF4ADE80);
  static const Color onSuccessDark = Color(0xFF052E16);
  static const Color successContainerDark = Color(0xFF14532D);

  static const Color errorLight = Color(0xFFB91C1C);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color errorContainerLight = Color(0xFFFEE2E2);

  static const Color errorDark = Color(0xFFF87171);
  static const Color onErrorDark = Color(0xFF450A0A);
  static const Color errorContainerDark = Color(0xFF7F1D1D);

  static const Color warningLight = Color(0xFFB45309);
  static const Color onWarningLight = Color(0xFFFFFFFF);
  static const Color warningContainerLight = Color(0xFFFEF3C7);

  static const Color warningDark = Color(0xFFFBBF24);
  static const Color onWarningDark = Color(0xFF451A03);
  static const Color warningContainerDark = Color(0xFF78350F);

  static const Color infoLight = Color(0xFF0369A1);
  static const Color onInfoLight = Color(0xFFFFFFFF);
  static const Color infoContainerLight = Color(0xFFE0F2FE);

  static const Color infoDark = Color(0xFF38BDF8);
  static const Color onInfoDark = Color(0xFF082F49);
  static const Color infoContainerDark = Color(0xFF0C4A6E);

  // Tilawat Word-Level Highlight Colors (Accessible foreground + soft background)
  static const Color tilawatCorrectLight = Color(0xFF15803D);
  static const Color tilawatCorrectBgLight = Color(0x2615803D);
  static const Color tilawatCorrectDark = Color(0xFF4ADE80);
  static const Color tilawatCorrectBgDark = Color(0x294ADE80);

  static const Color tilawatWrongLight = Color(0xFFB91C1C);
  static const Color tilawatWrongBgLight = Color(0x24B91C1C);
  static const Color tilawatWrongDark = Color(0xFFF87171);
  static const Color tilawatWrongBgDark = Color(0x29F87171);

  static const Color tilawatSkippedLight = Color(0xFFB45309);
  static const Color tilawatSkippedBgLight = Color(0x24B45309);
  static const Color tilawatSkippedDark = Color(0xFFFBBF24);
  static const Color tilawatSkippedBgDark = Color(0x29FBBF24);

  static const Color tilawatExtraLight = Color(0xFF7E22CE);
  static const Color tilawatExtraBgLight = Color(0x217E22CE);
  static const Color tilawatExtraDark = Color(0xFFC084FC);
  static const Color tilawatExtraBgDark = Color(0x29C084FC);

  // ===========================================================================
  // 5. ISLAMIC FEATURE-SPECIFIC COLORS (Quran, Audio, Prayer Times)
  // ===========================================================================
  static const Color ayahHighlightLight = Color(0x33C9A227);
  static const Color ayahHighlightDark = Color(0x33E0B93B);

  static const Color ayahBadgeLight = Color(0xFF0F5132);
  static const Color ayahBadgeDark = Color(0xFFE0B93B);
  static const Color sajdahMarkerLight = Color(0xFF9A3412);
  static const Color sajdahMarkerDark = Color(0xFFFB923C);

  static const Color prayerFajr = Color(0xFF2563EB);
  static const Color prayerSunrise = Color(0xFFD97706);
  static const Color prayerDhuhr = Color(0xFF0F5132);
  static const Color prayerAsr = Color(0xFF0D9488);
  static const Color prayerMaghrib = Color(0xFFC2410C);
  static const Color prayerIsha = Color(0xFF4338CA);

  static const Color activePrayerBgLight = Color(0xFFE6F4ED);
  static const Color activePrayerBgDark = Color(0xFF194231);

  // ===========================================================================
  // 6. BORDERS, DIVIDERS, GEOMETRIC PATTERNS & SHIMMERS
  // ===========================================================================
  static const Color borderLight = Color(0xFFE2D9C3);
  static const Color borderDark = Color(0xFF234738);

  static const Color dividerLight = Color(0xFFE8E0CD);
  static const Color dividerDark = Color(0xFF1D3D30);

  static const Color patternStrokeLight = Color(0x1F0F5132);
  static const Color patternStrokeDark = Color(0x24E0B93B);

  static const Color shimmerBaseLight = Color(0xFFEDE6D5);
  static const Color shimmerHighlightLight = Color(0xFFFAF6EC);
  static const Color shimmerBaseDark = Color(0xFF143326);
  static const Color shimmerHighlightDark = Color(0xFF1F4B39);

  static const Color shadowLight = Color(0x140F5132);
  static const Color shadowDark = Color(0x4D000000);
  static const Color transparent = Colors.transparent;

  // ===========================================================================
  // 7. GRADIENTS (Headers, Hero Cards & Shareable Ayah/Hadith Cards)
  // ===========================================================================
  static const LinearGradient primaryGradientLight = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: <Color>[Color(0xFF0F5132), Color(0xFF082C1B)],
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: <Color>[Color(0xFF164A33), Color(0xFF0D281D)],
  );

  static const LinearGradient goldAccentGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: <Color>[Color(0xFFE0B93B), Color(0xFFA17F1A)],
  );

  static const LinearGradient shareCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFF0F5132), Color(0xFF0B2E1E), Color(0xFF071D13)],
  );
}