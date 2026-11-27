
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/app_constants.dart';

/// Global persistent settings service backed by GetStorage.
class SettingsService extends GetxService {
  static const String _boxName = 'iqra_app_settings';

  // Supported Locales
  static const Locale englishLocale = Locale('en', 'US');
  static const Locale urduLocale = Locale('ur', 'PK');

  // Storage Keys
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyUseUrduNumerals = 'use_urdu_numerals';
  static const String _keyShowUrduTranslation =
      'show_urdu_translation';
  static const String _keyShowEnglishTranslation =
      'show_english_translation';
  static const String _keyIsMushaf16LineMode =
      'is_mushaf_16_line_mode';
  static const String _keyCleanArabicMarks = 'clean_arabic_marks';
  static const String _keyQuranFontSize = 'quran_font_size';
  static const String _keyQuranLineHeight = 'quran_line_height';
  static const String _keyTranslationFontSize =
      'translation_font_size';
  static const String _keyHijriDayOffset = 'hijri_day_offset';

  static const String _keyLastReadSurah = 'last_read_surah';
  static const String _keyLastReadAyah = 'last_read_ayah';
  static const String _keyLastReadPage = 'last_read_page';
  static const String _keyLastReadOffset = 'last_read_offset';
  static const String _keyLastReadTimestamp =
      'last_read_timestamp';

  static const String _keyBookmarkedAyahs = 'bookmarked_ayahs';
  static const String _keyTilawatNotifyMe = 'tilawat_notify_me';

  static const String _keyDailyFeedCacheDate =
      'daily_feed_cache_date';
  static const String _keyDailyFeedCacheJson =
      'daily_feed_cache_json';

  late final GetStorage _box;

  // Reactive User Preferences

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  final Rx<Locale> currentLocale = englishLocale.obs;

  final RxBool useUrduNumerals = false.obs;

  final RxBool showUrduTranslation = true.obs;

  final RxBool showEnglishTranslation = true.obs;

  final RxBool isMushaf16LineMode = true.obs;

  // Quranic Arabic marks should be preserved by default.
  // This preference must never be used to modify original Quran text.
  final RxBool cleanArabicMarks = false.obs;

  final RxDouble quranFontSize =
      AppConstants.defaultQuranFontSize.obs;

  final RxDouble quranLineHeight = 1.95.obs;

  final RxDouble translationFontSize =
      AppConstants.defaultTranslationFontSize.obs;

  final RxInt hijriDayOffset = 0.obs;

  final RxBool tilawatNotifyMe = false.obs;

  // Reactive Last Read & Bookmarks State

  final RxInt lastReadSurah = 1.obs;

  final RxInt lastReadAyah = 1.obs;

  final RxInt lastReadPage = 1.obs;

  final RxDouble lastReadOffset = 0.0.obs;

  final RxInt lastReadTimestamp = 0.obs;

  final RxList<String> bookmarkedAyahs = <String>[].obs;

  bool get isUrdu =>
      currentLocale.value.languageCode == 'ur';

  bool get hasLastReadProgress =>
      lastReadTimestamp.value > 0;

  // Initialization

  Future<SettingsService> init() async {
    await GetStorage.init(_boxName);

    _box = GetStorage(_boxName);

    _loadFromStorage();

    return this;
  }

  // Safe Storage Readers

  String _readString(String key, String fallback) {
    final value = _box.read(key);

    if (value is String) {
      return value;
    }

    return fallback;
  }

  bool _readBool(String key, bool fallback) {
    final value = _box.read(key);

    if (value is bool) {
      return value;
    }

    return fallback;
  }

  int _readInt(String key, int fallback) {
    final value = _box.read(key);

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return fallback;
  }

  double _readDouble(String key, double fallback) {
    final value = _box.read(key);

    if (value is num) {
      return value.toDouble();
    }

    return fallback;
  }

  // Load Saved Settings

  void _loadFromStorage() {
    // Theme
    final String savedTheme =
    _readString(_keyThemeMode, 'system');

    themeMode.value = _parseThemeMode(savedTheme);

    // Language
    final String savedLang =
    _readString(_keyLanguageCode, 'en');

    currentLocale.value =
    savedLang == 'ur' ? urduLocale : englishLocale;

    // Numerals
    useUrduNumerals.value = _readBool(
      _keyUseUrduNumerals,
      savedLang == 'ur',
    );

    // Translation Visibility
    showUrduTranslation.value =
        _readBool(_keyShowUrduTranslation, true);

    showEnglishTranslation.value =
        _readBool(_keyShowEnglishTranslation, true);

    // Mushaf Mode
    isMushaf16LineMode.value =
        _readBool(_keyIsMushaf16LineMode, true);

    // Quran Arabic Marks
    // Default false to avoid hiding Quranic marks accidentally.
    cleanArabicMarks.value =
        _readBool(_keyCleanArabicMarks, false);

    // Quran Font Size
    quranFontSize.value = _readDouble(
      _keyQuranFontSize,
      AppConstants.defaultQuranFontSize,
    ).clamp(
      AppConstants.minQuranFontSize,
      AppConstants.maxQuranFontSize,
    ).toDouble();

    // Quran Line Height
    quranLineHeight.value = _readDouble(
      _keyQuranLineHeight,
      1.95,
    ).clamp(1.55, 2.55).toDouble();

    // Translation Font Size
    translationFontSize.value = _readDouble(
      _keyTranslationFontSize,
      AppConstants.defaultTranslationFontSize,
    ).clamp(
      AppConstants.minTranslationFontSize,
      AppConstants.maxTranslationFontSize,
    ).toDouble();

    // Hijri Offset
    hijriDayOffset.value = _readInt(
      _keyHijriDayOffset,
      0,
    ).clamp(-2, 2).toInt();

    // Last Read Position
    lastReadSurah.value = _readInt(
      _keyLastReadSurah,
      1,
    ).clamp(1, 114).toInt();

    lastReadAyah.value = _readInt(
      _keyLastReadAyah,
      1,
    ).clamp(1, 286).toInt();

    lastReadPage.value = _readInt(
      _keyLastReadPage,
      1,
    ).clamp(1, 604).toInt();

    lastReadOffset.value = _readDouble(
      _keyLastReadOffset,
      0.0,
    ).clamp(0.0, 1000000.0).toDouble();

    lastReadTimestamp.value = _readInt(
      _keyLastReadTimestamp,
      0,
    ).clamp(0, 9999999999999).toInt();

    // Bookmarks
    final dynamic savedBookmarks =
    _box.read(_keyBookmarkedAyahs);

    if (savedBookmarks is List) {
      final validBookmarks = savedBookmarks
          .whereType<String>()
          .where(_isValidBookmark)
          .toSet()
          .toList();

      bookmarkedAyahs.assignAll(validBookmarks);
    } else {
      bookmarkedAyahs.clear();
    }

    // Tilawat Notification
    tilawatNotifyMe.value =
        _readBool(_keyTilawatNotifyMe, false);
  }

  bool _isValidBookmark(String value) {
    final parts = value.split(':');

    if (parts.length != 2) {
      return false;
    }

    final int? surah = int.tryParse(parts[0]);
    final int? ayah = int.tryParse(parts[1]);

    if (surah == null || ayah == null) {
      return false;
    }

    return surah >= 1 &&
        surah <= 114 &&
        ayah >= 1 &&
        ayah <= 286;
  }

  // Storage Integrity

  bool verifyStorageIntegrity() {
    const String probeKey = '_health_probe';

    try {
      _box.write(probeKey, true);

      final bool ok =
          _box.read<bool>(probeKey) ?? false;

      _box.remove(probeKey);

      return ok;
    } catch (_) {
      return false;
    }
  }

  // Theme Settings

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;

    await _box.write(_keyThemeMode, mode.name);

    Get.changeThemeMode(mode);
  }

  Future<void> toggleLightDarkTheme(
      bool isCurrentlyDark,
      ) async {
    await setThemeMode(
      isCurrentlyDark
          ? ThemeMode.light
          : ThemeMode.dark,
    );
  }

  // Language Settings

  Future<void> setLocale(Locale locale) async {
    final Locale selectedLocale =
    locale.languageCode == 'ur'
        ? urduLocale
        : englishLocale;

    currentLocale.value = selectedLocale;

    await _box.write(
      _keyLanguageCode,
      selectedLocale.languageCode,
    );

    await Get.updateLocale(selectedLocale);
  }

  Future<void> toggleLanguage() async {
    await setLocale(
      isUrdu ? englishLocale : urduLocale,
    );
  }

  // Hijri Settings

  Future<void> setHijriDayOffset(int offset) async {
    final int clamped =
    offset.clamp(-2, 2).toInt();

    hijriDayOffset.value = clamped;

    await _box.write(
      _keyHijriDayOffset,
      clamped,
    );

    // Old daily feed cache should not be reused
    // after changing the Hijri date offset.
    await _box.remove(_keyDailyFeedCacheDate);
  }

  // Quran Numerals

  Future<void> setUseUrduNumerals(bool value) async {
    useUrduNumerals.value = value;

    await _box.write(
      _keyUseUrduNumerals,
      value,
    );
  }

  // Translation Visibility

  Future<void> setShowUrduTranslation(
      bool value,
      ) async {
    showUrduTranslation.value = value;

    await _box.write(
      _keyShowUrduTranslation,
      value,
    );
  }

  Future<void> setShowEnglishTranslation(
      bool value,
      ) async {
    showEnglishTranslation.value = value;

    await _box.write(
      _keyShowEnglishTranslation,
      value,
    );
  }

  // Mushaf Display Mode

  Future<void> setMushaf16LineMode(
      bool value,
      ) async {
    isMushaf16LineMode.value = value;

    await _box.write(
      _keyIsMushaf16LineMode,
      value,
    );
  }

  // Arabic Marks Preference

  Future<void> setCleanArabicMarks(
      bool value,
      ) async {
    cleanArabicMarks.value = value;

    await _box.write(
      _keyCleanArabicMarks,
      value,
    );
  }

  // Important:
  // Do not use cleanArabicMarks to remove Quranic
  // letters, Harakat, Tajweed signs, or Uthmani symbols
  // from the original Quran text.

  // Quran Font Settings

  Future<void> setQuranFontSize(
      double size,
      ) async {
    final double clamped = size.clamp(
      AppConstants.minQuranFontSize,
      AppConstants.maxQuranFontSize,
    ).toDouble();

    quranFontSize.value = clamped;

    await _box.write(
      _keyQuranFontSize,
      clamped,
    );
  }

  Future<void> setQuranLineHeight(
      double height,
      ) async {
    final double clamped =
    height.clamp(1.55, 2.55).toDouble();

    quranLineHeight.value = clamped;

    await _box.write(
      _keyQuranLineHeight,
      clamped,
    );
  }

  // Translation Font Settings

  Future<void> setTranslationFontSize(
      double size,
      ) async {
    final double clamped = size.clamp(
      AppConstants.minTranslationFontSize,
      AppConstants.maxTranslationFontSize,
    ).toDouble();

    translationFontSize.value = clamped;

    await _box.write(
      _keyTranslationFontSize,
      clamped,
    );
  }

  // Daily Feed Cache

  String? readCachedDailyFeedJson(
      String dateKey,
      ) {
    final String cachedDate =
    _readString(_keyDailyFeedCacheDate, '');

    if (cachedDate != dateKey) {
      return null;
    }

    return _readStringOrNull(
      _keyDailyFeedCacheJson,
    );
  }

  String? readAnyCachedDailyFeedJson() {
    return _readStringOrNull(
      _keyDailyFeedCacheJson,
    );
  }

  String? _readStringOrNull(String key) {
    final dynamic value = _box.read(key);

    return value is String ? value : null;
  }

  Future<void> saveCachedDailyFeedJson(
      String dateKey,
      String jsonPayload,
      ) async {
    await _box.write(
      _keyDailyFeedCacheDate,
      dateKey,
    );

    await _box.write(
      _keyDailyFeedCacheJson,
      jsonPayload,
    );
  }

  // Last Read Position

  Future<void> saveLastReadPosition({
    required int surahId,
    required int ayahNumber,
    int pageNumber = 1,
    double scrollOffset = 0.0,
  }) async {
    final int safeSurahId =
    surahId.clamp(1, 114).toInt();

    final int safeAyahNumber =
    ayahNumber.clamp(1, 286).toInt();

    final int safePageNumber =
    pageNumber.clamp(1, 604).toInt();

    final double safeScrollOffset =
    scrollOffset.isFinite
        ? scrollOffset.clamp(0.0, 1000000.0).toDouble()
        : 0.0;

    final int nowMillis =
        DateTime.now().millisecondsSinceEpoch;

    lastReadSurah.value = safeSurahId;
    lastReadAyah.value = safeAyahNumber;
    lastReadPage.value = safePageNumber;
    lastReadOffset.value = safeScrollOffset;
    lastReadTimestamp.value = nowMillis;

    await _box.write(
      _keyLastReadSurah,
      safeSurahId,
    );

    await _box.write(
      _keyLastReadAyah,
      safeAyahNumber,
    );

    await _box.write(
      _keyLastReadPage,
      safePageNumber,
    );

    await _box.write(
      _keyLastReadOffset,
      safeScrollOffset,
    );

    await _box.write(
      _keyLastReadTimestamp,
      nowMillis,
    );
  }

  // Bookmarks

  bool isAyahBookmarked(
      int surahNumber,
      int ayahNumber,
      ) {
    return bookmarkedAyahs.contains(
      '$surahNumber:$ayahNumber',
    );
  }

  Future<void> toggleBookmarkAyah(
      int surahNumber,
      int ayahNumber,
      ) async {
    if (surahNumber < 1 ||
        surahNumber > 114 ||
        ayahNumber < 1 ||
        ayahNumber > 286) {
      return;
    }

    final String key =
        '$surahNumber:$ayahNumber';

    if (bookmarkedAyahs.contains(key)) {
      bookmarkedAyahs.remove(key);
    } else {
      bookmarkedAyahs.insert(0, key);
    }

    await _box.write(
      _keyBookmarkedAyahs,
      bookmarkedAyahs.toList(),
    );
  }

  // Tilawat Notification

  Future<void> setTilawatNotifyMe(
      bool value,
      ) async {
    tilawatNotifyMe.value = value;

    await _box.write(
      _keyTilawatNotifyMe,
      value,
    );
  }

  // Theme Parser

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;

      case 'dark':
        return ThemeMode.dark;

      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
