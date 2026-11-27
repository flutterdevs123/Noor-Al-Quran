import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/daily_inspiration_model.dart';
import '../../models/islamic_date_info_model.dart';
import '../constants/app_strings.dart';
import '../responsive/responsive_extensions.dart';
import '../responsive/responsive_utils.dart';
import '../theme/app_theme.dart';

/// Top hero card displaying:
/// - Special Islamic occasion banner (when applicable)
/// - Live Ayah & Hadith infinite loop with Pause/Resume control
/// - Download as Status Image to Gallery action
/// - Clean, dignified bottom Reference bar
class DailyReflectionCarousel extends StatelessWidget {
  final IslamicDateInfoModel dateInfo;
  final List<DailyInspirationModel> items;
  final PageController pageController;
  final int activeIndex;
  final bool isUrdu;
  final bool isLoadingFeed;
  final bool isPaused;
  final bool isSavingStatus;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onUserDragStart;
  final VoidCallback onUserDragEnd;
  final VoidCallback onTogglePause;
  final VoidCallback onRefreshTap;
  final ValueChanged<DailyInspirationModel> onDownloadStatusTap;

  const DailyReflectionCarousel({
    super.key,
    required this.dateInfo,
    required this.items,
    required this.pageController,
    required this.activeIndex,
    required this.isUrdu,
    required this.isLoadingFeed,
    required this.isPaused,
    required this.isSavingStatus,
    required this.onPageChanged,
    required this.onUserDragStart,
    required this.onUserDragEnd,
    required this.onTogglePause,
    required this.onRefreshTap,
    required this.onDownloadStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasOccasion = dateInfo.hasSpecialOccasion;
    final double feedHeight = isUrdu ? 248.sz : 220.sz;

    return Container(
      decoration: BoxDecoration(
        gradient: context.appColors.heroGradient,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: context.appColors.onHeroSecondary.withValues(alpha: 0.45),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.colorScheme.shadow,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Special Islamic Occasion Strip (e.g. 10 Dhul Hijjah Qurbani, Ramadan, Jummah)
            if (hasOccasion) _buildOccasionBanner(context),

            // Main Slide Area
            SizedBox(
              height: feedHeight,
              child: isLoadingFeed && items.isEmpty
                  ? _buildLoadingPlaceholder(context)
                  : _buildTickerBody(context),
            ),

            // Bottom Pagination Dots
            if (items.length > 1)
              Padding(
                padding: EdgeInsetsDirectional.only(bottom: 10.sz, top: 2.sz),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(items.length, (int index) {
                    final bool isSelected = index == activeIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.symmetric(horizontal: 3.sz),
                      width: isSelected ? 18.sz : 6.sz,
                      height: 6.sz,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.appColors.onHeroSecondary
                            : context.appColors.onHeroPrimary.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccasionBanner(BuildContext context) {
    final String title = dateInfo.localizedOccasionTitle(isUrdu: isUrdu) ?? '';
    final String subtitle = dateInfo.localizedOccasionSubtitle(isUrdu: isUrdu) ?? '';

    return Container(
      padding: ResponsiveUtils.symmetricPadding(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.onHeroSecondary.withValues(alpha: 0.16),
        border: Border(
          bottom: BorderSide(
            color: context.appColors.onHeroSecondary.withValues(alpha: 0.28),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.auto_awesome_rounded,
            size: 16.sz,
            color: context.appColors.onHeroSecondary,
          ),
          8.hSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.appColors.onHeroSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.appColors.onHeroPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 24.sz,
            height: 24.sz,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: context.appColors.onHeroSecondary,
            ),
          ),
          10.vSpace,
          Text(
            AppStrings.loadingLiveFeed.tr,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.appColors.onHeroMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTickerBody(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification &&
            notification.dragDetails != null) {
          onUserDragStart();
        } else if (notification is ScrollEndNotification) {
          onUserDragEnd();
        }
        return false;
      },
      child: PageView.builder(
        controller: pageController,
        onPageChanged: (int virtualIndex) {
          onPageChanged(virtualIndex % items.length);
        },
        itemBuilder: (BuildContext context, int virtualIndex) {
          final DailyInspirationModel item = items[virtualIndex % items.length];
          return _buildSlide(context, item);
        },
      ),
    );
  }

  Widget _buildSlide(BuildContext context, DailyInspirationModel item) {
    final String badgeLabel = item.isAyah
        ? AppStrings.dailyAyahBadge.tr
        : AppStrings.dailyHadithBadge.tr;

    final TextStyle arabicStyle = item.isAyah
        ? AppTheme.quranTextStyle(
      context: context,
      fontSize: 20.sp,
      height: 1.85,
    ).copyWith(color: context.appColors.onHeroPrimary)
        : AppTheme.arabicHadithTextStyle(
      context: context,
      fontSize: 19.sp,
      height: 1.75,
    ).copyWith(color: context.appColors.onHeroPrimary);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.sz, 12.sz, 12.sz, 6.sz),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Top Control Row: Ayah/Hadith Badge + Pause/Resume + Refresh + Download Status
          Row(
            children: <Widget>[
              Container(
                padding: ResponsiveUtils.symmetricPadding(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.appColors.onHeroSecondary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: context.appColors.onHeroSecondary.withValues(alpha: 0.75),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      item.isAyah
                          ? Icons.menu_book_rounded
                          : Icons.format_quote_rounded,
                      size: 13.sz,
                      color: context.appColors.onHeroSecondary,
                    ),
                    5.hSpace,
                    Text(
                      badgeLabel,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.appColors.onHeroSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Pause / Resume Auto-Swipe Button
              _buildActionChipButton(
                context: context,
                tooltip: isPaused
                    ? AppStrings.resumeTickerTooltip.tr
                    : AppStrings.pauseTickerTooltip.tr,
                icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                label: isPaused ? AppStrings.pausedLabel.tr : AppStrings.liveLabel.tr,
                isHighlighted: isPaused,
                onTap: onTogglePause,
              ),
              4.hSpace,

              // Download Status Image to Gallery Button
              IconButton(
                tooltip: AppStrings.downloadStatusTooltip.tr,
                onPressed: isSavingStatus ? null : () => onDownloadStatusTap(item),
                constraints: BoxConstraints.tightFor(width: 34.sz, height: 34.sz),
                padding: EdgeInsets.zero,
                icon: isSavingStatus
                    ? SizedBox(
                  width: 15.sz,
                  height: 15.sz,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.appColors.onHeroSecondary,
                  ),
                )
                    : Icon(
                  Icons.download_rounded,
                  size: 19.sz,
                  color: context.appColors.onHeroSecondary,
                ),
              ),

              // Refresh Live Feed Button
              IconButton(
                tooltip: AppStrings.refreshFeedTooltip.tr,
                onPressed: isLoadingFeed ? null : onRefreshTap,
                constraints: BoxConstraints.tightFor(width: 32.sz, height: 32.sz),
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 18.sz,
                  color: context.appColors.onHeroPrimary.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          8.vSpace,

          // Center Arabic Verse / Hadith Text (Always RTL)
          Expanded(
            flex: 3,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SingleChildScrollView(
                physics: isPaused
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: Text(
                  item.arabicText,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.start,
                  maxLines: isPaused ? 6 : 2,
                  overflow: isPaused ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: arabicStyle,
                ),
              ),
            ),
          ),
          4.vSpace,

          // Translation Text
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              physics: isPaused
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: Text(
                item.localizedTranslation(isUrdu: isUrdu),
                maxLines: isPaused ? 5 : 2,
                overflow: isPaused ? TextOverflow.visible : TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.appColors.onHeroMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          6.vSpace,

          // Dedicated Bottom Reference Bar (Balanced, prominent placement)
          Container(
            padding: ResponsiveUtils.symmetricPadding(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.appColors.onHeroPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.bookmark_border_rounded,
                  size: 13.sz,
                  color: context.appColors.onHeroSecondary,
                ),
                6.hSpace,
                Expanded(
                  child: Text(
                    item.localizedReference(isUrdu: isUrdu),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.appColors.onHeroSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChipButton({
    required BuildContext context,
    required String tooltip,
    required IconData icon,
    required String label,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          padding: ResponsiveUtils.symmetricPadding(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHighlighted
                ? context.appColors.onHeroSecondary
                : context.appColors.onHeroPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 14.sz,
                color: isHighlighted
                    ? context.colorScheme.onSecondary
                    : context.appColors.onHeroPrimary,
              ),
              3.hSpace,
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  color: isHighlighted
                      ? context.colorScheme.onSecondary
                      : context.appColors.onHeroPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}