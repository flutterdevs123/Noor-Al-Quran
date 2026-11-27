/// Central application-wide constants and feature flags.
/// App name must ONLY be defined here and referenced everywhere else.
class AppConstants {
  AppConstants._();

  // Application Identity (Defined exclusively here)
  static const String appName = 'Noor Al-Quran';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Font Family Identifiers
  static const String quranUthmaniFontFamily = 'KFGQPCUthmanTahaNaskh';
  static const String englishGoogleFont = 'Plus Jakarta Sans';
  static const String urduNastaliqGoogleFont = 'Noto Nastaliq Urdu';
  static const String arabicNaskhGoogleFont = 'Amiri';

  // Responsive Scaling Boundaries (Design base width: 375px)
  static const double designBaseWidth = 375.0;
  static const double minScaleFactor = 0.80;
  static const double maxScaleFactor = 1.40;
  static const double minSystemTextScale = 0.90;
  static const double maxSystemTextScale = 1.15;
  static const double maxTabletContentWidth = 600.0;

  // Quran Reader Font Size Bounds (User adjustable)
  static const double minQuranFontSize = 20.0;
  static const double maxQuranFontSize = 42.0;
  static const double defaultQuranFontSize = 28.0;
  static const double minTranslationFontSize = 14.0;
  static const double maxTranslationFontSize = 26.0;
  static const double defaultTranslationFontSize = 17.0;

  // Splash & Live Feed Timing Constants
  static const Duration splashDisplayDuration = Duration(seconds: 3);
  static const Duration liveFeedSlideInterval = Duration(seconds: 4);
  static const Duration liveFeedTransitionDuration = Duration(milliseconds: 550);

  // Default Fallback Coordinates (Makkah Al-Mukarramah) if GPS is unavailable
  static const double defaultLatitude = 21.4225;
  static const double defaultLongitude = 39.8262;

  // Feature Flags
  static const bool tilawatCheckerEnabled = false;

  // Data Integrity
  static const String quranBundleAssetPath = 'assets/data/quran_uthmani_ur.json';
  static const String expectedQuranBundleSha256 = 'REPLACE_WITH_VERIFIED_SHA256_HASH';

  // Routing Transition Duration
  static const Duration routeTransitionDuration = Duration(milliseconds: 200);
}