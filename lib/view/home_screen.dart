import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../res/components/daily_reflection_carousel.dart';
import '../res/constants/app_constants.dart';
import '../res/constants/app_strings.dart';
import '../res/responsive/responsive_builder.dart';
import '../res/responsive/responsive_extensions.dart';
import '../res/responsive/responsive_scroll_body.dart';
import '../res/responsive/responsive_utils.dart';
import '../res/theme/app_theme.dart';
import '../view_model/home_controller.dart';

/// Main Dashboard screen hosting the Hijri/Gregorian date header,
/// live API Ayah & Hadith ticker, feature cards, and bottom navigation.
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: <Widget>[
          // Multi-Language Switcher Chip (English <-> Urdu)
          TextButton.icon(
            onPressed: controller.toggleLanguage,
            style: TextButton.styleFrom(
              backgroundColor: context.colorScheme.primaryContainer,
              foregroundColor: context.colorScheme.onPrimaryContainer,
              padding: ResponsiveUtils.symmetricPadding(horizontal: 10, vertical: 4),
              minimumSize: Size(44.sz, 34.sz),
            ),
            icon: Icon(Icons.translate_rounded, size: 16.sz),
            label: Text(
              AppStrings.switchLanguageLabel.tr,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          4.hSpace,

          // Theme Mode Toggle Button
          IconButton(
            tooltip: isDark
                ? AppStrings.switchToLightTheme.tr
                : AppStrings.switchToDarkTheme.tr,
            onPressed: () => controller.toggleTheme(context),
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 22.sz,
            ),
          ),
          6.hSpace,
        ],
      ),
      body: ResponsiveScrollBody(
        onRefresh: () => controller.loadLiveDailyFeed(forceRefresh: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Top Dual-Calendar + Live Ayah & Hadith Auto-Swiping Card
            Obx(
                  () => DailyReflectionCarousel(
                dateInfo: controller.todayDateInfo.value,
                items: controller.dailyFeed.toList(),
                pageController: controller.tickerPageController,
                activeIndex: controller.currentSlideIndex.value,
                isUrdu: controller.settingsService.isUrdu,
                isLoadingFeed: controller.isFeedLoading.value,
                onPageChanged: controller.onTickerPageChanged,
                onUserDragStart: controller.pauseAutoSlide,
                onUserDragEnd: controller.resumeAutoSlide,
                onRefreshTap: () => controller.loadLiveDailyFeed(forceRefresh: true),
              ),
            ),
            20.vSpace,

            // Section Heading
            Text(
              AppStrings.quickAccessTitle.tr,
              style: context.textTheme.titleLarge,
            ),
            12.vSpace,

            // Adaptive Feature Cards (1 column in portrait, 2 balanced columns in landscape/tablet)
            ResponsiveBuilder(
              mobile: (BuildContext ctx) => _buildFeatureList(ctx, crossAxisCount: 1),
              landscape: (BuildContext ctx) => _buildFeatureList(ctx, crossAxisCount: 2),
              tablet: (BuildContext ctx) => _buildFeatureList(ctx, crossAxisCount: 2),
            ),
            24.vSpace,
          ],
        ),
      ),
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

  Widget _buildFeatureList(BuildContext context, {required int crossAxisCount}) {
    final List<_DashboardFeatureItem> items = <_DashboardFeatureItem>[
      _DashboardFeatureItem(
        title: AppStrings.featureQuranTitle.tr,
        subtitle: AppStrings.featureQuranSubtitle.tr,
        icon: Icons.menu_book_rounded,
      ),
      _DashboardFeatureItem(
        title: AppStrings.featureAudioTitle.tr,
        subtitle: AppStrings.featureAudioSubtitle.tr,
        icon: Icons.headphones_rounded,
      ),
      _DashboardFeatureItem(
        title: AppStrings.featurePrayerTitle.tr,
        subtitle: AppStrings.featurePrayerSubtitle.tr,
        icon: Icons.mosque_rounded,
      ),
      _DashboardFeatureItem(
        title: AppStrings.featureDailyTitle.tr,
        subtitle: AppStrings.featureDailySubtitle.tr,
        icon: Icons.auto_awesome_rounded,
      ),
      _DashboardFeatureItem(
        title: AppStrings.featureTilawatTitle.tr,
        subtitle: AppStrings.featureTilawatSubtitle.tr,
        icon: Icons.mic_none_rounded,
        isBadgeVisible: true,
      ),
    ];

    if (crossAxisCount == 1) {
      return Column(
        children: items
            .map(
              (_DashboardFeatureItem item) => Padding(
            padding: EdgeInsetsDirectional.only(bottom: 12.sz),
            child: _buildFeatureCard(context, item),
          ),
        )
            .toList(),
      );
    }

    // Equal-height 2-column rows for Landscape and Tablet viewports
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final _DashboardFeatureItem first = items[i];
      final _DashboardFeatureItem? second =
      (i + 1 < items.length) ? items[i + 1] : null;

      rows.add(
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: 12.sz),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: _buildFeatureCard(context, first)),
                12.hSpace,
                Expanded(
                  child: second != null
                      ? _buildFeatureCard(context, second)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildFeatureCard(BuildContext context, _DashboardFeatureItem item) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          // Will navigate to respective feature screens as they are added in upcoming steps.
        },
        child: Padding(
          padding: ResponsiveUtils.allPadding(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 46.sz,
                height: 46.sz,
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  item.icon,
                  size: 23.sz,
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
              12.hSpace,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 8.sz,
                      runSpacing: 4.sz,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          item.title,
                          style: context.textTheme.titleMedium,
                        ),
                        if (item.isBadgeVisible)
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
                    4.vSpace,
                    Text(
                      item.subtitle,
                      maxLines: 3,
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
}

class _DashboardFeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isBadgeVisible;

  const _DashboardFeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isBadgeVisible = false,
  });
}