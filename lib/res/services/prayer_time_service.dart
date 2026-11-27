import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/prayer_time_slot_model.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

/// Result bundle containing all 8 daily prayer/sun slots and next prayer countdown info.
class DailyPrayerSchedule {
  final List<PrayerTimeSlotModel> slots;
  final String nextPrayerNameKey;
  final Duration timeUntilNext;
  final bool isUsingDeviceLocation;

  const DailyPrayerSchedule({
    required this.slots,
    required this.nextPrayerNameKey,
    required this.timeUntilNext,
    required this.isUsingDeviceLocation,
  });
}

/// Calculates accurate offline astronomical prayer and sun timings (Fajr, Sunrise,
/// Ishraq, Chasht, Dhuhr, Asr, Maghrib, Isha) using the user's device coordinates.
class PrayerTimeService {
  double _cachedLat = AppConstants.defaultLatitude;
  double _cachedLng = AppConstants.defaultLongitude;
  bool _hasDeviceCoords = false;

  /// Attempts to acquire user's device coordinates gracefully without blocking UI.
  Future<void> resolveLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        _cachedLat = lastKnown.latitude;
        _cachedLng = lastKnown.longitude;
        _hasDeviceCoords = true;
      }

      final Position current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 6),
        ),
      );
      _cachedLat = current.latitude;
      _cachedLng = current.longitude;
      _hasDeviceCoords = true;
    } catch (e) {
      debugPrint('[PrayerTimeService] Using fallback coordinates: $e');
    }
  }

  /// Computes today's complete schedule including Ishraq and Chasht (Duha).
  DailyPrayerSchedule computeTodaySchedule({DateTime? referenceNow}) {
    final DateTime now = referenceNow ?? DateTime.now();
    final Coordinates coords = Coordinates(_cachedLat, _cachedLng);
    final CalculationParameters params = CalculationMethod.karachi.getParameters()
      ..madhab = Madhab.hanafi;

    final DateComponents dateComponents = DateComponents.from(now);
    final PrayerTimes todayTimes = PrayerTimes(coords, dateComponents, params);

    // Astronomical & Fiqh-aligned Sun Windows
    final DateTime fajrTime = todayTimes.fajr.toLocal();
    final DateTime sunriseTime = todayTimes.sunrise.toLocal(); // Tulu-e-Aftab
    final DateTime ishraqTime = sunriseTime.add(const Duration(minutes: 15));
    final DateTime chashtTime = sunriseTime.add(const Duration(minutes: 45));
    final DateTime dhuhrTime = todayTimes.dhuhr.toLocal();
    final DateTime asrTime = todayTimes.asr.toLocal();
    final DateTime maghribTime = todayTimes.maghrib.toLocal();
    final DateTime ishaTime = todayTimes.isha.toLocal();

    final List<_RawSlot> rawSlots = <_RawSlot>[
      _RawSlot(
        id: 'fajr',
        nameKey: AppStrings.prayerFajr,
        time: fajrTime,
        icon: Icons.wb_twilight_rounded,
        color: AppColors.prayerFajr,
      ),
      _RawSlot(
        id: 'sunrise',
        nameKey: AppStrings.prayerSunrise,
        time: sunriseTime,
        icon: Icons.wb_sunny_outlined,
        color: AppColors.prayerSunrise,
        isSunEvent: true,
      ),
      _RawSlot(
        id: 'ishraq',
        nameKey: AppStrings.prayerIshraq,
        time: ishraqTime,
        icon: Icons.light_mode_rounded,
        color: AppColors.prayerSunrise,
        isSunEvent: true,
      ),
      _RawSlot(
        id: 'chasht',
        nameKey: AppStrings.prayerChasht,
        time: chashtTime,
        icon: Icons.sunny,
        color: AppColors.accentLight,
        isSunEvent: true,
      ),
      _RawSlot(
        id: 'dhuhr',
        nameKey: AppStrings.prayerDhuhr,
        time: dhuhrTime,
        icon: Icons.wb_sunny_rounded,
        color: AppColors.prayerDhuhr,
      ),
      _RawSlot(
        id: 'asr',
        nameKey: AppStrings.prayerAsr,
        time: asrTime,
        icon: Icons.wb_cloudy_rounded,
        color: AppColors.prayerAsr,
      ),
      _RawSlot(
        id: 'maghrib',
        nameKey: AppStrings.prayerMaghrib,
        time: maghribTime,
        icon: Icons.nights_stay_outlined,
        color: AppColors.prayerMaghrib,
      ),
      _RawSlot(
        id: 'isha',
        nameKey: AppStrings.prayerIsha,
        time: ishaTime,
        icon: Icons.bedtime_rounded,
        color: AppColors.prayerIsha,
      ),
    ];

    // Determine next upcoming slot
    int upcomingIndex = rawSlots.indexWhere((_RawSlot s) => s.time.isAfter(now));
    String nextKey;
    Duration remaining;

    if (upcomingIndex == -1) {
      // After Isha: next prayer is tomorrow's Fajr
      upcomingIndex = 0;
      final DateComponents tomorrowComp =
      DateComponents.from(now.add(const Duration(days: 1)));
      final DateTime tomorrowFajr =
      PrayerTimes(coords, tomorrowComp, params).fajr.toLocal();
      nextKey = AppStrings.prayerFajr;
      remaining = tomorrowFajr.difference(now);
    } else {
      nextKey = rawSlots[upcomingIndex].nameKey;
      remaining = rawSlots[upcomingIndex].time.difference(now);
    }

    final List<PrayerTimeSlotModel> models =
    List<PrayerTimeSlotModel>.generate(rawSlots.length, (int i) {
      final _RawSlot s = rawSlots[i];
      return PrayerTimeSlotModel(
        id: s.id,
        nameKey: s.nameKey,
        dateTime: s.time,
        formattedTime: _format12Hour(s.time),
        icon: s.icon,
        accentColor: s.color,
        isUpcoming: i == upcomingIndex,
        isSunEvent: s.isSunEvent,
      );
    });

    return DailyPrayerSchedule(
      slots: models,
      nextPrayerNameKey: nextKey,
      timeUntilNext: remaining.isNegative ? Duration.zero : remaining,
      isUsingDeviceLocation: _hasDeviceCoords,
    );
  }

  String _format12Hour(DateTime dt) {
    final int hour24 = dt.hour;
    final int hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final String minuteStr = dt.minute.toString().padLeft(2, '0');
    final String period = hour24 >= 12 ? 'PM' : 'AM';
    return '$hour12:$minuteStr $period';
  }
}

class _RawSlot {
  final String id;
  final String nameKey;
  final DateTime time;
  final IconData icon;
  final Color color;
  final bool isSunEvent;

  const _RawSlot({
    required this.id,
    required this.nameKey,
    required this.time,
    required this.icon,
    required this.color,
    this.isSunEvent = false,
  });
}