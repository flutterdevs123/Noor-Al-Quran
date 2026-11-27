
/// Immutable model representing a single Ayah of the Holy Quran.
///
/// Stores Uthmani Arabic text, translations, and Mushaf metadata.
class QuranAyahModel {
  final int surahNumber;
  final int numberInSurah;

  final String arabicText;
  final String urduTranslation;
  final String englishTranslation;

  final int juz;
  final int page;
  final int ruku;

  final bool hasSajda;

  // Additional Quran metadata.
  // Optional to maintain compatibility with existing code and JSON.
  final int? globalAyahNumber;
  final int? hizbQuarter;
  final int? manzil;

  const QuranAyahModel({
    required this.surahNumber,
    required this.numberInSurah,
    required this.arabicText,
    required this.urduTranslation,
    required this.englishTranslation,
    required this.juz,
    required this.page,
    required this.ruku,
    this.hasSajda = false,
    this.globalAyahNumber,
    this.hizbQuarter,
    this.manzil,
  });

  /// Unique composite key formatted as surah:ayah.
  /// Example: 2:255
  String get referenceKey => '$surahNumber:$numberInSurah';

  /// Converts Western digits (0-9) into Arabic-Indic digits (٠-٩).
  static String toArabicIndicDigits(int value) {
    const List<String> arabicDigits = [
      '٠',
      '١',
      '٢',
      '٣',
      '٤',
      '٥',
      '٦',
      '٧',
      '٨',
      '٩',
    ];

    return value
        .toString()
        .split('')
        .map((String ch) {
      final int? digit = int.tryParse(ch);

      return digit != null
          ? arabicDigits[digit]
          : ch;
    })
        .join();
  }

  /// Verse number formatted in Eastern Arabic-Indic script.
  /// Example: ١١٣
  String get arabicIndicNumber =>
      toArabicIndicDigits(numberInSurah);

  /// Ornamental Mushaf end-of-ayah marker.
  /// Example: ۝١١٣
  String get ornateMushafEndMarker =>
      '\u06DD$arabicIndicNumber';

  /// Serializes this Ayah to JSON for offline storage.
  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'numberInSurah': numberInSurah,
      'arabicText': arabicText,
      'urduTranslation': urduTranslation,
      'englishTranslation': englishTranslation,
      'juz': juz,
      'page': page,
      'ruku': ruku,
      'hasSajda': hasSajda,
      'globalAyahNumber': globalAyahNumber,
      'hizbQuarter': hizbQuarter,
      'manzil': manzil,
    };
  }

  /// Restores an Ayah instance from local offline JSON cache.
  ///
  /// Supports both old and new JSON formats.
  factory QuranAyahModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return QuranAyahModel(
      surahNumber:
      (json['surahNumber'] as num?)?.toInt() ?? 1,

      numberInSurah:
      (json['numberInSurah'] as num?)?.toInt() ?? 1,

      arabicText:
      json['arabicText'] as String? ?? '',

      urduTranslation:
      json['urduTranslation'] as String? ?? '',

      englishTranslation:
      json['englishTranslation'] as String? ?? '',

      juz:
      (json['juz'] as num?)?.toInt() ?? 1,

      page:
      (json['page'] as num?)?.toInt() ?? 1,

      ruku:
      (json['ruku'] as num?)?.toInt() ?? 1,

      hasSajda:
      json['hasSajda'] as bool? ?? false,

      globalAyahNumber:
      (json['globalAyahNumber'] as num?)?.toInt(),

      hizbQuarter:
      (json['hizbQuarter'] as num?)?.toInt(),

      manzil:
      (json['manzil'] as num?)?.toInt(),
    );
  }
}
