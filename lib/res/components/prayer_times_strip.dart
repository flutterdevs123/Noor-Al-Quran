import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/prayer_time_slot_model.dart';
import '../constants/app_strings.dart';
import '../responsive/responsive_extensions.dart';
import '../responsive/responsive_utils.dart';
import '../services/prayer_time_service.dart';
import '../theme/app_theme.dart';

/// Horizontal live strip displaying all daily Salah & Sun timings
/// (Fajr, Sunrise/Tulu-e-Aftab, Ishraq, Chasht, Dhuhr, Asr, Maghrib, Isha)
/// along with next prayer countdown.
class PrayerTimesStrip extends StatelessWidget {
  final DailyPrayerSchedule schedule;
  final VoidCallback? onRefreshLocationTap;

  const PrayerTimesStrip({
    super.key,
    required this.schedule,
    this.onRefreshLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final String countdownText = _formatCountdown(schedule.timeUntilNext);

    return Card(
      child: Padding(
        padding: ResponsiveUtils.allPadding(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Top Strip Header: Location Status + Next Prayer Countdown Pill
            Row(
              children: <Widget>[
                Icon(
                  Icons.mosque_rounded,
                  size: 17.sz,
                  color: context.colorScheme.primary,
                ),
                6.hSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppStrings.prayerTimesSectionTitle.tr,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        schedule.isUsingDeviceLocation
                            ? AppStrings.currentLocationLabel.tr
                            : AppStrings.defaultLocationLabel.tr,
                        style: context.textTheme.labelSmall?.copyWith(
                          fontSize: 10.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: ResponsiveUtils.symmetricPadding(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${AppStrings.nextPrayerPrefix.tr}: ${schedule.nextPrayerNameKey.tr} • $countdownText',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            10.vSpace,

            // Horizontal Scrollable Patti of All 8 Timings
            SizedBox(
              height: 82.sz,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: schedule.slots.length,
                separatorBuilder: (_, __) => 8.hSpace,
                itemBuilder: (BuildContext context, int index) {
                  final PrayerTimeSlotModel slot = schedule.slots[index];
                  return _buildSlotPill(context, slot);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotPill(BuildContext context, PrayerTimeSlotModel slot) {
    final bool isActive = slot.isUpcoming;

    return Container(
      width: 88.sz,
      padding: ResponsiveUtils.symmetricPadding(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? context.colorScheme.primary
            : context.appColors.elevatedCardBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isActive
              ? context.colorScheme.primary
              : context.appColors.border,
          width: isActive ? 1.4 : 0.9,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            slot.icon,
            size: 16.sz,
            color: isActive ? context.appColors.onHeroSecondary : slot.accentColor,
          ),
          4.vSpace,
          Text(
            slot.nameKey.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isActive
                  ? context.colorScheme.onPrimary
                  : context.colorScheme.onSurface,
            ),
          ),
          2.vSpace,
          Text(
            slot.formattedTime,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: isActive
                  ? context.appColors.onHeroSecondary
                  : context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCountdown(Duration d) {
    final int hours = d.inHours;
    final int mins = d.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}