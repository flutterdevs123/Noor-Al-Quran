/// Represents today's Hijri (Islamic) & Gregorian dates along with any
/// special Islamic occasion (e.g. 10 Dhul Hijjah Qurbani, Eid, Ramadan, Jummah).
class IslamicDateInfoModel {
  final int hijriDay;
  final int hijriMonth;
  final int hijriYear;
  final String hijriFormattedEn;
  final String hijriFormattedUr;
  final String gregorianFormattedEn;
  final String gregorianFormattedUr;

  // Special Occasion Metadata (Null on regular days)
  final String? occasionTitleEn;
  final String? occasionTitleUr;
  final String? occasionSubtitleEn;
  final String? occasionSubtitleUr;

  // Curated Ayah (`surah:ayah`) & Sahih Bukhari Hadith Number for this occasion
  final String? occasionAyahRef;
  final int? occasionBukhariNumber;

  const IslamicDateInfoModel({
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
    required this.hijriFormattedEn,
    required this.hijriFormattedUr,
    required this.gregorianFormattedEn,
    required this.gregorianFormattedUr,
    this.occasionTitleEn,
    this.occasionTitleUr,
    this.occasionSubtitleEn,
    this.occasionSubtitleUr,
    this.occasionAyahRef,
    this.occasionBukhariNumber,
  });

  bool get hasSpecialOccasion =>
      occasionTitleEn != null && occasionTitleEn!.isNotEmpty;

  String formattedHijri({required bool isUrdu}) =>
      isUrdu ? hijriFormattedUr : hijriFormattedEn;

  String formattedGregorian({required bool isUrdu}) =>
      isUrdu ? gregorianFormattedUr : gregorianFormattedEn;

  String? localizedOccasionTitle({required bool isUrdu}) =>
      isUrdu ? occasionTitleUr : occasionTitleEn;

  String? localizedOccasionSubtitle({required bool isUrdu}) =>
      isUrdu ? occasionSubtitleUr : occasionSubtitleEn;
}