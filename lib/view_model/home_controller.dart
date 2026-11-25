import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/daily_inspiration_model.dart';
import '../models/islamic_date_info_model.dart';
import '../repositories/daily_inspiration_repository.dart';
import '../res/constants/app_constants.dart';
import '../res/services/settings_service.dart';
import '../res/utils/islamic_calendar_utils.dart';
import 'base_controller.dart';

/// ViewModel for the main Dashboard screen.
/// Drives Hijri/Gregorian date detection, Islamic occasion significance,
/// live API Ayah & Hadith fetching, and infinite 4-second auto-swipe ticker.
class HomeController extends BaseController {
  final SettingsService settingsService = Get.find<SettingsService>();
  late final DailyInspirationRepository _inspirationRepository;

  final RxInt currentTabIndex = 0.obs;
  final Rx<IslamicDateInfoModel> todayDateInfo =
      IslamicCalendarUtils.getTodayInfo().obs;
  final RxList<DailyInspirationModel> dailyFeed = <DailyInspirationModel>[].obs;
  final RxInt currentSlideIndex = 0.obs;
  final RxBool isFeedLoading = false.obs;

  late final PageController tickerPageController;
  Timer? _autoSlideTimer;
  bool _isUserDragging = false;

  static const int _virtualPageMultiplier = 1000;

  @override
  void onInit() {
    super.onInit();
    _inspirationRepository = DailyInspirationRepository(
      settingsService: settingsService,
    );

    tickerPageController = PageController(
      initialPage: _virtualPageMultiplier * 4,
    );

    _refreshTodayDate();
    loadLiveDailyFeed();
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
        _startAutoSlideTimer();
      }
    } finally {
      isFeedLoading.value = false;
    }
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    if (dailyFeed.length <= 1) return;

    _autoSlideTimer = Timer.periodic(
      AppConstants.liveFeedSlideInterval,
          (_) => _advanceToNextSlide(),
    );
  }

  void _advanceToNextSlide() {
    if (_isUserDragging || !tickerPageController.hasClients) return;

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

  void pauseAutoSlide() {
    _isUserDragging = true;
    _autoSlideTimer?.cancel();
  }

  void resumeAutoSlide() {
    _isUserDragging = false;
    _startAutoSlideTimer();
  }

  void changeTab(int index) {
    if (currentTabIndex.value == index) return;
    currentTabIndex.value = index;
  }

  Future<void> toggleTheme(BuildContext context) async {
    final bool isCurrentlyDark = Theme.of(context).brightness == Brightness.dark;
    await settingsService.toggleLightDarkTheme(isCurrentlyDark);
  }

  Future<void> toggleLanguage() async {
    await settingsService.toggleLanguage();
  }

  @override
  void onClose() {
    _autoSlideTimer?.cancel();
    tickerPageController.dispose();
    super.onClose();
  }
}