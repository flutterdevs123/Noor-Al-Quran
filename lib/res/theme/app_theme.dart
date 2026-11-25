import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import 'app_colors.dart';

/// Custom semantic color extension attached to [ThemeData].
/// Screens access these via `context.appColors` without checking brightness manually.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color cardBackground;
  final Color elevatedCardBackground;
  final Color mushafPaper;
  final Color mushafBorder;
  final Color quranArabicText;
  final Color urduTranslationText;
  final Color textSecondary;
  final Color textTertiary;
  final Color onHeroPrimary;
  final Color onHeroSecondary;
  final Color onHeroMuted;
  final Color border;
  final Color divider;
  final Color patternStroke;
  final Color ayahHighlight;
  final Color ayahBadge;
  final Color sajdahMarker;
  final Color activePrayerBackground;
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color info;
  final Color infoContainer;
  final Color tilawatCorrect;
  final Color tilawatCorrectBg;
  final Color tilawatWrong;
  final Color tilawatWrongBg;
  final Color tilawatSkipped;
  final Color tilawatSkippedBg;
  final Color tilawatExtra;
  final Color tilawatExtraBg;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final LinearGradient heroGradient;
  final LinearGradient goldGradient;
  final LinearGradient shareCardGradient;

  const AppSemanticColors({
    required this.cardBackground,
    required this.elevatedCardBackground,
    required this.mushafPaper,
    required this.mushafBorder,
    required this.quranArabicText,
    required this.urduTranslationText,
    required this.textSecondary,
    required this.textTertiary,
    required this.onHeroPrimary,
    required this.onHeroSecondary,
    required this.onHeroMuted,
    required this.border,
    required this.divider,
    required this.patternStroke,
    required this.ayahHighlight,
    required this.ayahBadge,
    required this.sajdahMarker,
    required this.activePrayerBackground,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.info,
    required this.infoContainer,
    required this.tilawatCorrect,
    required this.tilawatCorrectBg,
    required this.tilawatWrong,
    required this.tilawatWrongBg,
    required this.tilawatSkipped,
    required this.tilawatSkippedBg,
    required this.tilawatExtra,
    required this.tilawatExtraBg,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.heroGradient,
    required this.goldGradient,
    required this.shareCardGradient,
  });

  static const AppSemanticColors light = AppSemanticColors(
    cardBackground: AppColors.cardLight,
    elevatedCardBackground: AppColors.elevatedCardLight,
    mushafPaper: AppColors.mushafPaperLight,
    mushafBorder: AppColors.mushafBorderLight,
    quranArabicText: AppColors.quranArabicLight,
    urduTranslationText: AppColors.urduTranslationLight,
    textSecondary: AppColors.textSecondaryLight,
    textTertiary: AppColors.textTertiaryLight,
    onHeroPrimary: AppColors.onHeroPrimary,
    onHeroSecondary: AppColors.onHeroSecondary,
    onHeroMuted: AppColors.onHeroMuted,
    border: AppColors.borderLight,
    divider: AppColors.dividerLight,
    patternStroke: AppColors.patternStrokeLight,
    ayahHighlight: AppColors.ayahHighlightLight,
    ayahBadge: AppColors.ayahBadgeLight,
    sajdahMarker: AppColors.sajdahMarkerLight,
    activePrayerBackground: AppColors.activePrayerBgLight,
    success: AppColors.successLight,
    successContainer: AppColors.successContainerLight,
    warning: AppColors.warningLight,
    warningContainer: AppColors.warningContainerLight,
    info: AppColors.infoLight,
    infoContainer: AppColors.infoContainerLight,
    tilawatCorrect: AppColors.tilawatCorrectLight,
    tilawatCorrectBg: AppColors.tilawatCorrectBgLight,
    tilawatWrong: AppColors.tilawatWrongLight,
    tilawatWrongBg: AppColors.tilawatWrongBgLight,
    tilawatSkipped: AppColors.tilawatSkippedLight,
    tilawatSkippedBg: AppColors.tilawatSkippedBgLight,
    tilawatExtra: AppColors.tilawatExtraLight,
    tilawatExtraBg: AppColors.tilawatExtraBgLight,
    shimmerBase: AppColors.shimmerBaseLight,
    shimmerHighlight: AppColors.shimmerHighlightLight,
    heroGradient: AppColors.primaryGradientLight,
    goldGradient: AppColors.goldAccentGradient,
    shareCardGradient: AppColors.shareCardGradient,
  );

  static const AppSemanticColors dark = AppSemanticColors(
    cardBackground: AppColors.cardDark,
    elevatedCardBackground: AppColors.elevatedCardDark,
    mushafPaper: AppColors.mushafPaperDark,
    mushafBorder: AppColors.mushafBorderDark,
    quranArabicText: AppColors.quranArabicDark,
    urduTranslationText: AppColors.urduTranslationDark,
    textSecondary: AppColors.textSecondaryDark,
    textTertiary: AppColors.textTertiaryDark,
    onHeroPrimary: AppColors.onHeroPrimary,
    onHeroSecondary: AppColors.onHeroSecondary,
    onHeroMuted: AppColors.onHeroMuted,
    border: AppColors.borderDark,
    divider: AppColors.dividerDark,
    patternStroke: AppColors.patternStrokeDark,
    ayahHighlight: AppColors.ayahHighlightDark,
    ayahBadge: AppColors.ayahBadgeDark,
    sajdahMarker: AppColors.sajdahMarkerDark,
    activePrayerBackground: AppColors.activePrayerBgDark,
    success: AppColors.successDark,
    successContainer: AppColors.successContainerDark,
    warning: AppColors.warningDark,
    warningContainer: AppColors.warningContainerDark,
    info: AppColors.infoDark,
    infoContainer: AppColors.infoContainerDark,
    tilawatCorrect: AppColors.tilawatCorrectDark,
    tilawatCorrectBg: AppColors.tilawatCorrectBgDark,
    tilawatWrong: AppColors.tilawatWrongDark,
    tilawatWrongBg: AppColors.tilawatWrongBgDark,
    tilawatSkipped: AppColors.tilawatSkippedDark,
    tilawatSkippedBg: AppColors.tilawatSkippedBgDark,
    tilawatExtra: AppColors.tilawatExtraDark,
    tilawatExtraBg: AppColors.tilawatExtraBgDark,
    shimmerBase: AppColors.shimmerBaseDark,
    shimmerHighlight: AppColors.shimmerHighlightDark,
    heroGradient: AppColors.primaryGradientDark,
    goldGradient: AppColors.goldAccentGradient,
    shareCardGradient: AppColors.shareCardGradient,
  );

  @override
  AppSemanticColors copyWith({
    Color? cardBackground,
    Color? elevatedCardBackground,
    Color? mushafPaper,
    Color? mushafBorder,
    Color? quranArabicText,
    Color? urduTranslationText,
    Color? textSecondary,
    Color? textTertiary,
    Color? onHeroPrimary,
    Color? onHeroSecondary,
    Color? onHeroMuted,
    Color? border,
    Color? divider,
    Color? patternStroke,
    Color? ayahHighlight,
    Color? ayahBadge,
    Color? sajdahMarker,
    Color? activePrayerBackground,
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? info,
    Color? infoContainer,
    Color? tilawatCorrect,
    Color? tilawatCorrectBg,
    Color? tilawatWrong,
    Color? tilawatWrongBg,
    Color? tilawatSkipped,
    Color? tilawatSkippedBg,
    Color? tilawatExtra,
    Color? tilawatExtraBg,
    Color? shimmerBase,
    Color? shimmerHighlight,
    LinearGradient? heroGradient,
    LinearGradient? goldGradient,
    LinearGradient? shareCardGradient,
  }) {
    return AppSemanticColors(
      cardBackground: cardBackground ?? this.cardBackground,
      elevatedCardBackground: elevatedCardBackground ?? this.elevatedCardBackground,
      mushafPaper: mushafPaper ?? this.mushafPaper,
      mushafBorder: mushafBorder ?? this.mushafBorder,
      quranArabicText: quranArabicText ?? this.quranArabicText,
      urduTranslationText: urduTranslationText ?? this.urduTranslationText,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      onHeroPrimary: onHeroPrimary ?? this.onHeroPrimary,
      onHeroSecondary: onHeroSecondary ?? this.onHeroSecondary,
      onHeroMuted: onHeroMuted ?? this.onHeroMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      patternStroke: patternStroke ?? this.patternStroke,
      ayahHighlight: ayahHighlight ?? this.ayahHighlight,
      ayahBadge: ayahBadge ?? this.ayahBadge,
      sajdahMarker: sajdahMarker ?? this.sajdahMarker,
      activePrayerBackground: activePrayerBackground ?? this.activePrayerBackground,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      tilawatCorrect: tilawatCorrect ?? this.tilawatCorrect,
      tilawatCorrectBg: tilawatCorrectBg ?? this.tilawatCorrectBg,
      tilawatWrong: tilawatWrong ?? this.tilawatWrong,
      tilawatWrongBg: tilawatWrongBg ?? this.tilawatWrongBg,
      tilawatSkipped: tilawatSkipped ?? this.tilawatSkipped,
      tilawatSkippedBg: tilawatSkippedBg ?? this.tilawatSkippedBg,
      tilawatExtra: tilawatExtra ?? this.tilawatExtra,
      tilawatExtraBg: tilawatExtraBg ?? this.tilawatExtraBg,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      heroGradient: heroGradient ?? this.heroGradient,
      goldGradient: goldGradient ?? this.goldGradient,
      shareCardGradient: shareCardGradient ?? this.shareCardGradient,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      elevatedCardBackground: Color.lerp(elevatedCardBackground, other.elevatedCardBackground, t)!,
      mushafPaper: Color.lerp(mushafPaper, other.mushafPaper, t)!,
      mushafBorder: Color.lerp(mushafBorder, other.mushafBorder, t)!,
      quranArabicText: Color.lerp(quranArabicText, other.quranArabicText, t)!,
      urduTranslationText: Color.lerp(urduTranslationText, other.urduTranslationText, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      onHeroPrimary: Color.lerp(onHeroPrimary, other.onHeroPrimary, t)!,
      onHeroSecondary: Color.lerp(onHeroSecondary, other.onHeroSecondary, t)!,
      onHeroMuted: Color.lerp(onHeroMuted, other.onHeroMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      patternStroke: Color.lerp(patternStroke, other.patternStroke, t)!,
      ayahHighlight: Color.lerp(ayahHighlight, other.ayahHighlight, t)!,
      ayahBadge: Color.lerp(ayahBadge, other.ayahBadge, t)!,
      sajdahMarker: Color.lerp(sajdahMarker, other.sajdahMarker, t)!,
      activePrayerBackground: Color.lerp(activePrayerBackground, other.activePrayerBackground, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      tilawatCorrect: Color.lerp(tilawatCorrect, other.tilawatCorrect, t)!,
      tilawatCorrectBg: Color.lerp(tilawatCorrectBg, other.tilawatCorrectBg, t)!,
      tilawatWrong: Color.lerp(tilawatWrong, other.tilawatWrong, t)!,
      tilawatWrongBg: Color.lerp(tilawatWrongBg, other.tilawatWrongBg, t)!,
      tilawatSkipped: Color.lerp(tilawatSkipped, other.tilawatSkipped, t)!,
      tilawatSkippedBg: Color.lerp(tilawatSkippedBg, other.tilawatSkippedBg, t)!,
      tilawatExtra: Color.lerp(tilawatExtra, other.tilawatExtra, t)!,
      tilawatExtraBg: Color.lerp(tilawatExtraBg, other.tilawatExtraBg, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      heroGradient: LinearGradient.lerp(heroGradient, other.heroGradient, t)!,
      goldGradient: LinearGradient.lerp(goldGradient, other.goldGradient, t)!,
      shareCardGradient: LinearGradient.lerp(shareCardGradient, other.shareCardGradient, t)!,
    );
  }
}

/// Convenient BuildContext accessor for custom semantic colors and ColorScheme.
extension AppThemeContextExtension on BuildContext {
  AppSemanticColors get appColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

/// Builds Material 3 Light and Dark themes supporting both English (LTR) & Urdu (RTL).
class AppTheme {
  AppTheme._();

  static ThemeData lightTheme({bool isUrdu = false}) =>
      _buildTheme(Brightness.light, isUrdu: isUrdu);

  static ThemeData darkTheme({bool isUrdu = false}) =>
      _buildTheme(Brightness.dark, isUrdu: isUrdu);

  static ThemeData _buildTheme(Brightness brightness, {required bool isUrdu}) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme colorScheme = isDark
        ? const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,
      secondary: AppColors.accentDark,
      onSecondary: AppColors.onAccentDark,
      secondaryContainer: AppColors.accentContainerDark,
      onSecondaryContainer: AppColors.onAccentContainerDark,
      tertiary: AppColors.infoDark,
      onTertiary: AppColors.onInfoDark,
      tertiaryContainer: AppColors.infoContainerDark,
      onTertiaryContainer: AppColors.infoDark,
      error: AppColors.errorDark,
      onError: AppColors.onErrorDark,
      errorContainer: AppColors.errorContainerDark,
      onErrorContainer: AppColors.errorDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.dividerDark,
      shadow: AppColors.shadowDark,
      scrim: AppColors.shadowDark,
      inverseSurface: AppColors.surfaceLight,
      onInverseSurface: AppColors.textPrimaryLight,
      inversePrimary: AppColors.primaryLight,
    )
        : const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryLight,
      onPrimary: AppColors.onPrimaryLight,
      primaryContainer: AppColors.primaryContainerLight,
      onPrimaryContainer: AppColors.onPrimaryContainerLight,
      secondary: AppColors.accentLight,
      onSecondary: AppColors.onAccentLight,
      secondaryContainer: AppColors.accentContainerLight,
      onSecondaryContainer: AppColors.onAccentContainerLight,
      tertiary: AppColors.infoLight,
      onTertiary: AppColors.onInfoLight,
      tertiaryContainer: AppColors.infoContainerLight,
      onTertiaryContainer: AppColors.infoLight,
      error: AppColors.errorLight,
      onError: AppColors.onErrorLight,
      errorContainer: AppColors.errorContainerLight,
      onErrorContainer: AppColors.errorLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: AppColors.borderLight,
      outlineVariant: AppColors.dividerLight,
      shadow: AppColors.shadowLight,
      scrim: AppColors.shadowLight,
      inverseSurface: AppColors.surfaceDark,
      onInverseSurface: AppColors.textPrimaryDark,
      inversePrimary: AppColors.primaryDark,
    );

    final Color scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final Color cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final Color borderClr = isDark ? AppColors.borderDark : AppColors.borderLight;
    final Color dividerClr = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final Color textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final TextTheme appTextTheme = isUrdu
        ? _buildUrduTextTheme(textPrimary, textSecondary)
        : _buildEnglishTextTheme(textPrimary, textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: appTextTheme,
      extensions: <ThemeExtension<dynamic>>[
        isDark ? AppSemanticColors.dark : AppSemanticColors.light,
      ],

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: scaffoldBg,
        foregroundColor: textPrimary,
        surfaceTintColor: AppColors.transparent,
        iconTheme: IconThemeData(color: textPrimary, size: 22),
        titleTextStyle: appTextTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(statusBarColor: AppColors.transparent)
            : SystemUiOverlayStyle.dark.copyWith(statusBarColor: AppColors.transparent),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: isDark ? 0 : 1,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: AppColors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderClr, width: 1),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: borderClr,
          disabledForegroundColor: textSecondary,
          elevation: 0,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: appTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.2),
          minimumSize: const Size(64, 48),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: appTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: appTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 14),
        hintStyle: appTextTheme.bodyMedium?.copyWith(color: textSecondary),
        labelStyle: appTextTheme.bodyMedium?.copyWith(color: textSecondary),
        errorStyle: appTextTheme.bodySmall?.copyWith(color: colorScheme.error),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderClr, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderClr, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.6),
        ),
      ),

      // Filter & Choice Chips Theme
      chipTheme: ChipThemeData(
        backgroundColor: cardBg,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: borderClr,
        labelStyle: appTextTheme.labelMedium?.copyWith(color: textPrimary),
        secondaryLabelStyle: appTextTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: borderClr, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      // Material 3 NavigationBar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardBg,
        indicatorColor: colorScheme.primaryContainer,
        surfaceTintColor: AppColors.transparent,
        elevation: 3,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onPrimaryContainer, size: 24);
          }
          return IconThemeData(color: textSecondary, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appTextTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            );
          }
          return appTextTheme.labelSmall?.copyWith(color: textSecondary);
        }),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: dividerClr,
        thickness: 1,
        space: 1,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderClr, width: 1),
        ),
        titleTextStyle: appTextTheme.titleLarge?.copyWith(color: textPrimary),
        contentTextStyle: appTextTheme.bodyMedium?.copyWith(color: textSecondary),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: AppColors.transparent,
        showDragHandle: true,
        dragHandleColor: borderClr,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.onPrimary;
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return borderClr;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primaryContainer,
        thumbColor: colorScheme.secondary,
        overlayColor: colorScheme.secondary.withValues(alpha: 0.16),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
        circularTrackColor: colorScheme.primaryContainer,
      ),
    );
  }

  /// Premium Plus Jakarta Sans TextTheme for sharp, modern English legibility.
  static TextTheme _buildEnglishTextTheme(Color primary, Color secondary) {
    final TextTheme base = GoogleFonts.plusJakartaSansTextTheme();

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 32,
        height: 1.25,
        letterSpacing: -0.4,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 28,
        height: 1.25,
        letterSpacing: -0.3,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 24,
        height: 1.3,
        letterSpacing: -0.2,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 22,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 17,
        height: 1.4,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 15,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12.5,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11.5,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
    );
  }

  /// Bundled Noto Nastaliq Urdu TextTheme with zero letter-spacing (preserves cursive joining)
  /// and generous line heights so Urdu diacritics and dots never clip.
  static TextTheme _buildUrduTextTheme(Color primary, Color secondary) {
    final TextTheme base = GoogleFonts.notoNastaliqUrduTextTheme();

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 30,
        height: 1.85,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 26,
        height: 1.85,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 22,
        height: 1.8,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 20,
        height: 1.8,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 18,
        height: 1.75,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 17,
        height: 1.75,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 16,
        height: 1.75,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 15,
        height: 1.75,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        height: 1.7,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.85,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.8,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12.5,
        height: 1.75,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        height: 1.7,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        height: 1.7,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11.5,
        height: 1.65,
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
    );
  }

  /// Dedicated helper text style for Uthmani Quran Arabic script.
  static TextStyle quranTextStyle({
    required BuildContext context,
    double fontSize = AppConstants.defaultQuranFontSize,
    double height = 2.1,
  }) {
    return TextStyle(
      fontFamily: AppConstants.quranUthmaniFontFamily,
      fontSize: fontSize,
      height: height,
      letterSpacing: 0,
      color: context.appColors.quranArabicText,
    );
  }

  /// Dedicated helper text style for Arabic Hadith & Bismillah text using bundled Amiri.
  static TextStyle arabicHadithTextStyle({
    required BuildContext context,
    double fontSize = 22.0,
    double height = 1.9,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      height: height,
      letterSpacing: 0,
      fontWeight: FontWeight.w700,
      color: context.appColors.quranArabicText,
    ).copyWith(
      fontFamilyFallback: const <String>[
        AppConstants.quranUthmaniFontFamily,
      ],
    );
  }
}