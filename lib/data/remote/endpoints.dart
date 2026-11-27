/// Central API endpoint definitions for Quran, Sahih Hadith, and Translation services.
class Endpoints {
  Endpoints._();

  // AlQuran Cloud REST API (Arabic Uthmani + English + Urdu editions)
  static const String quranBaseUrl = 'https://api.alquran.cloud/v1';

  /// Accepts either a global Ayah number (`1`..`6236`) or `surah:ayah` (e.g. `22:37`).
  static String quranAyahEditions(String ayahReference) =>
      '$quranBaseUrl/ayah/$ayahReference/editions/quran-uthmani,en.asad,ur.jalandhry';

  /// Fetches all Ayahs of a complete Surah (`1`..`114`) with Uthmani Arabic,
  /// Muhammad Asad English translation, and Fateh Muhammad Jalandhry Urdu translation.
  static String quranSurahEditions(int surahNumber) =>
      '$quranBaseUrl/surah/$surahNumber/editions/quran-uthmani,en.asad,ur.jalandhry';

  // Sahih al-Bukhari Open Hadith CDN API
  static const String hadithCdnBaseUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions';

  static String bukhariArabic(int hadithNumber) =>
      '$hadithCdnBaseUrl/ara-bukhari/$hadithNumber.min.json';

  static String bukhariEnglish(int hadithNumber) =>
      '$hadithCdnBaseUrl/eng-bukhari/$hadithNumber.min.json';

  static String bukhariUrdu(int hadithNumber) =>
      '$hadithCdnBaseUrl/urd-bukhari/$hadithNumber.min.json';

  // Live English <-> Urdu Translation APIs (Primary + Fallback)
  static const String googleTranslateUrl =
      'https://translate.googleapis.com/translate_a/single';

  static const String myMemoryTranslateUrl =
      'https://api.mymemory.translated.net/get';
}