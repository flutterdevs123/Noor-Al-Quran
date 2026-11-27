import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/daily_inspiration_model.dart';
import '../models/islamic_date_info_model.dart';
import '../repositories/daily_inspiration_repository.dart';
import '../res/constants/app_constants.dart';
import '../res/constants/app_strings.dart';
import '../res/services/prayer_time_service.dart';
import '../res/services/settings_service.dart';
import '../res/services/status_image_saver_service.dart';
import '../res/utils/islamic_calendar_utils.dart';
import 'base_controller.dart';

/// ViewModel for the main Dashboard screen.
class HomeController extends BaseController {
  final SettingsService settingsService = Get.find<SettingsService>();
  late final DailyInspirationRepository _inspirationRepository;
  final PrayerTimeService _prayerTimeService = PrayerTimeService();

  final RxInt currentTabIndex = 0.obs;
  final Rx<IslamicDateInfoModel> todayDateInfo =
      IslamicCalendarUtils.getTodayInfo().obs;
  final RxList<DailyInspirationModel> dailyFeed = <DailyInspirationModel>[].obs;
  final RxInt currentSlideIndex = 0.obs;
  final RxBool isFeedLoading = false.obs;
  final RxBool isTickerPaused = false.obs;
  final RxBool isSavingStatus = false.obs;

  late final Rx<DailyPrayerSchedule> prayerSchedule;

  late final PageController tickerPageController;
  Timer? _autoSlideTimer;
  Timer? _prayerClockTimer;
  bool _isUserDragging = false;

  static const int _virtualPageMultiplier = 1000;

  @override
  void onInit() {
    super.onInit();
    _inspirationRepository = DailyInspirationRepository(
      settingsService: settingsService,
    );

    prayerSchedule = _prayerTimeService.computeTodaySchedule().obs;
    tickerPageController = PageController(
      initialPage: _virtualPageMultiplier * 4,
    );

    _refreshTodayDate();
    loadLiveDailyFeed();
    _initLocationAndPrayerTimes();
  }

  Future<void> _initLocationAndPrayerTimes() async {
    await _prayerTimeService.resolveLocation();
    prayerSchedule.value = _prayerTimeService.computeTodaySchedule();

    // Update countdown every minute
    _prayerClockTimer?.cancel();
    _prayerClockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      prayerSchedule.value = _prayerTimeService.computeTodaySchedule();
    });
  }

  void _refreshTodayDate() {
    todayDateInfo.value = IslamicCalendarUtils.getTodayInfo(
      hijriDayOffset: settingsService.hijriDayOffset.value,
    );
  }

  /// Fetches today's occasion-specific or random Ayah & Sahih Hadith from live APIs.
  Future<void> loadLiveDailyFeed({bool forceRefresh = false}) async {
    _refreshTodayDate();
    isFeedLoading.value = true;

    try {
      final List<DailyInspirationModel> items =
      await _inspirationRepository.fetchDailyLiveFeed(
        dateInfo: todayDateInfo.value,
        forceRefresh: forceRefresh,
      );

      if (items.isNotEmpty) {
        dailyFeed.assignAll(items);
        currentSlideIndex.value = 0;

        if (tickerPageController.hasClients) {
          tickerPageController.jumpToPage(items.length * _virtualPageMultiplier);
        }
        if (!isTickerPaused.value) {
          _startAutoSlideTimer();
        }
      }
    } finally {
      isFeedLoading.value = false;
    }
  }

  /// Updates Hijri moon-sighting offset from the Dual Calendar sheet and refreshes feed.
  Future<void> updateHijriOffset(int newOffset) async {
    await settingsService.setHijriDayOffset(newOffset);
    await loadLiveDailyFeed(forceRefresh: true);
  }

  /// Toggles manual Pause / Resume on the live Ayah & Hadith ticker.
  void toggleTickerPause() {
    isTickerPaused.value = !isTickerPaused.value;
    if (isTickerPaused.value) {
      _autoSlideTimer?.cancel();
    } else {
      _startAutoSlideTimer();
    }
  }

  /// Renders the currently viewed Ayah or Hadith as a 9:16 Status Image and saves to Gallery.
  Future<void> saveItemAsStatusImage(
      BuildContext context,
      DailyInspirationModel item,
      ) async {
    if (isSavingStatus.value) return;

    // Pause ticker momentarily while rendering image
    final bool wasPaused = isTickerPaused.value;
    if (!wasPaused) {
      _autoSlideTimer?.cancel();
    }

    isSavingStatus.value = true;
    try {
      final bool saved = await StatusImageSaverService.saveStatusImageToGallery(
        context: context,
        item: item,
        isUrdu: settingsService.isUrdu,
      );

      Get.snackbar(
        AppConstants.appName,
        saved
            ? AppStrings.statusSavedToGallery.tr
            : AppStrings.statusSaveFailed.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSavingStatus.value = false;
      if (!wasPaused && !isTickerPaused.value) {
        _startAutoSlideTimer();
      }
    }
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    if (dailyFeed.length <= 1 || isTickerPaused.value) return;

    _autoSlideTimer = Timer.periodic(
      AppConstants.liveFeedSlideInterval,
          (_) => _advanceToNextSlide(),
    );
  }

  void _advanceToNextSlide() {
    if (_isUserDragging || isTickerPaused.value || !tickerPageController.hasClients) {
      return;
    }

    final int currentPage = tickerPageController.page?.round() ?? 0;
    tickerPageController.animateToPage(
      currentPage + 1,
      duration: AppConstants.liveFeedTransitionDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  void onTickerPageChanged(int logicalIndex) {
    currentSlideIndex.value = logicalIndex;
  }

  void pauseAutoSlideOnDrag() {
    _isUserDragging = true;
    _autoSlideTimer?.cancel();
  }

  void resumeAutoSlideAfterDrag() {
    _isUserDragging = false;
    if (!isTickerPaused.value) {
      _startAutoSlideTimer();
    }
  }

  void changeTab(int index) {
    if (currentTabIndex.value == index) return;
    currentTabIndex.value = index;
  }

  Future<void> toggleTheme(BuildContext context) async {
    final bool isCurrentlyDark = Theme.of(context).brightness == Brightness.dark;
    await settingsService.toggleLightDarkTheme(isCurrentlyDark);
  }

  Future<void> setAppLanguage(Locale locale) async {
    await settingsService.setLocale(locale);
  }

  @override
  void onClose() {
    _autoSlideTimer?.cancel();
    _prayerClockTimer?.cancel();
    tickerPageController.dispose();
    super.onClose();
  }
}