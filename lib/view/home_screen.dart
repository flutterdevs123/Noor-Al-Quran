import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../res/components/daily_reflection_carousel.dart';
import '../res/components/dual_calendar_sheet.dart';
import '../res/components/prayer_times_strip.dart';
import '../res/constants/app_constants.dart';
import '../res/constants/app_strings.dart';
import '../res/responsive/responsive_extensions.dart';
import '../res/responsive/responsive_scroll_body.dart';
import '../res/responsive/responsive_utils.dart';
import '../res/routes/app_routes.dart';
import '../res/services/settings_service.dart';
import '../res/theme/app_theme.dart';
import '../view_model/audio_quran_controller.dart';
import '../view_model/home_controller.dart';
import '../view_model/quran_reader_controller.dart';
import 'quran_index_view.dart';

/// Main Dashboard screen hosting:
/// - AppBar with Noor Al-Quran brand title & interactive Hijri/Gregorian calendar button
/// - Tab 0: Live Ayah/Hadith ticker, Prayer strip, Audio Tilawat, Offline Quran & Essentials
/// - Tab 1: Complete Offline Quran Index (114 Surahs, 30 Paras, Bookmarks)
/// - Tab 3: Language, Theme Appearance & Data Credits
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  void _openDualCalendar(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return DualCalendarSheet(
          initialHijriOffset: controller.settingsService.hijriDayOffset.value,
          isUrdu: controller.settingsService.isUrdu,
          onOffsetChanged: controller.updateHijriOffset,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 12.sz,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 28.sz,
              height: 28.sz,
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 16.sz,
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
            8.hSpace,
            Flexible(
              child: Text(
                AppConstants.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          // Compact Interactive Date & Calendar Trigger Pill
          Obx(() {
            final bool isUrdu = controller.settingsService.isUrdu;
            final info = controller.todayDateInfo.value;
            final String compactGregorian = isUrdu
                ? info.formattedGregorian(isUrdu: true)
                : DateFormat('d MMM yy').format(DateTime.now());

            return Tooltip(
              message: AppStrings.openCalendarTooltip.tr,
              child: InkWell(
                borderRadius: BorderRadius.circular(10.r),
                onTap: () => _openDualCalendar(context),
                child: Container(
                  padding: ResponsiveUtils.symmetricPadding(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: context.colorScheme.primary.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            info.formattedHijri(isUrdu: isUrdu),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w700,
                              color: context.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            compactGregorian,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: 8.5.sp,
                              color: context.colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      4.hSpace,
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 15.sz,
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          2.hSpace,

          // Compact Theme Mode Toggle Button
          IconButton(
            tooltip: isDark
                ? AppStrings.switchToLightTheme.tr
                : AppStrings.switchToDarkTheme.tr,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.all(6.sz),
            constraints: BoxConstraints(
              minWidth: 34.sz,
              minHeight: 34.sz,
            ),
            onPressed: () => controller.toggleTheme(context),
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 19.sz,
            ),
          ),
          6.hSpace,
        ],
      ),
      body: Obx(() {
        switch (controller.currentTabIndex.value) {
          case 1:
            return const QuranIndexView();
          case 3:
            return _buildSettingsBody(context);
          default:
            return _buildHomeDashboardBody(context);
        }
      }),
      bottomNavigationBar: Obx(
            () => NavigationBar(
          selectedIndex: controller.currentTabIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: AppStrings.navHome.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book_rounded),
              label: AppStrings.navQuran.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.access_time_outlined),
              selectedIcon: const Icon(Icons.access_time_filled_rounded),
              label: AppStrings.navPrayer.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: AppStrings.navSettings.tr,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeDashboardBody(BuildContext context) {
    return ResponsiveScrollBody(
      onRefresh: () => controller.loadLiveDailyFeed(forceRefresh: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1. Top Live Ayah & Hadith Ticker Card
          Obx(
                () => DailyReflectionCarousel(
              dateInfo: controller.todayDateInfo.value,
              items: controller.dailyFeed.toList(),
              pageController: controller.tickerPageController,
              activeIndex: controller.currentSlideIndex.value,
              isUrdu: controller.settingsService.isUrdu,
              isLoadingFeed: controller.isFeedLoading.value,
              isPaused: controller.isTickerPaused.value,
              isSavingStatus: controller.isSavingStatus.value,
              onPageChanged: controller.onTickerPageChanged,
              onUserDragStart: controller.pauseAutoSlideOnDrag,
              onUserDragEnd: controller.resumeAutoSlideAfterDrag,
              onTogglePause: controller.toggleTickerPause,
              onRefreshTap: () => controller.loadLiveDailyFeed(forceRefresh: true),
              onDownloadStatusTap: (item) =>
                  controller.saveItemAsStatusImage(context, item),
            ),
          ),
          14.vSpace,

          // 2. Live Nimazon & Sun Timings Strip
          Obx(
                () => PrayerTimesStrip(
              schedule: controller.prayerSchedule.value,
            ),
          ),
          14.vSpace,

          // 3. Audio Tilawat Player Bar Card (Top 20 Qaris + Offline + Notification Player)
          _buildAudioTilawatCard(context),
          12.vSpace,

          // 4. Offline Quran Recitation Card (with Saved Reading Progress)
          _buildOfflineQuranCard(context),
          12.vSpace,

          // 5. Quran Tilawat Correction Module Card
          _buildQuranCorrectionCard(context),
          16.vSpace,

          // 6. Islamic Essentials Section (Qibla Finder, Tasbih, Daily Duas)
          Text(
            AppStrings.islamicEssentialsTitle.tr,
            style: context.textTheme.titleMedium,
          ),
          10.vSpace,
          _buildIslamicEssentialsRow(context),
          24.vSpace,
        ],
      ),
    );
  }

  Widget _buildAudioTilawatCard(BuildContext context) {
    final AudioQuranController audioCtrl = Get.find<AudioQuranController>();

    return Obx(() {
      final activeSurah = audioCtrl.currentSurah.value;
      final bool isPlaying = audioCtrl.isPlaying.value;

      return Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => Get.toNamed(AppRoutes.audioQuran),
          child: Padding(
            padding: ResponsiveUtils.allPadding(14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48.sz,
                  height: 48.sz,
                  decoration: BoxDecoration(
                    gradient: context.appColors.heroGradient,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    isPlaying ? Icons.graphic_eq_rounded : Icons.headphones_rounded,
                    size: 24.sz,
                    color: context.appColors.onHeroSecondary,
                  ),
                ),
                12.hSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        activeSurah != null
                            ? 'Surah ${activeSurah.englishName} (${activeSurah.arabicName})'
                            : AppStrings.audioTilawatTitle.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleMedium,
                      ),
                      3.vSpace,
                      Text(
                        activeSurah != null
                            ? audioCtrl.selectedQari.value.name
                            : AppStrings.audioTilawatSubtitle.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                8.hSpace,
                Container(
                  padding: ResponsiveUtils.symmetricPadding(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 16.sz,
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                      2.hSpace,
                      Text(
                        isPlaying ? 'Playing' : AppStrings.openPlayerLabel.tr,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOfflineQuranCard(BuildContext context) {
    final QuranReaderController quranCtrl = Get.find<QuranReaderController>();

    return Obx(() {
      final int surah = controller.settingsService.lastReadSurah.value;
      final int ayah = controller.settingsService.lastReadAyah.value;

      return Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => controller.changeTab(1),
          child: Padding(
            padding: ResponsiveUtils.allPadding(14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48.sz,
                  height: 48.sz,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 24.sz,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
                12.hSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppStrings.offlineQuranTitle.tr,
                        style: context.textTheme.titleMedium,
                      ),
                      3.vSpace,
                      Text(
                        AppStrings.offlineQuranSubtitle.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                8.hSpace,
                InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () => quranCtrl.openSurah(
                    surahNumber: surah,
                    initialAyah: ayah,
                  ),
                  child: Container(
                    padding: ResponsiveUtils.symmetricPadding(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          AppStrings.continueReadingLabel.tr,
                          style: context.textTheme.labelSmall?.copyWith(
                            fontSize: 10.sp,
                            color: context.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$surah:$ayah',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildQuranCorrectionCard(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {},
        child: Padding(
          padding: ResponsiveUtils.allPadding(14),
          child: Row(
            children: <Widget>[
              Container(
                width: 48.sz,
                height: 48.sz,
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.mic_rounded,
                  size: 24.sz,
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
              12.hSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 8.sz,
                      runSpacing: 4.sz,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          AppStrings.featureTilawatTitle.tr,
                          style: context.textTheme.titleMedium,
                        ),
                        Container(
                          padding: ResponsiveUtils.symmetricPadding(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            AppStrings.comingSoon.tr,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    3.vSpace,
                    Text(
                      AppStrings.featureTilawatSubtitle.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              8.hSpace,
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15.sz,
                color: context.appColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIslamicEssentialsRow(BuildContext context) {
    final List<({String title, IconData icon})> tools =
    <({String title, IconData icon})>[
      (title: AppStrings.toolQiblaTitle.tr, icon: Icons.explore_rounded),
      (title: AppStrings.toolTasbihTitle.tr, icon: Icons.radio_button_checked_rounded),
      (title: AppStrings.toolDuasTitle.tr, icon: Icons.volunteer_activism_rounded),
    ];

    return Row(
      children: List<Widget>.generate(tools.length, (int index) {
        final tool = tools[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: index < tools.length - 1 ? 10.sz : 0,
            ),
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: () {},
                child: Padding(
                  padding: ResponsiveUtils.symmetricPadding(
                    horizontal: 8,
                    vertical: 14,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 40.sz,
                        height: 40.sz,
                        decoration: BoxDecoration(
                          color: context.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          tool.icon,
                          size: 20.sz,
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      8.vSpace,
                      Text(
                        tool.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Dedicated Settings Tab housing App Language, Theme Appearance, and Data Credits.
  Widget _buildSettingsBody(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveScrollBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            AppStrings.settingsTitle.tr,
            style: context.textTheme.headlineSmall,
          ),
          14.vSpace,

          // Language Selector Card
          Card(
            child: Padding(
              padding: ResponsiveUtils.allPadding(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.translate_rounded,
                        color: context.colorScheme.primary,
                      ),
                      10.hSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AppStrings.appLanguageTitle.tr,
                              style: context.textTheme.titleMedium,
                            ),
                            Text(
                              AppStrings.appLanguageSubtitle.tr,
                              style: context.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  14.vSpace,
                  Obx(() {
                    final bool isUrdu = controller.settingsService.isUrdu;
                    return SegmentedButton<String>(
                      segments: const <ButtonSegment<String>>[
                        ButtonSegment<String>(
                          value: 'en',
                          label: Text('English'),
                        ),
                        ButtonSegment<String>(
                          value: 'ur',
                          label: Text('اردو'),
                        ),
                      ],
                      selected: <String>{isUrdu ? 'ur' : 'en'},
                      onSelectionChanged: (Set<String> selection) {
                        final String code = selection.first;
                        controller.setAppLanguage(
                          code == 'ur'
                              ? SettingsService.urduLocale
                              : SettingsService.englishLocale,
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          12.vSpace,

          // Theme Mode Card
          Card(
            child: ListTile(
              leading: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: context.colorScheme.primary,
              ),
              title: Text(AppStrings.appearanceTitle.tr),
              subtitle: Text(
                isDark
                    ? AppStrings.darkModeLabel.tr
                    : AppStrings.lightModeLabel.tr,
              ),
              trailing: Switch(
                value: isDark,
                onChanged: (_) => controller.toggleTheme(context),
              ),
            ),
          ),
          12.vSpace,

          // Credits & Data Sources Card
          Card(
            child: ListTile(
              leading: Icon(
                Icons.verified_user_rounded,
                color: context.colorScheme.primary,
              ),
              title: const Text('Credits & Data Sources'),
              subtitle: const Text(
                'Acknowledgements for Quran text, audio Qaris & APIs',
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sz,
                color: context.appColors.textTertiary,
              ),
              onTap: () => Get.toNamed(AppRoutes.credits),
            ),
          ),
        ],
      ),
    );
  }
}