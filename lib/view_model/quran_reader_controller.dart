import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/qari_model.dart';
import '../models/quran_ayah_model.dart';
import '../repositories/quran_offline_repository.dart';
import '../res/routes/app_routes.dart';
import '../res/services/settings_service.dart';
import 'audio_quran_controller.dart';
import 'base_controller.dart';

/// ViewModel managing the Offline Quran Index (Surahs, 30 Paras, Bookmarks),
/// full-Quran offline batch downloading, and active Surah Mushaf Reader state.
class QuranReaderController extends BaseController {
  final SettingsService settingsService = Get.find<SettingsService>();
  final QuranOfflineRepository _repository = QuranOfflineRepository();

  // Index Tabs: 0 = Surahs (114), 1 = Paras / Juz (30), 2 = Bookmarks
  final RxInt activeIndexTab = 0.obs;
  final RxString searchQuery = ''.obs;

  // Offline Storage Tracking
  final RxSet<int> cachedSurahNumbers = <int>{}.obs;
  final RxBool isDownloadingAllQuran = false.obs;
  final RxInt downloadedSurahsCount = 0.obs;

  // Active Surah Reader State
  final Rx<SurahMeta> activeSurah = QuranAudioData.allSurahs.first.obs;
  final RxList<QuranAyahModel> activeAyahs = <QuranAyahModel>[].obs;
  final RxBool isSurahLoading = false.obs;
  final RxInt highlightedAyahNumber = 1.obs;

  @override
  void onInit() {
    super.onInit();
    refreshOfflineCacheStatus();
  }

  /// Scans local disk to update which Surahs (`1`..`114`) are available offline.
  Future<void> refreshOfflineCacheStatus() async {
    final Set<int> cached = await _repository.getCachedSurahNumbers();
    cachedSurahNumbers.assignAll(cached);
    downloadedSurahsCount.value = cached.length;
  }

  /// Filtered 114 Surahs matching the current [searchQuery].
  List<SurahMeta> get filteredSurahs {
    final String q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return QuranAudioData.allSurahs;
    return QuranAudioData.allSurahs.where((SurahMeta s) {
      return s.englishName.toLowerCase().contains(q) ||
          s.arabicName.contains(q) ||
          s.number.toString() == q ||
          s.revelationLabel.toLowerCase().contains(q);
    }).toList();
  }

  /// Filtered 30 Paras (Juz) matching the current [searchQuery].
  List<ParaMeta> get filteredParas {
    final String q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return QuranAudioData.allParas;
    return QuranAudioData.allParas.where((ParaMeta p) {
      return p.englishName.toLowerCase().contains(q) ||
          p.arabicName.contains(q) ||
          p.number.toString() == q;
    }).toList();
  }

  /// Downloads all uncached Surahs in parallel batches of 5 so the entire
  /// 114-Surah Quran Majeed can be read offline anywhere.
  Future<void> downloadCompleteQuranOffline() async {
    if (isDownloadingAllQuran.value) return;

    await refreshOfflineCacheStatus();
    final List<int> missing = <int>[
      for (int i = 1; i <= 114; i++)
        if (!cachedSurahNumbers.contains(i)) i,
    ];

    if (missing.isEmpty) {
      Get.snackbar(
        'Offline Quran Ready',
        'Complete Quran Majeed (all 114 Surahs) is already saved offline.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isDownloadingAllQuran.value = true;
    try {
      const int batchSize = 5;
      for (int i = 0; i < missing.length; i += batchSize) {
        final List<int> batch = missing.sublist(
          i,
          (i + batchSize).clamp(0, missing.length),
        );
        await Future.wait(
          batch.map((int surahNum) => _repository.getSurahAyahs(surahNum)),
        );
        await refreshOfflineCacheStatus();
      }

      if (downloadedSurahsCount.value == 114) {
        Get.snackbar(
          'Download Complete',
          'All 114 Surahs are now available for 100% offline reading.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Partial Download',
          '${downloadedSurahsCount.value}/114 Surahs saved. Check internet and tap again to finish.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isDownloadingAllQuran.value = false;
    }
  }

  /// Opens [SurahReaderScreen] for [surahNumber] and scrolls to [initialAyah].
  Future<void> openSurah({
    required int surahNumber,
    int initialAyah = 1,
  }) async {
    final SurahMeta target = QuranAudioData.getSurahByNumber(surahNumber);
    activeSurah.value = target;
    highlightedAyahNumber.value = initialAyah;

    if (Get.currentRoute != AppRoutes.surahReader) {
      Get.toNamed(AppRoutes.surahReader);
    }

    await loadSurahContent(target.number, targetAyah: initialAyah);
  }

  /// Loads Ayahs for [surahNumber] from offline storage or network and persists Last Read.
  Future<void> loadSurahContent(
      int surahNumber, {
        int targetAyah = 1,
        bool forceRefresh = false,
      }) async {
    isSurahLoading.value = true;
    try {
      final List<QuranAyahModel> ayahs = await _repository.getSurahAyahs(
        surahNumber,
        forceRefresh: forceRefresh,
      );
      activeAyahs.assignAll(ayahs);
      await refreshOfflineCacheStatus();

      if (ayahs.isNotEmpty) {
        final int safeAyah = targetAyah.clamp(1, ayahs.length);
        highlightedAyahNumber.value = safeAyah;
        final QuranAyahModel ay = ayahs[safeAyah - 1];
        await settingsService.saveLastReadPosition(
          surahId: surahNumber,
          ayahNumber: safeAyah,
          pageNumber: ay.page,
        );
      }
    } finally {
      isSurahLoading.value = false;
    }
  }

  /// Marks a specific Ayah as the user's current reading position.
  Future<void> markAyahAsLastRead(QuranAyahModel ayah) async {
    highlightedAyahNumber.value = ayah.numberInSurah;
    await settingsService.saveLastReadPosition(
      surahId: ayah.surahNumber,
      ayahNumber: ayah.numberInSurah,
      pageNumber: ayah.page,
    );
  }

  /// Reuses [AudioQuranController] (DRY) to play audio recitation of the active Surah.
  Future<void> playActiveSurahAudio() async {
    if (Get.isRegistered<AudioQuranController>()) {
      final AudioQuranController audioCtrl = Get.find<AudioQuranController>();
      await audioCtrl.playSurah(activeSurah.value.number);
    }
  }
}