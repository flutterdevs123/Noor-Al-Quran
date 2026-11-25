import 'package:hijri/hijri_calendar.dart';
import '../../models/islamic_date_info_model.dart';
import 'urdu_number_utils.dart';

/// Computes offline Hijri (Islamic) & Gregorian dates and detects significant
/// Islamic calendar dates (Eid al-Adha / Qurbani, Ramadan, Eid al-Fitr, Ashura, Jummah, etc.).
class IslamicCalendarUtils {
  IslamicCalendarUtils._();

  static const List<String> _hijriMonthsEn = <String>[
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Ula',
    'Jumada al-Akhirah',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhul Qa\'dah',
    'Dhul Hijjah',
  ];

  static const List<String> _hijriMonthsUr = <String>[
    'محرم الحرام',
    'صفر المظفر',
    'ربیع الاول',
    'ربیع الثانی',
    'جمادی الاولیٰ',
    'جمادی الثانیہ',
    'رجب المرجب',
    'شعبان المعظم',
    'رمضان المبارک',
    'شوال المکرم',
    'ذوالقعدۃ',
    'ذوالحجۃ',
  ];

  static const List<String> _gregorianMonthsEn = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _gregorianMonthsUr = <String>[
    'جنوری',
    'فروری',
    'مارچ',
    'اپریل',
    'مئی',
    'جون',
    'جولائی',
    'اگست',
    'ستمبر',
    'اکتوبر',
    'نومبر',
    'دسمبر',
  ];

  /// Builds full [IslamicDateInfoModel] for [date] with optional moon-sighting [hijriDayOffset].
  static IslamicDateInfoModel getTodayInfo({
    DateTime? date,
    int hijriDayOffset = 0,
  }) {
    final DateTime now = date ?? DateTime.now();
    final DateTime adjustedForHijri = now.add(Duration(days: hijriDayOffset));
    final HijriCalendar hijri = HijriCalendar.fromDate(adjustedForHijri);

    final int hDay = hijri.hDay;
    final int hMonth = hijri.hMonth;
    final int hYear = hijri.hYear;

    final String monthEn = _hijriMonthsEn[(hMonth - 1).clamp(0, 11)];
    final String monthUr = _hijriMonthsUr[(hMonth - 1).clamp(0, 11)];

    final String hijriEn = '$hDay $monthEn $hYear AH';
    final String hijriUr =
        '${UrduNumberUtils.format(hDay)} $monthUr ${UrduNumberUtils.format(hYear)} ھ';

    final String gMonthEn = _gregorianMonthsEn[now.month - 1];
    final String gMonthUr = _gregorianMonthsUr[now.month - 1];

    final String gregEn = '${now.day} $gMonthEn ${now.year}';
    final String gregUr =
        '${UrduNumberUtils.format(now.day)} $gMonthUr ${UrduNumberUtils.format(now.year)}';

    final _OccasionSpec? occasion = _resolveOccasion(
      hDay: hDay,
      hMonth: hMonth,
      weekday: now.weekday,
    );

    return IslamicDateInfoModel(
      hijriDay: hDay,
      hijriMonth: hMonth,
      hijriYear: hYear,
      hijriFormattedEn: hijriEn,
      hijriFormattedUr: hijriUr,
      gregorianFormattedEn: gregEn,
      gregorianFormattedUr: gregUr,
      occasionTitleEn: occasion?.titleEn,
      occasionTitleUr: occasion?.titleUr,
      occasionSubtitleEn: occasion?.subtitleEn,
      occasionSubtitleUr: occasion?.subtitleUr,
      occasionAyahRef: occasion?.ayahRef,
      occasionBukhariNumber: occasion?.bukhariNumber,
    );
  }

  /// Resolves authentic occasion metadata and verified Quran/Bukhari references
  /// for special Islamic calendar days.
  static _OccasionSpec? _resolveOccasion({
    required int hDay,
    required int hMonth,
    required int weekday,
  }) {
    // 1. Dhul Hijjah (Month 12): Qurbani, Eid al-Adha & Arafah
    if (hMonth == 12) {
      if (hDay >= 10 && hDay <= 12) {
        return const _OccasionSpec(
          titleEn: 'Eid al-Adha & Qurbani',
          titleUr: 'عید الاضحیٰ اور فضیلتِ قربانی',
          subtitleEn: 'Days of sacrifice, Takbir & gratitude to Allah',
          subtitleUr: 'قربانی، تکبیراتِ تشریق اور اللہ کے حضور شکر گزاری کے ایام',
          ayahRef: '22:37', // Surah Al-Hajj: Taqwa reaches Allah
          bukhariNumber: 5545, // Sahih Bukhari: Eid al-Adha & Qurbani
        );
      }
      if (hDay == 9) {
        return const _OccasionSpec(
          titleEn: 'Day of Arafah',
          titleUr: 'یومِ عرفہ',
          subtitleEn: 'Best day of supplication, forgiveness & Takbir',
          subtitleUr: 'دعا، مغفرت اور تکبیر کا عظیم دن',
          ayahRef: '5:3', // Perfection of religion revealed on Arafah
          bukhariNumber: 45,
        );
      }
      if (hDay >= 1 && hDay <= 8) {
        return const _OccasionSpec(
          titleEn: 'Blessed First 10 Days of Dhul Hijjah',
          titleUr: 'عشرہ ذوالحجہ کے مبارک ایام',
          subtitleEn: 'Good deeds in these days are most beloved to Allah',
          subtitleUr: 'ان ایام کے نیک اعمال اللہ کو سب سے زیادہ محبوب ہیں',
          ayahRef: '89:1', // By the dawn and ten nights
          bukhariNumber: 969, // Virtue of deeds in first 10 days of Dhul Hijjah
        );
      }
    }

    // 2. Shawwal (Month 10): Eid al-Fitr
    if (hMonth == 10 && (hDay == 1 || hDay == 2)) {
      return const _OccasionSpec(
        titleEn: 'Eid al-Fitr Mubarak',
        titleUr: 'عید الفطر مبارک',
        subtitleEn: 'Day of gratitude, Sadaqah al-Fitr & celebration',
        subtitleUr: 'شکر گزاری، صدقہ فطر اور خوشی کا بابرکت دن',
        ayahRef: '2:185', // Completing the period & glorifying Allah
        bukhariNumber: 952, // Eid prayer & celebration in Sahih Bukhari
      );
    }

    // 3. Ramadan (Month 9): Fasting & Laylatul Qadr
    if (hMonth == 9) {
      if (hDay >= 21 && hDay.isOdd) {
        return const _OccasionSpec(
          titleEn: 'Last 10 Nights • Seek Laylatul Qadr',
          titleUr: 'آخری عشرہ • تلاشِ شبِ قدر',
          subtitleEn: 'Better than a thousand months of worship',
          subtitleUr: 'ہزار مہینوں کی عبادت سے بہتر رات',
          ayahRef: '97:3', // Laylatul Qadr is better than a thousand months
          bukhariNumber: 2017, // Seeking Laylatul Qadr in odd nights
        );
      }
      return const _OccasionSpec(
        titleEn: 'Blessed Month of Ramadan',
        titleUr: 'ماہِ رمضان المبارک',
        subtitleEn: 'Month of fasting, Quran recitation & mercy',
        subtitleUr: 'روزہ، تلاوتِ قرآن اور رحمت و مغفرت کا مہینہ',
        ayahRef: '2:183', // Prescription of fasting
        bukhariNumber: 1894, // Fasting as a shield
      );
    }

    // 4. Muharram (Month 1): Islamic New Year & Ashura
    if (hMonth == 1) {
      if (hDay == 9 || hDay == 10) {
        return const _OccasionSpec(
          titleEn: 'Day of Ashura (10 Muharram)',
          titleUr: 'یومِ عاشوراء (۱۰ محرم)',
          subtitleEn: 'Recommended day of fasting & remembrance',
          subtitleUr: 'روزہ اور اللہ کے شکر کا مسنون دن',
          ayahRef: '26:65', // Deliverance of Musa (AS)
          bukhariNumber: 2004, // Fasting on Ashura
        );
      }
      if (hDay == 1) {
        return const _OccasionSpec(
          titleEn: 'Islamic Hijri New Year',
          titleUr: 'نیا اسلامی ہجری سال',
          subtitleEn: 'Reflect, renew intentions & increase good deeds',
          subtitleUr: 'نئی نیتوں اور نیک اعمال کے عزم کا آغاز',
          ayahRef: '9:36', // Number of months with Allah
          bukhariNumber: 1, // Actions are judged by intentions
        );
      }
    }

    // 5. Rabi al-Awwal (Month 3): Seerah & Salawat
    if (hMonth == 3 && hDay == 12) {
      return const _OccasionSpec(
        titleEn: 'Seerah & Salawat Remembrance',
        titleUr: 'ذکرِ سیرت و درودِ پاک',
        subtitleEn: 'Send abundant peace and blessings upon the Prophet ﷺ',
        subtitleUr: 'نبی کریم ﷺ پر کثرت سے درود و سلام بھیجیں',
        ayahRef: '33:56', // Allah and His angels send blessings upon the Prophet
        bukhariNumber: 6357, // How to send Salawat
      );
    }

    // 6. Weekly Jummah (Friday)
    if (weekday == DateTime.friday) {
      return const _OccasionSpec(
        titleEn: 'Blessed Jummah (Friday)',
        titleUr: 'جمعۃ المبارک',
        subtitleEn: 'Recite Surah Al-Kahf & send abundant Salawat ﷺ',
        subtitleUr: 'سورۃ الکہف کی تلاوت اور درودِ پاک کی کثرت کریں',
        ayahRef: '62:9', // Surah Al-Jumu'ah call to prayer
        bukhariNumber: 883, // Virtues of Jummah prayer
      );
    }

    return null;
  }
}

class _OccasionSpec {
  final String titleEn;
  final String titleUr;
  final String subtitleEn;
  final String subtitleUr;
  final String ayahRef;
  final int bukhariNumber;

  const _OccasionSpec({
    required this.titleEn,
    required this.titleUr,
    required this.subtitleEn,
    required this.subtitleUr,
    required this.ayahRef,
    required this.bukhariNumber,
  });
}