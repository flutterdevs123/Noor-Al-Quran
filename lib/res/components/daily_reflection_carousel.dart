import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/daily_inspiration_model.dart';
import '../../models/islamic_date_info_model.dart';
import '../constants/app_strings.dart';
import '../responsive/responsive_extensions.dart';
import '../responsive/responsive_utils.dart';
import '../theme/app_theme.dart';

/// Reusable top dashboard card displaying:
/// 1. Dual Hijri (Madani) & Gregorian calendar header
/// 2. Special Islamic occasion significance strip (when applicable)
/// 3. Infinite 4-second auto-swiping live Quran Ayah & Sahih Hadith feed
class DailyReflectionCarousel extends StatelessWidget {
  final IslamicDateInfoModel dateInfo;
  final List<DailyInspirationModel> items;
  final PageController pageController;
  final int activeIndex;
  final bool isUrdu;
  final bool isLoadingFeed;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onUserDragStart;
  final VoidCallback onUserDragEnd;
  final VoidCallback onRefreshTap;
  final ValueChanged<DailyInspirationModel>? onItemTap;

  const DailyReflectionCarousel({
    super.key,
    required this.dateInfo,
    required this.items,
    required this.pageController,
    required this.activeIndex,
    required this.isUrdu,
    required this.isLoadingFeed,
    required this.onPageChanged,
    required this.onUserDragStart,
    required this.onUserDragEnd,
    required this.onRefreshTap,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasOccasion = dateInfo.hasSpecialOccasion;
    final double feedHeight = isUrdu ? 210.sz : 185.sz;

    return Container(
      decoration: BoxDecoration(
        gradient: context.appColors.heroGradient,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: context.appColors.onHeroSecondary.withValues(alpha: 0.45),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.colorScheme.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Dual Hijri (Islamic) & Gregorian Date Header Bar
            _buildCalendarHeader(context),

            // 2. Special Islamic Occasion Significance Banner (e.g., 10 Dhul Hijjah Qurbani)
            if (hasOccasion) _buildOccasionBanner(context),

            // 3. Live Auto-Swiping Ayah & Hadith Feed
            SizedBox(
              height: feedHeight,
              child: isLoadingFeed && items.isEmpty
                  ? _buildLoadingPlaceholder(context)
                  : _buildTickerBody(context),
            ),

            // 4. Bottom Pagination Dots
            if (items.length > 1)
              Padding(
                padding: EdgeInsetsDirectional.only(bottom: 10.sz),
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

  Widget _buildCalendarHeader(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.symmetricPadding(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.appColors.onHeroPrimary.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(
            color: context.appColors.onHeroSecondary.withValues(alpha: 0.25),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.calendar_month_rounded,
            size: 18.sz,
            color: context.appColors.onHeroSecondary,
          ),
          8.hSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  dateInfo.formattedHijri(isUrdu: isUrdu),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.appColors.onHeroSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  dateInfo.formattedGregorian(isUrdu: isUrdu),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.appColors.onHeroMuted,
                  ),
                ),
              ],
            ),
          ),
          // Manual Refresh Button for fetching new random Ayah & Hadith
          IconButton(
            tooltip: AppStrings.refreshFeedTooltip.tr,
            onPressed: isLoadingFeed ? null : onRefreshTap,
            constraints: BoxConstraints.tightFor(width: 34.sz, height: 34.sz),
            padding: EdgeInsets.zero,
            icon: isLoadingFeed
                ? SizedBox(
              width: 15.sz,
              height: 15.sz,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.appColors.onHeroSecondary,
              ),
            )
                : Icon(
              Icons.refresh_rounded,
              size: 18.sz,
              color: context.appColors.onHeroPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccasionBanner(BuildContext context) {
    final String title = dateInfo.localizedOccasionTitle(isUrdu: isUrdu) ?? '';
    final String subtitle = dateInfo.localizedOccasionSubtitle(isUrdu: isUrdu) ?? '';

    return Container(
      padding: ResponsiveUtils.symmetricPadding(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.onHeroSecondary.withValues(alpha: 0.18),
        border: Border(
          bottom: BorderSide(
            color: context.appColors.onHeroSecondary.withValues(alpha: 0.30),
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
      fontSize: 19.sp,
      height: 1.8,
    ).copyWith(color: context.appColors.onHeroPrimary)
        : AppTheme.arabicHadithTextStyle(
      context: context,
      fontSize: 18.5.sp,
      height: 1.7,
    ).copyWith(color: context.appColors.onHeroPrimary);

    return InkWell(
      onTap: onItemTap != null ? () => onItemTap!(item) : null,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(14.sz, 10.sz, 14.sz, 6.sz),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Type Badge ("Daily Ayah" / "Daily Hadith") + Authentic Reference
            Row(
              children: <Widget>[
                Container(
                  padding: ResponsiveUtils.symmetricPadding(
                    horizontal: 9,
                    vertical: 2,
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
                8.hSpace,
                Expanded(
                  child: Text(
                    item.localizedReference(isUrdu: isUrdu),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.appColors.onHeroMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            6.vSpace,

            // Arabic Text (Always RTL)
            Flexible(
              flex: 3,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  item.arabicText,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: arabicStyle,
                ),
              ),
            ),
            4.vSpace,

            // Live API Translation (English or Urdu)
            Flexible(
              flex: 2,
              child: Text(
                item.localizedTranslation(isUrdu: isUrdu),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.appColors.onHeroMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}