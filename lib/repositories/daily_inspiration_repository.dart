import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../data/remote/api_client.dart';
import '../../data/remote/endpoints.dart';
import '../../models/daily_inspiration_model.dart';
import '../../models/islamic_date_info_model.dart';
import '../../res/services/settings_service.dart';
import '../../res/utils/urdu_number_utils.dart';

/// Fetches live daily random (or Islamic-occasion-specific) Quranic Ayahs
/// and Sahih Hadiths from remote APIs, caching today's feed locally.
class DailyInspirationRepository {
  final ApiClient _apiClient;
  final SettingsService _settingsService;

  static const int _totalQuranAyahs = 6236;
  static const int _maxBukhariNumber = 7563;

  DailyInspirationRepository({
    ApiClient? apiClient,
    required SettingsService settingsService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _settingsService = settingsService;

  /// Returns an alternating list `[Ayah, Hadith, Ayah, Hadith]` for today's date.
  /// - If today is a special Islamic date (e.g. 10 Dhul Hijjah Qurbani, Eid, Ramadan, Jummah),
  ///   the first Ayah & Hadith pair matches that occasion, followed by a fresh random pair.
  /// - Uses same-day local cache unless [forceRefresh] is true.
  Future<List<DailyInspirationModel>> fetchDailyLiveFeed({
    required IslamicDateInfoModel dateInfo,
    bool forceRefresh = false,
  }) async {
    final String cacheKey =
        '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}_h${dateInfo.hijriMonth}_${dateInfo.hijriDay}';

    if (!forceRefresh) {
      final String? cachedJson = _settingsService.readCachedDailyFeedJson(cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<DailyInspirationModel> decoded = _decodeFeed(cachedJson);
        if (decoded.isNotEmpty) return decoded;
      }
    }

    final Random random = Random(
      DateTime.now().millisecondsSinceEpoch ^ (forceRefresh ? 7919 : 104729),
    );

    final List<DailyInspirationModel> liveItems = <DailyInspirationModel>[];

    // Pair 1: Occasion-specific Ayah & Hadith if today has Islamic significance, otherwise random
    final String firstAyahRef = dateInfo.occasionAyahRef ??
        (random.nextInt(_totalQuranAyahs) + 1).toString();
    final int firstBukhariNum = dateInfo.occasionBukhariNumber ??
        (random.nextInt(_maxBukhariNumber) + 1);

    final List<DailyInspirationModel?> pair1 =
    await Future.wait<DailyInspirationModel?>(
      <Future<DailyInspirationModel?>>[
        _fetchLiveAyah(
          reference: firstAyahRef,
          occasionEn: dateInfo.occasionTitleEn,
          occasionUr: dateInfo.occasionTitleUr,
        ),
        _fetchLiveBukhariHadith(
          hadithNumber: firstBukhariNum,
          occasionEn: dateInfo.occasionTitleEn,
          occasionUr: dateInfo.occasionTitleUr,
        ),
      ],
    );

    if (pair1[0] != null) liveItems.add(pair1[0]!);
    if (pair1[1] != null) liveItems.add(pair1[1]!);

    // Pair 2: Additional live random Ayah & Sahih Hadith for continuous news-ticker rotation
    final String secondAyahRef = (random.nextInt(_totalQuranAyahs) + 1).toString();
    final int secondBukhariNum = random.nextInt(_maxBukhariNumber) + 1;

    final List<DailyInspirationModel?> pair2 =
    await Future.wait<DailyInspirationModel?>(
      <Future<DailyInspirationModel?>>[
        _fetchLiveAyah(reference: secondAyahRef),
        _fetchLiveBukhariHadith(hadithNumber: secondBukhariNum),
      ],
    );

    if (pair2[0] != null) liveItems.add(pair2[0]!);
    if (pair2[1] != null) liveItems.add(pair2[1]!);

    if (liveItems.isNotEmpty) {
      await _settingsService.saveCachedDailyFeedJson(
        cacheKey,
        _encodeFeed(liveItems),
      );
      return liveItems;
    }

    // Offline fallback: return previous day's cached items if network is unavailable
    final String? staleCache = _settingsService.readAnyCachedDailyFeedJson();
    if (staleCache != null && staleCache.isNotEmpty) {
      return _decodeFeed(staleCache);
    }

    return _emergencyOfflineFallback(dateInfo);
  }

  Future<DailyInspirationModel?> _fetchLiveAyah({
    required String reference,
    String? occasionEn,
    String? occasionUr,
  }) async {
    try {
      final Map<String, dynamic> response = await _apiClient.getJson(
        Endpoints.quranAyahEditions(reference),
      );

      final dynamic rawData = response['data'];
      if (rawData is! List<dynamic> || rawData.length < 3) return null;

      final Map<String, dynamic> arabicEdition =
      rawData[0] as Map<String, dynamic>;
      final Map<String, dynamic> englishEdition =
      rawData[1] as Map<String, dynamic>;
      final Map<String, dynamic> urduEdition =
      rawData[2] as Map<String, dynamic>;

      final Map<String, dynamic> surahMeta =
          arabicEdition['surah'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final String surahEnglishName =
          surahMeta['englishName'] as String? ?? 'Quran';
      final String surahArabicName = surahMeta['name'] as String? ?? '';
      final int surahNumber = surahMeta['number'] as int? ?? 1;
      final int ayahInSurah = arabicEdition['numberInSurah'] as int? ?? 1;

      final String arabicText = (arabicEdition['text'] as String? ?? '').trim();
      final String englishText = (englishEdition['text'] as String? ?? '').trim();
      final String urduText = (urduEdition['text'] as String? ?? '').trim();

      if (arabicText.isEmpty) return null;

      return DailyInspirationModel(
        id: 'ayah_${surahNumber}_$ayahInSurah',
        type: InspirationType.ayah,
        arabicText: arabicText,
        englishTranslation: englishText,
        urduTranslation: urduText,
        englishReference: '$surahEnglishName • $surahNumber:$ayahInSurah',
        urduReference:
        '$surahArabicName • ${UrduNumberUtils.format(surahNumber)}:${UrduNumberUtils.format(ayahInSurah)}',
        occasionLabelEn: occasionEn,
        occasionLabelUr: occasionUr,
      );
    } catch (e) {
      debugPrint(
          '[DailyInspirationRepository] Failed to fetch Ayah ($reference): $e');
      return null;
    }
  }

  Future<DailyInspirationModel?> _fetchLiveBukhariHadith({
    required int hadithNumber,
    String? occasionEn,
    String? occasionUr,
  }) async {
    try {
      final List<Map<String, dynamic>> responses =
      await Future.wait<Map<String, dynamic>>(
        <Future<Map<String, dynamic>>>[
          _apiClient.getJson(Endpoints.bukhariArabic(hadithNumber)),
          _apiClient.getJson(Endpoints.bukhariEnglish(hadithNumber)),
          _apiClient.getJson(Endpoints.bukhariUrdu(hadithNumber)),
        ],
      );

      final String arabicText = _extractHadithText(responses[0]);
      final String englishText = _extractHadithText(responses[1]);
      final String urduText = _extractHadithText(responses[2]);

      if (arabicText.isEmpty && englishText.isEmpty) return null;

      return DailyInspirationModel(
        id: 'bukhari_$hadithNumber',
        type: InspirationType.hadith,
        arabicText: arabicText.isNotEmpty ? arabicText : englishText,
        englishTranslation: englishText,
        urduTranslation: urduText.isNotEmpty ? urduText : englishText,
        englishReference: 'Sahih al-Bukhari • $hadithNumber',
        urduReference: 'صحیح البخاری • ${UrduNumberUtils.format(hadithNumber)}',
        occasionLabelEn: occasionEn,
        occasionLabelUr: occasionUr,
      );
    } catch (e) {
      debugPrint(
          '[DailyInspirationRepository] Failed to fetch Bukhari #$hadithNumber: $e');
      return null;
    }
  }

  String _extractHadithText(Map<String, dynamic> payload) {
    final dynamic hadiths = payload['hadiths'];
    if (hadiths is List<dynamic> && hadiths.isNotEmpty) {
      final Map<String, dynamic> first =
      hadiths.first as Map<String, dynamic>;
      return (first['text'] as String? ?? '').trim();
    }
    return '';
  }

  String _encodeFeed(List<DailyInspirationModel> items) {
    final List<Map<String, dynamic>> list = items
        .map((DailyInspirationModel e) => e.toJson())
        .toList();
    return jsonEncode(list);
  }

  List<DailyInspirationModel> _decodeFeed(String rawJson) {
    try {
      final dynamic decoded = jsonDecode(rawJson);
      if (decoded is List<dynamic>) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(DailyInspirationModel.fromJson)
            .toList();
      }
    } catch (e) {
      debugPrint('[DailyInspirationRepository] Cache decode error: $e');
    }
    return <DailyInspirationModel>[];
  }

  /// Minimal public-domain Arabic fallback only when device has never been online.
  List<DailyInspirationModel> _emergencyOfflineFallback(
      IslamicDateInfoModel dateInfo,
      ) {
    return <DailyInspirationModel>[
      DailyInspirationModel(
        id: 'offline_ayah_1',
        type: InspirationType.ayah,
        arabicText:
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        englishTranslation:
        'Connect to the internet to load live daily Quran translation.',
        urduTranslation:
        'روزانہ لائیو ترجمہ لوڈ کرنے کے لیے انٹرنیٹ سے منسلک ہوں۔',
        englishReference: 'Al-Fatihah • 1:1-2',
        urduReference: 'الفاتحہ • ۱:۱-۲',
        occasionLabelEn: dateInfo.occasionTitleEn,
        occasionLabelUr: dateInfo.occasionTitleUr,
      ),
    ];
  }
}