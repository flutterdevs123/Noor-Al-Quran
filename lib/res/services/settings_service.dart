import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

/// Global persistent settings service backed by [GetStorage].
/// Manages theme mode, active locale (English / Urdu), Hijri offset, and local caches.
class SettingsService extends GetxService {
  static const String _boxName = 'iqra_app_settings';

  // Supported Locales
  static const Locale englishLocale = Locale('en', 'US');
  static const Locale urduLocale = Locale('ur', 'PK');

  // Storage Keys
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyUseUrduNumerals = 'use_urdu_numerals';
  static const String _keyShowUrduTranslation = 'show_urdu_translation';
  static const String _keyQuranFontSize = 'quran_font_size';
  static const String _keyTranslationFontSize = 'translation_font_size';
  static const String _keyHijriDayOffset = 'hijri_day_offset';
  static const String _keyLastReadSurah = 'last_read_surah';
  static const String _keyLastReadAyah = 'last_read_ayah';
  static const String _keyLastReadPage = 'last_read_page';
  static const String _keyLastReadOffset = 'last_read_offset';
  static const String _keyLastReadTimestamp = 'last_read_timestamp';
  static const String _keyTilawatNotifyMe = 'tilawat_notify_me';
  static const String _keyDailyFeedCacheDate = 'daily_feed_cache_date';
  static const String _keyDailyFeedCacheJson = 'daily_feed_cache_json';

  late final GetStorage _box;

  // Reactive User Preferences
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final Rx<Locale> currentLocale = englishLocale.obs;
  final RxBool useUrduNumerals = false.obs;
  final RxBool showUrduTranslation = true.obs;
  final RxDouble quranFontSize = AppConstants.defaultQuranFontSize.obs;
  final RxDouble translationFontSize = AppConstants.defaultTranslationFontSize.obs;
  final RxInt hijriDayOffset = 0.obs;
  final RxBool tilawatNotifyMe = false.obs;

  // Reactive Last Read State
  final RxInt lastReadSurah = 1.obs;
  final RxInt lastReadAyah = 1.obs;
  final RxInt lastReadPage = 1.obs;
  final RxDouble lastReadOffset = 0.0.obs;
  final RxInt lastReadTimestamp = 0.obs;

  bool get isUrdu => currentLocale.value.languageCode == 'ur';

  /// Initializes [GetStorage] container and loads persisted values into reactive fields.
  Future<SettingsService> init() async {
    await GetStorage.init(_boxName);
    _box = GetStorage(_boxName);
    _loadFromStorage();
    return this;
  }

  void _loadFromStorage() {
    final String savedTheme = _box.read<String>(_keyThemeMode) ?? 'system';
    themeMode.value = _parseThemeMode(savedTheme);

    final String savedLang = _box.read<String>(_keyLanguageCode) ?? 'en';
    currentLocale.value = savedLang == 'ur' ? urduLocale : englishLocale;

    useUrduNumerals.value = _box.read<bool>(_keyUseUrduNumerals) ?? (savedLang == 'ur');
    showUrduTranslation.value = _box.read<bool>(_keyShowUrduTranslation) ?? true;

    quranFontSize.value = (_box.read<num>(_keyQuranFontSize)?.toDouble() ??
        AppConstants.defaultQuranFontSize)
        .clamp(AppConstants.minQuranFontSize, AppConstants.maxQuranFontSize);

    translationFontSize.value = (_box.read<num>(_keyTranslationFontSize)?.toDouble() ??
        AppConstants.defaultTranslationFontSize)
        .clamp(AppConstants.minTranslationFontSize, AppConstants.maxTranslationFontSize);

    hijriDayOffset.value = (_box.read<int>(_keyHijriDayOffset) ?? 0).clamp(-2, 2);

    lastReadSurah.value = _box.read<int>(_keyLastReadSurah) ?? 1;
    lastReadAyah.value = _box.read<int>(_keyLastReadAyah) ?? 1;
    lastReadPage.value = _box.read<int>(_keyLastReadPage) ?? 1;
    lastReadOffset.value = _box.read<num>(_keyLastReadOffset)?.toDouble() ?? 0.0;
    lastReadTimestamp.value = _box.read<int>(_keyLastReadTimestamp) ?? 0;

    tilawatNotifyMe.value = _box.read<bool>(_keyTilawatNotifyMe) ?? false;
  }

  /// Verifies read/write access to local storage during app startup.
  bool verifyStorageIntegrity() {
    const String probeKey = '_health_probe';
    _box.write(probeKey, true);
    final bool ok = _box.read<bool>(probeKey) ?? false;
    _box.remove(probeKey);
    return ok;
  }

  // ===========================================================================
  // THEME, LANGUAGE & CALENDAR SETTERS
  // ===========================================================================
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _box.write(_keyThemeMode, mode.name);
    Get.changeThemeMode(mode);
  }

  Future<void> toggleLightDarkTheme(bool isCurrentlyDark) async {
    await setThemeMode(isCurrentlyDark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setLocale(Locale locale) async {
    currentLocale.value = locale;
    await _box.write(_keyLanguageCode, locale.languageCode);
    await Get.updateLocale(locale);
  }

  Future<void> toggleLanguage() async {
    await setLocale(isUrdu ? englishLocale : urduLocale);
  }

  Future<void> setHijriDayOffset(int offset) async {
    final int clamped = offset.clamp(-2, 2);
    hijriDayOffset.value = clamped;
    await _box.write(_keyHijriDayOffset, clamped);
    // Invalidate daily feed cache so occasion-aware content refreshes for new Hijri date
    await _box.remove(_keyDailyFeedCacheDate);
  }

  Future<void> setUseUrduNumerals(bool value) async {
    useUrduNumerals.value = value;
    await _box.write(_keyUseUrduNumerals, value);
  }

  Future<void> setShowUrduTranslation(bool value) async {
    showUrduTranslation.value = value;
    await _box.write(_keyShowUrduTranslation, value);
  }

  Future<void> setQuranFontSize(double size) async {
    final double clamped = size.clamp(
      AppConstants.minQuranFontSize,
      AppConstants.maxQuranFontSize,
    );
    quranFontSize.value = clamped;
    await _box.write(_keyQuranFontSize, clamped);
  }

  Future<void> setTranslationFontSize(double size) async {
    final double clamped = size.clamp(
      AppConstants.minTranslationFontSize,
      AppConstants.maxTranslationFontSize,
    );
    translationFontSize.value = clamped;
    await _box.write(_keyTranslationFontSize, clamped);
  }

  // ===========================================================================
  // DAILY LIVE FEED CACHE (By Date Key)
  // ===========================================================================
  String? readCachedDailyFeedJson(String dateKey) {
    final String? cachedDate = _box.read<String>(_keyDailyFeedCacheDate);
    if (cachedDate != dateKey) return null;
    return _box.read<String>(_keyDailyFeedCacheJson);
  }

  String? readAnyCachedDailyFeedJson() {
    return _box.read<String>(_keyDailyFeedCacheJson);
  }

  Future<void> saveCachedDailyFeedJson(String dateKey, String jsonPayload) async {
    await _box.write(_keyDailyFeedCacheDate, dateKey);
    await _box.write(_keyDailyFeedCacheJson, jsonPayload);
  }

  // ===========================================================================
  // LAST READ & FEATURE FLAGS
  // ===========================================================================
  Future<void> saveLastReadPosition({
    required int surahId,
    required int ayahNumber,
    int pageNumber = 1,
    double scrollOffset = 0.0,
  }) async {
    final int nowMillis = DateTime.now().millisecondsSinceEpoch;
    lastReadSurah.value = surahId;
    lastReadAyah.value = ayahNumber;
    lastReadPage.value = pageNumber;
    lastReadOffset.value = scrollOffset;
    lastReadTimestamp.value = nowMillis;

    await _box.write(_keyLastReadSurah, surahId);
    await _box.write(_keyLastReadAyah, ayahNumber);
    await _box.write(_keyLastReadPage, pageNumber);
    await _box.write(_keyLastReadOffset, scrollOffset);
    await _box.write(_keyLastReadTimestamp, nowMillis);
  }

  bool get hasLastReadProgress => lastReadTimestamp.value > 0;

  Future<void> setTilawatNotifyMe(bool value) async {
    tilawatNotifyMe.value = value;
    await _box.write(_keyTilawatNotifyMe, value);
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}