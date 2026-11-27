
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../data/remote/api_client.dart';
import '../data/remote/endpoints.dart';
import '../models/quran_ayah_model.dart';

/// Offline-first repository for the Holy Quran.
///
/// Data priority:
/// 1. Bundled Quran JSON
/// 2. Local Surah cache
/// 3. Online AlQuran Cloud API
class QuranOfflineRepository {
  static const String _bundledAssetPath =
      'assets/data/quran_complete.json';

  static const int _totalSurahs = 114;

  final ApiClient _apiClient;

  Directory? _cacheDir;

  static Map<int, List<QuranAyahModel>>?
  _bundledQuranMemoryCache;

  static bool _bundledAssetMissing = false;

  QuranOfflineRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ------------------------------------------------------------
  // 1. ARABIC TEXT CLEANING
  // ------------------------------------------------------------

  /// Normalizes Arabic words only for comparison.
  ///
  /// Does NOT modify the original Quran text.
  static String _normalizeArabicForComparison(String word) {
    return word
        .replaceAll(
      RegExp(r'[\u0640\u064B-\u065F\u0670\u06D6-\u06ED]'),
      '',
    )
        .replaceAll('ٱ', 'ا')
        .trim();
  }

  /// Removes Bismillah only when all four opening words match.
  ///
  /// Used for Surahs 2-8 and 10-114.
  static String stripBismillah(String text) {
    final String cleanedText =
    text.replaceAll('\uFEFF', '').trim();

    if (cleanedText.isEmpty) {
      return cleanedText;
    }

    final List<String> words =
    cleanedText.split(RegExp(r'\s+'));

    const List<String> expectedWords = [
      'بسم',
      'الله',
      'الرحمن',
      'الرحيم',
    ];

    if (words.length <= 4) {
      return cleanedText;
    }

    final List<String> firstFourWords = words
        .take(4)
        .map(_normalizeArabicForComparison)
        .toList();

    final bool matchesBismillah = List.generate(
      4,
          (index) =>
      firstFourWords[index] == expectedWords[index],
    ).every((match) => match);

    if (!matchesBismillah) {
      return cleanedText;
    }

    return words.sublist(4).join(' ').trim();
  }

  /// Removes only invisible BOM characters.
  ///
  /// Important Quranic characters, diacritics, Alif Wasla,
  /// and Mushaf symbols are preserved.
  static String cleanArabicGlyphs(String text) {
    return text.replaceAll('\uFEFF', '').trim();
  }

  // ------------------------------------------------------------
  // 2. AYAH SANITIZATION
  // ------------------------------------------------------------

  /// Sanitizes an existing Quran Ayah model.
  ///
  /// Keeps compatibility with the current QuranAyahModel.
  QuranAyahModel _sanitizeAyah(QuranAyahModel raw) {
    String cleanedArabic = cleanArabicGlyphs(
      raw.arabicText,
    );

    if (raw.surahNumber != 1 &&
        raw.surahNumber != 9 &&
        raw.numberInSurah == 1) {
      cleanedArabic = stripBismillah(cleanedArabic);
    }

    return QuranAyahModel(
      surahNumber: raw.surahNumber,
      numberInSurah: raw.numberInSurah,
      arabicText: cleanedArabic,
      urduTranslation: raw.urduTranslation,
      englishTranslation: raw.englishTranslation,
      juz: raw.juz,
      page: raw.page,
      ruku: raw.ruku,
      hasSajda: raw.hasSajda,
    );
  }

  // ------------------------------------------------------------
  // 3. JSON PARSING
  // ------------------------------------------------------------

  /// Converts JSON maps into Quran Ayah models.
  List<QuranAyahModel> _parseAyahList(dynamic value) {
    if (value is! List) {
      throw const FormatException(
        'Invalid Ayah list in Quran JSON.',
      );
    }

    final List<QuranAyahModel> result = [];

    for (final dynamic item in value) {
      if (item is! Map) {
        throw const FormatException(
          'Invalid Ayah object in Quran JSON.',
        );
      }

      final Map<String, dynamic> json =
      Map<String, dynamic>.from(item);

      result.add(
        _sanitizeAyah(
          QuranAyahModel.fromJson(json),
        ),
      );
    }

    return result;
  }

  /// Parses locally cached Surah JSON.
  List<QuranAyahModel> _parseCachedSurah(String raw) {
    final dynamic decoded = jsonDecode(
      raw.replaceAll('\uFEFF', '').trim(),
    );

    return _parseAyahList(decoded);
  }

  // ------------------------------------------------------------
  // 4. BUNDLED QURAN ASSET
  // ------------------------------------------------------------

  Future<Map<int, List<QuranAyahModel>>?>
  _loadBundledQuranAsset() async {
    if (_bundledQuranMemoryCache != null) {
      return _bundledQuranMemoryCache;
    }

    if (_bundledAssetMissing) {
      return null;
    }

    try {
      final String raw = await rootBundle.loadString(
        _bundledAssetPath,
      );

      final String cleanedRaw =
      raw.replaceAll('\uFEFF', '').trim();

      if (cleanedRaw.isEmpty) {
        throw const FormatException(
          'Bundled Quran JSON is empty.',
        );
      }

      final dynamic decoded = jsonDecode(cleanedRaw);

      if (decoded is! Map) {
        throw const FormatException(
          'Invalid bundled Quran JSON format.',
        );
      }

      final Map<int, List<QuranAyahModel>> parsedMap = {};

      for (final entry in decoded.entries) {
        final int? surahNumber =
        int.tryParse(entry.key.toString());

        if (surahNumber == null ||
            surahNumber < 1 ||
            surahNumber > _totalSurahs) {
          continue;
        }

        final List<QuranAyahModel> ayahs =
        _parseAyahList(entry.value);

        if (ayahs.isEmpty) {
          throw FormatException(
            'Surah $surahNumber has no Ayahs.',
          );
        }

        // Verify every Ayah belongs to the correct Surah.
        for (final ayah in ayahs) {
          if (ayah.surahNumber != surahNumber) {
            throw FormatException(
              'Surah number mismatch in Surah $surahNumber.',
            );
          }
        }

        parsedMap[surahNumber] = ayahs;
      }

      if (parsedMap.isEmpty) {
        throw const FormatException(
          'No valid Surahs found in bundled JSON.',
        );
      }

      _bundledQuranMemoryCache = parsedMap;

      debugPrint(
        '[QuranOfflineRepository] '
            'Loaded ${parsedMap.length} Surahs from bundled JSON.',
      );

      return parsedMap;
    } catch (e, stackTrace) {
      _bundledAssetMissing = true;

      debugPrint(
        '[QuranOfflineRepository] Bundled asset error: $e',
      );

      debugPrintStack(stackTrace: stackTrace);

      return null;
    }
  }

  // ------------------------------------------------------------
  // 5. LOCAL CACHE DIRECTORY
  // ------------------------------------------------------------

  Future<Directory?> _ensureCacheDir() async {
    if (_cacheDir != null) {
      return _cacheDir;
    }

    try {
      final Directory appDir =
      await getApplicationDocumentsDirectory();

      final Directory dir = Directory(
        '${appDir.path}/quran_offline',
      );

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      _cacheDir = dir;

      return dir;
    } catch (e) {
      debugPrint(
        '[QuranOfflineRepository] '
            'Cache directory unavailable: $e',
      );

      return null;
    }
  }

  Future<File?> _getSurahCacheFile(
      int surahNumber,
      ) async {
    if (surahNumber < 1 ||
        surahNumber > _totalSurahs) {
      return null;
    }

    final Directory? dir = await _ensureCacheDir();

    if (dir == null) {
      return null;
    }

    final String paddedNumber =
    surahNumber.toString().padLeft(3, '0');

    return File(
      '${dir.path}/surah_$paddedNumber.json',
    );
  }

  // ------------------------------------------------------------
  // 6. CACHE READING
  // ------------------------------------------------------------

  Future<List<QuranAyahModel>?> _readSurahCache(
      int surahNumber,
      ) async {
    final File? file =
    await _getSurahCacheFile(surahNumber);

    if (file == null || !await file.exists()) {
      return null;
    }

    try {
      final String raw = await file.readAsString();

      if (raw.trim().isEmpty) {
        return null;
      }

      final List<QuranAyahModel> ayahs =
      _parseCachedSurah(raw);

      if (ayahs.isEmpty) {
        return null;
      }

      for (final ayah in ayahs) {
        if (ayah.surahNumber != surahNumber) {
          throw FormatException(
            'Invalid Surah number in cache: $surahNumber',
          );
        }
      }

      return ayahs;
    } catch (e) {
      debugPrint(
        '[QuranOfflineRepository] '
            'Cache read failed for Surah $surahNumber: $e',
      );

      return null;
    }
  }

  /// Saves Surah data to local storage.
  Future<void> _saveSurahCache(
      int surahNumber,
      List<QuranAyahModel> ayahs,
      ) async {
    try {
      final File? file =
      await _getSurahCacheFile(surahNumber);

      if (file == null) {
        return;
      }

      final String encoded = const JsonEncoder.withIndent(
        '  ',
      ).convert(
        ayahs.map((ayah) => ayah.toJson()).toList(),
      );

      await file.writeAsString(
        encoded,
        encoding: utf8,
        flush: true,
      );

      debugPrint(
        '[QuranOfflineRepository] '
            'Surah $surahNumber cached successfully.',
      );
    } catch (e) {
      debugPrint(
        '[QuranOfflineRepository] '
            'Cache save failed for Surah $surahNumber: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // 7. CACHED SURAH INFORMATION
  // ------------------------------------------------------------

  Future<Set<int>> getCachedSurahNumbers() async {
    final Set<int> cached = {};

    // First check bundled Quran.
    final Map<int, List<QuranAyahModel>>? bundled =
    await _loadBundledQuranAsset();

    if (bundled != null) {
      cached.addAll(bundled.keys);
    }

    if (cached.length == _totalSurahs) {
      return cached;
    }

    // Then check local cache.
    try {
      final Directory? dir = await _ensureCacheDir();

      if (dir == null || !await dir.exists()) {
        return cached;
      }

      await for (final FileSystemEntity entity
      in dir.list()) {
        if (entity is! File ||
            !entity.path.endsWith('.json')) {
          continue;
        }

        final String name = entity.uri.pathSegments.last
            .replaceFirst('surah_', '')
            .replaceFirst('.json', '');

        final int? number = int.tryParse(name);

        if (number == null ||
            number < 1 ||
            number > _totalSurahs) {
          continue;
        }

        final List<QuranAyahModel>? ayahs =
        await _readSurahCache(number);

        if (ayahs != null && ayahs.isNotEmpty) {
          cached.add(number);
        }
      }
    } catch (e) {
      debugPrint(
        '[QuranOfflineRepository] '
            'Error scanning cache: $e',
      );
    }

    return cached;
  }

  /// Checks whether a Surah is available offline.
  Future<bool> isSurahCached(int surahNumber) async {
    if (surahNumber < 1 ||
        surahNumber > _totalSurahs) {
      return false;
    }

    final Map<int, List<QuranAyahModel>>? bundled =
    await _loadBundledQuranAsset();

    if (bundled?[surahNumber]?.isNotEmpty ?? false) {
      return true;
    }

    final List<QuranAyahModel>? cached =
    await _readSurahCache(surahNumber);

    return cached != null && cached.isNotEmpty;
  }

  // ------------------------------------------------------------
  // 8. ONLINE API DATA
  // ------------------------------------------------------------

  /// Safely extracts an API edition.
  List<dynamic> _getEditionAyahs(
      dynamic edition,
      String editionName,
      ) {
    if (edition is! Map) {
      throw FormatException(
        'Invalid $editionName edition.',
      );
    }

    final dynamic ayahs = edition['ayahs'];

    if (ayahs is! List || ayahs.isEmpty) {
      throw FormatException(
        'No Ayahs found in $editionName edition.',
      );
    }

    return ayahs;
  }

  /// Converts API editions into Quran Ayah models.
  ///
  /// Expected API edition order:
  /// 0 = Arabic Uthmani
  /// 1 = English Asad
  /// 2 = Urdu Jalandhry
  List<QuranAyahModel> _parseApiEditions(
      int surahNumber,
      dynamic responseData,
      ) {
    if (responseData is! List ||
        responseData.length < 3) {
      throw const FormatException(
        'Invalid Quran API editions response.',
      );
    }

    final List<dynamic> arAyahs =
    _getEditionAyahs(
      responseData[0],
      'Arabic',
    );

    final List<dynamic> enAyahs =
    _getEditionAyahs(
      responseData[1],
      'English',
    );

    final List<dynamic> urAyahs =
    _getEditionAyahs(
      responseData[2],
      'Urdu',
    );

    // Do not combine mismatched translations.
    if (arAyahs.length != enAyahs.length ||
        arAyahs.length != urAyahs.length) {
      throw const FormatException(
        'Arabic, Urdu and English Ayah counts do not match.',
      );
    }

    final List<QuranAyahModel> parsed = [];

    for (int i = 0; i < arAyahs.length; i++) {
      if (arAyahs[i] is! Map ||
          enAyahs[i] is! Map ||
          urAyahs[i] is! Map) {
        throw FormatException(
          'Invalid Ayah data at index $i.',
        );
      }

      final Map<String, dynamic> ar =
      Map<String, dynamic>.from(arAyahs[i]);

      final Map<String, dynamic> en =
      Map<String, dynamic>.from(enAyahs[i]);

      final Map<String, dynamic> ur =
      Map<String, dynamic>.from(urAyahs[i]);

      final int numberInSurah =
          (ar['numberInSurah'] as num?)?.toInt() ??
              (i + 1);

      if (numberInSurah != i + 1) {
        throw FormatException(
          'Arabic Ayah numbering error in Surah $surahNumber.',
        );
      }

      final int urduNumber =
          (ur['numberInSurah'] as num?)?.toInt() ??
              (i + 1);

      final int englishNumber =
          (en['numberInSurah'] as num?)?.toInt() ??
              (i + 1);

      if (urduNumber != numberInSurah ||
          englishNumber != numberInSurah) {
        throw FormatException(
          'Translation numbering mismatch in '
              'Surah $surahNumber, Ayah $numberInSurah.',
        );
      }

      String arabicText =
      cleanArabicGlyphs(
        ar['text'] as String? ?? '',
      );

      if (surahNumber != 1 &&
          surahNumber != 9 &&
          numberInSurah == 1) {
        arabicText = stripBismillah(arabicText);
      }

      final dynamic sajdaRaw = ar['sajda'];

      final bool hasSajda =
          sajdaRaw == true || sajdaRaw is Map;

      parsed.add(
        QuranAyahModel(
          surahNumber: surahNumber,
          numberInSurah: numberInSurah,
          arabicText: arabicText,
          urduTranslation: cleanArabicGlyphs(
            ur['text'] as String? ?? '',
          ),
          englishTranslation: cleanArabicGlyphs(
            en['text'] as String? ?? '',
          ),
          juz: (ar['juz'] as num?)?.toInt() ?? 1,
          page: (ar['page'] as num?)?.toInt() ?? 1,
          ruku: (ar['ruku'] as num?)?.toInt() ?? 1,
          hasSajda: hasSajda,
        ),
      );
    }

    return parsed;
  }

  // ------------------------------------------------------------
  // 9. MAIN SURAH LOADER
  // ------------------------------------------------------------

  /// Loads a Surah using offline-first strategy.
  ///
  /// forceRefresh:
  /// true = Attempts online API first.
  /// false = Uses bundled data/cache first.
  ///
  /// If the network fails, existing cached data is returned.
  Future<List<QuranAyahModel>> getSurahAyahs(
      int surahNumber, {
        bool forceRefresh = false,
      }) async {
    // Validate Surah number.
    if (surahNumber < 1 ||
        surahNumber > _totalSurahs) {
      throw RangeError.range(
        surahNumber,
        1,
        _totalSurahs,
        'surahNumber',
      );
    }

    List<QuranAyahModel>? localFallback;

    if (!forceRefresh) {
      // Priority 1: Bundled Quran JSON.
      final Map<int, List<QuranAyahModel>>? bundled =
      await _loadBundledQuranAsset();

      final List<QuranAyahModel>? bundledSurah =
      bundled?[surahNumber];

      if (bundledSurah != null &&
          bundledSurah.isNotEmpty) {
        return bundledSurah;
      }

      // Priority 2: Local cache.
      localFallback = await _readSurahCache(
        surahNumber,
      );

      if (localFallback != null &&
          localFallback.isNotEmpty) {
        return localFallback;
      }
    } else {
      // Preserve existing data as fallback during refresh.
      localFallback = await _readSurahCache(
        surahNumber,
      );
    }

    // Priority 3: Online API.
    try {
      debugPrint(
        '[QuranOfflineRepository] '
            'Downloading Surah $surahNumber...',
      );

      final Map<String, dynamic> response =
      await _apiClient.getJson(
        Endpoints.quranSurahEditions(surahNumber),
      );

      if (response['code'] != 200) {
        throw FormatException(
          'Quran API returned an unsuccessful response: '
              '${response['status'] ?? 'Unknown error'}',
        );
      }

      final List<QuranAyahModel> parsed =
      _parseApiEditions(
        surahNumber,
        response['data'],
      );

      if (parsed.isEmpty) {
        throw FormatException(
          'No Ayahs downloaded for Surah $surahNumber.',
        );
      }

      // Save downloaded data for future offline use.
      await _saveSurahCache(
        surahNumber,
        parsed,
      );

      debugPrint(
        '[QuranOfflineRepository] '
            'Surah $surahNumber downloaded successfully. '
            'Total Ayahs: ${parsed.length}',
      );

      return parsed;
    } catch (e, stackTrace) {
      debugPrint(
        '[QuranOfflineRepository] '
            'Network request failed for Surah $surahNumber: $e',
      );

      debugPrintStack(stackTrace: stackTrace);
    }

    // Return existing cache if online refresh fails.
    if (localFallback != null &&
        localFallback.isNotEmpty) {
      return localFallback;
    }

    // Last fallback: bundled JSON.
    final Map<int, List<QuranAyahModel>>? bundled =
    await _loadBundledQuranAsset();

    final List<QuranAyahModel>? bundledSurah =
    bundled?[surahNumber];

    if (bundledSurah != null &&
        bundledSurah.isNotEmpty) {
      return bundledSurah;
    }

    // No local or online data available.
    return const <QuranAyahModel>[];
  }
}
