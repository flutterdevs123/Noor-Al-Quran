import 'package:flutter/material.dart';

/// Represents a single daily prayer or sun event slot (Fajr, Sunrise, Ishraq, Chasht, Dhuhr, Asr, Maghrib, Isha).
class PrayerTimeSlotModel {
  final String id;
  final String nameKey;
  final DateTime dateTime;
  final String formattedTime;
  final IconData icon;
  final Color accentColor;
  final bool isUpcoming;
  final bool isSunEvent;

  const PrayerTimeSlotModel({
    required this.id,
    required this.nameKey,
    required this.dateTime,
    required this.formattedTime,
    required this.icon,
    required this.accentColor,
    this.isUpcoming = false,
    this.isSunEvent = false,
  });
}