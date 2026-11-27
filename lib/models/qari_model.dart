/// Represents an audio reciter (Qari) and their verified MP3Quran server endpoint.
class QariModel {
  final String id;
  final String name;
  final String arabicName;
  final String style;
  final String serverUrl;

  const QariModel({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.style,
    required this.serverUrl,
  });

  /// Returns exact 3-digit padded MP3 URL (e.g. `001.mp3` .. `114.mp3`).
  String getSurahUrl(int surahNumber) {
    final String padded = surahNumber.toString().padLeft(3, '0');
    return '$serverUrl$padded.mp3';
  }
}

/// Shared metadata for each of the 114 Surahs of the Holy Quran.
/// Used across both Audio Tilawat Player and Offline Quran Reader (DRY).
class SurahMeta {
  final int number;
  final String englishName;
  final String arabicName;
  final int versesCount;
  final bool isMeccan;
  final int startJuz;

  const SurahMeta(
      this.number,
      this.englishName,
      this.arabicName,
      this.versesCount, [
        this.isMeccan = true,
        this.startJuz = 1,
      ]);

  /// Human-readable revelation classification (`Meccan` or `Medinan`).
  String get revelationLabel => isMeccan ? 'Meccan' : 'Medinan';
}

/// Represents one of the 30 Juz (Paras) of the Holy Quran with its exact starting Surah & Ayah.
class ParaMeta {
  final int number;
  final String englishName;
  final String arabicName;
  final int startSurah;
  final int startAyah;

  const ParaMeta({
    required this.number,
    required this.englishName,
    required this.arabicName,
    required this.startSurah,
    required this.startAyah,
  });
}

/// Central static registry of Top 20 Qaris, all 114 Surahs, and all 30 Paras (Juz).
class QuranAudioData {
  QuranAudioData._();

  static const List<QariModel> top20Qaris = <QariModel>[
    QariModel(
      id: 'alafasy',
      name: 'Mishary Rashid Alafasy',
      arabicName: 'مشاري راشد العفاسي',
      style: 'Murattal',
      serverUrl: 'https://server8.mp3quran.net/afs/',
    ),
    QariModel(
      id: 'sudais',
      name: 'Abdul Rahman Al-Sudais',
      arabicName: 'عبدالرحمن السديس',
      style: 'Murattal (Haramain)',
      serverUrl: 'https://server11.mp3quran.net/sds/',
    ),
    QariModel(
      id: 'shuraim',
      name: 'Saud Al-Shuraim',
      arabicName: 'سعود الشريم',
      style: 'Murattal (Haramain)',
      serverUrl: 'https://server7.mp3quran.net/shur/',
    ),
    QariModel(
      id: 'maher',
      name: 'Maher Al-Muaiqly',
      arabicName: 'ماهر المعيقلي',
      style: 'Murattal (Haramain)',
      serverUrl: 'https://server12.mp3quran.net/maher/',
    ),
    QariModel(
      id: 'dosari',
      name: 'Yasser Al-Dosari',
      arabicName: 'ياسر الدوسري',
      style: 'Murattal (Haramain)',
      serverUrl: 'https://server11.mp3quran.net/yasser/',
    ),
    QariModel(
      id: 'ghamdi',
      name: 'Saad Al-Ghamdi',
      arabicName: 'سعد الغامدي',
      style: 'Murattal',
      serverUrl: 'https://server7.mp3quran.net/s_gmd/',
    ),
    QariModel(
      id: 'abdul_basit',
      name: 'Abdul Basit Abdul Samad',
      arabicName: 'عبدالباسط عبدالصمد',
      style: 'Murattal',
      serverUrl: 'https://server7.mp3quran.net/basit/',
    ),
    QariModel(
      id: 'minshawi',
      name: 'Mohamed Siddiq Al-Minshawi',
      arabicName: 'محمد صديق المنشاوي',
      style: 'Murattal',
      serverUrl: 'https://server10.mp3quran.net/minsh/',
    ),
    QariModel(
      id: 'husary',
      name: 'Mahmoud Khalil Al-Husary',
      arabicName: 'محمود خليل الحصري',
      style: 'Murattal',
      serverUrl: 'https://server13.mp3quran.net/husr/',
    ),
    QariModel(
      id: 'ajmy',
      name: 'Ahmed ibn Ali al-Ajmy',
      arabicName: 'أحمد بن علي العجمي',
      style: 'Murattal',
      serverUrl: 'https://server10.mp3quran.net/ajm/',
    ),
    QariModel(
      id: 'qatami',
      name: 'Nasser Al Qatami',
      arabicName: 'ناصر القطامي',
      style: 'Murattal',
      serverUrl: 'https://server6.mp3quran.net/qtm/',
    ),
    QariModel(
      id: 'juhany',
      name: 'Abdullah Awad Al Juhany',
      arabicName: 'عبدالله عواد الجهني',
      style: 'Murattal (Haramain)',
      serverUrl: 'https://server13.mp3quran.net/jhn/',
    ),
    QariModel(
      id: 'baleela',
      name: 'Bandar Baleela',
      arabicName: 'بندر بليلة',
      style: 'Murattal (Haramain)',
      serverUrl: 'https://server6.mp3quran.net/balilah/',
    ),
    QariModel(
      id: 'hudhaify',
      name: 'Ali Al-Hudhaify',
      arabicName: 'علي الحذيفي',
      style: 'Murattal (Madinah)',
      serverUrl: 'https://server9.mp3quran.net/hthfi/',
    ),
    QariModel(
      id: 'shatri',
      name: 'Abu Bakr Al-Shatri',
      arabicName: 'أبو بكر الشاطري',
      style: 'Murattal',
      serverUrl: 'https://server11.mp3quran.net/shatri/',
    ),
    QariModel(
      id: 'banna',
      name: 'Mahmoud Ali Al-Banna',
      arabicName: 'محمود علي البنا',
      style: 'Murattal',
      serverUrl: 'https://server8.mp3quran.net/bna/',
    ),
    QariModel(
      id: 'jibreel',
      name: 'Muhammad Jibreel',
      arabicName: 'محمد جبريل',
      style: 'Murattal',
      serverUrl: 'https://server8.mp3quran.net/jbrl/',
    ),
    QariModel(
      id: 'ayyoub',
      name: 'Muhammad Ayyub',
      arabicName: 'محمد أيوب',
      style: 'Murattal (Madinah)',
      serverUrl: 'https://server8.mp3quran.net/ayyub/',
    ),
    QariModel(
      id: 'fares',
      name: 'Fares Abbad',
      arabicName: 'فارس عباد',
      style: 'Murattal',
      serverUrl: 'https://server8.mp3quran.net/frs_a/',
    ),
    QariModel(
      id: 'luhaidan',
      name: 'Muhammad Al-Luhaidan',
      arabicName: 'محمد اللحيدان',
      style: 'Murattal',
      serverUrl: 'https://server8.mp3quran.net/lhdan/',
    ),
  ];

  static const List<SurahMeta> allSurahs = <SurahMeta>[
    SurahMeta(1, 'Al-Fatihah', 'الفاتحة', 7, true, 1),
    SurahMeta(2, 'Al-Baqarah', 'البقرة', 286, false, 1),
    SurahMeta(3, 'Ali \'Imran', 'آل عمران', 200, false, 3),
    SurahMeta(4, 'An-Nisa', 'النساء', 176, false, 4),
    SurahMeta(5, 'Al-Ma\'idah', 'المائدة', 120, false, 6),
    SurahMeta(6, 'Al-An\'am', 'الأنعام', 165, true, 7),
    SurahMeta(7, 'Al-A\'raf', 'الأعراف', 206, true, 8),
    SurahMeta(8, 'Al-Anfal', 'الأنفال', 75, false, 9),
    SurahMeta(9, 'At-Tawbah', 'التوبة', 129, false, 10),
    SurahMeta(10, 'Yunus', 'يونس', 109, true, 11),
    SurahMeta(11, 'Hud', 'هود', 123, true, 11),
    SurahMeta(12, 'Yusuf', 'يوسف', 111, true, 12),
    SurahMeta(13, 'Ar-Ra\'d', 'الرعد', 43, false, 13),
    SurahMeta(14, 'Ibrahim', 'إبراهيم', 52, true, 13),
    SurahMeta(15, 'Al-Hijr', 'الحجر', 99, true, 14),
    SurahMeta(16, 'An-Nahl', 'النحل', 128, true, 14),
    SurahMeta(17, 'Al-Isra', 'الإسراء', 111, true, 15),
    SurahMeta(18, 'Al-Kahf', 'الكهف', 110, true, 15),
    SurahMeta(19, 'Maryam', 'مريم', 98, true, 16),
    SurahMeta(20, 'Taha', 'طه', 135, true, 16),
    SurahMeta(21, 'Al-Anbya', 'الأنبياء', 112, true, 17),
    SurahMeta(22, 'Al-Hajj', 'الحج', 78, false, 17),
    SurahMeta(23, 'Al-Mu\'minun', 'المؤمنون', 118, true, 18),
    SurahMeta(24, 'An-Nur', 'النور', 64, false, 18),
    SurahMeta(25, 'Al-Furqan', 'الفرقان', 77, true, 18),
    SurahMeta(26, 'Ash-Shu\'ara', 'الشعراء', 227, true, 19),
    SurahMeta(27, 'An-Naml', 'النمل', 93, true, 19),
    SurahMeta(28, 'Al-Qasas', 'القصص', 88, true, 20),
    SurahMeta(29, 'Al-\'Ankabut', 'العنكبوت', 69, true, 20),
    SurahMeta(30, 'Ar-Rum', 'الروم', 60, true, 21),
    SurahMeta(31, 'Luqman', 'لقمان', 34, true, 21),
    SurahMeta(32, 'As-Sajdah', 'السجدة', 30, true, 21),
    SurahMeta(33, 'Al-Ahzab', 'الأحزاب', 73, false, 21),
    SurahMeta(34, 'Saba', 'سبأ', 54, true, 22),
    SurahMeta(35, 'Fatir', 'فاطر', 45, true, 22),
    SurahMeta(36, 'Ya-Sin', 'يس', 83, true, 22),
    SurahMeta(37, 'As-Saffat', 'الصافات', 182, true, 23),
    SurahMeta(38, 'Sad', 'ص', 88, true, 23),
    SurahMeta(39, 'Az-Zumar', 'الزمر', 75, true, 23),
    SurahMeta(40, 'Ghafir', 'غافر', 85, true, 24),
    SurahMeta(41, 'Fussilat', 'فصلت', 54, true, 24),
    SurahMeta(42, 'Ash-Shuraa', 'الشورى', 53, true, 25),
    SurahMeta(43, 'Az-Zukhruf', 'الزخرف', 89, true, 25),
    SurahMeta(44, 'Ad-Dukhan', 'الدخان', 59, true, 25),
    SurahMeta(45, 'Al-Jathiyah', 'الجاثية', 37, true, 25),
    SurahMeta(46, 'Al-Ahqaf', 'الأحقاف', 35, true, 26),
    SurahMeta(47, 'Muhammad', 'محمد', 38, false, 26),
    SurahMeta(48, 'Al-Fath', 'الفتح', 29, false, 26),
    SurahMeta(49, 'Al-Hujurat', 'الحجرات', 18, false, 26),
    SurahMeta(50, 'Qaf', 'ق', 45, true, 26),
    SurahMeta(51, 'Adh-Dhariyat', 'الذاريات', 60, true, 26),
    SurahMeta(52, 'At-Tur', 'الطور', 49, true, 27),
    SurahMeta(53, 'An-Najm', 'النجم', 62, true, 27),
    SurahMeta(54, 'Al-Qamar', 'القمر', 55, true, 27),
    SurahMeta(55, 'Ar-Rahman', 'الرحمن', 78, false, 27),
    SurahMeta(56, 'Al-Waqi\'ah', 'الواقعة', 96, true, 27),
    SurahMeta(57, 'Al-Hadid', 'الحديد', 29, false, 27),
    SurahMeta(58, 'Al-Mujadila', 'المجادلة', 22, false, 28),
    SurahMeta(59, 'Al-Hashr', 'الحشر', 24, false, 28),
    SurahMeta(60, 'Al-Mumtahanah', 'الممتحنة', 13, false, 28),
    SurahMeta(61, 'As-Saf', 'الصف', 14, false, 28),
    SurahMeta(62, 'Al-Jumu\'ah', 'الجمعة', 11, false, 28),
    SurahMeta(63, 'Al-Munafiqun', 'المنافقون', 11, false, 28),
    SurahMeta(64, 'At-Taghabun', 'التغابن', 18, false, 28),
    SurahMeta(65, 'At-Talaq', 'الطلاق', 12, false, 28),
    SurahMeta(66, 'At-Tahrim', 'التحريم', 12, false, 28),
    SurahMeta(67, 'Al-Mulk', 'الملك', 30, true, 29),
    SurahMeta(68, 'Al-Qalam', 'القلم', 52, true, 29),
    SurahMeta(69, 'Al-Haqqah', 'الحاقة', 52, true, 29),
    SurahMeta(70, 'Al-Ma\'arij', 'المعارج', 44, true, 29),
    SurahMeta(71, 'Nuh', 'نوح', 28, true, 29),
    SurahMeta(72, 'Al-Jinn', 'الجن', 28, true, 29),
    SurahMeta(73, 'Al-Muzzammil', 'المزمل', 20, true, 29),
    SurahMeta(74, 'Al-Muddaththir', 'المدثر', 56, true, 29),
    SurahMeta(75, 'Al-Qiyamah', 'القيامة', 40, true, 29),
    SurahMeta(76, 'Al-Insan', 'الإنسان', 31, false, 29),
    SurahMeta(77, 'Al-Mursalat', 'المرسلات', 50, true, 29),
    SurahMeta(78, 'An-Naba', 'النبأ', 40, true, 30),
    SurahMeta(79, 'An-Nazi\'at', 'النازعات', 46, true, 30),
    SurahMeta(80, '\'Abasa', 'عبس', 42, true, 30),
    SurahMeta(81, 'At-Takwir', 'التكوير', 29, true, 30),
    SurahMeta(82, 'Al-Infitar', 'الانفطار', 19, true, 30),
    SurahMeta(83, 'Al-Mutaffifin', 'المطففين', 36, true, 30),
    SurahMeta(84, 'Al-Inshiqaq', 'الانشقاق', 25, true, 30),
    SurahMeta(85, 'Al-Buruj', 'البروج', 22, true, 30),
    SurahMeta(86, 'At-Tariq', 'الطارق', 17, true, 30),
    SurahMeta(87, 'Al-A\'la', 'الأعلى', 19, true, 30),
    SurahMeta(88, 'Al-Ghashiyah', 'الغاشية', 26, true, 30),
    SurahMeta(89, 'Al-Fajr', 'الفجر', 30, true, 30),
    SurahMeta(90, 'Al-Balad', 'البلد', 20, true, 30),
    SurahMeta(91, 'Ash-Shams', 'الشمس', 15, true, 30),
    SurahMeta(92, 'Al-Layl', 'الليل', 21, true, 30),
    SurahMeta(93, 'Ad-Duhaa', 'الضحى', 11, true, 30),
    SurahMeta(94, 'Ash-Sharh', 'الشرح', 8, true, 30),
    SurahMeta(95, 'At-Tin', 'التين', 8, true, 30),
    SurahMeta(96, 'Al-\'Alaq', 'العلق', 19, true, 30),
    SurahMeta(97, 'Al-Qadr', 'القدر', 5, true, 30),
    SurahMeta(98, 'Al-Bayyinah', 'البينة', 8, false, 30),
    SurahMeta(99, 'Az-Zalzalah', 'الزلزلة', 8, false, 30),
    SurahMeta(100, 'Al-\'Adiyat', 'العاديات', 11, true, 30),
    SurahMeta(101, 'Al-Qari\'ah', 'القارعة', 11, true, 30),
    SurahMeta(102, 'At-Takathur', 'التكاثر', 8, true, 30),
    SurahMeta(103, 'Al-\'Asr', 'العصر', 3, true, 30),
    SurahMeta(104, 'Al-Humazah', 'الهمزة', 9, true, 30),
    SurahMeta(105, 'Al-Fil', 'الفيل', 5, true, 30),
    SurahMeta(106, 'Quraysh', 'قريش', 4, true, 30),
    SurahMeta(107, 'Al-Ma\'un', 'الماعون', 7, true, 30),
    SurahMeta(108, 'Al-Kawthar', 'الكوثر', 3, true, 30),
    SurahMeta(109, 'Al-Kafirun', 'الكافرون', 6, true, 30),
    SurahMeta(110, 'An-Nasr', 'النصر', 3, false, 30),
    SurahMeta(111, 'Al-Masad', 'المسد', 5, true, 30),
    SurahMeta(112, 'Al-Ikhlas', 'الإخلاص', 4, true, 30),
    SurahMeta(113, 'Al-Falaq', 'الفلق', 5, true, 30),
    SurahMeta(114, 'An-Nas', 'الناس', 6, true, 30),
  ];

  /// Complete 30 Paras (Juz) index mapped to their exact starting Surah & Ayah.
  static const List<ParaMeta> allParas = <ParaMeta>[
    ParaMeta(number: 1, englishName: 'Alif Lam Meem', arabicName: 'الم', startSurah: 1, startAyah: 1),
    ParaMeta(number: 2, englishName: 'Sayaqool', arabicName: 'سيقول', startSurah: 2, startAyah: 142),
    ParaMeta(number: 3, englishName: 'Tilkal Rusul', arabicName: 'تلك الرسل', startSurah: 2, startAyah: 253),
    ParaMeta(number: 4, englishName: 'Lan Tanaloo', arabicName: 'لن تنالوا', startSurah: 3, startAyah: 93),
    ParaMeta(number: 5, englishName: 'Wal Mohsanat', arabicName: 'والمحصنات', startSurah: 4, startAyah: 24),
    ParaMeta(number: 6, englishName: 'La Yuhibbullah', arabicName: 'لا يحب الله', startSurah: 4, startAyah: 148),
    ParaMeta(number: 7, englishName: 'Wa Iza Samiu', arabicName: 'وإذا سمعوا', startSurah: 5, startAyah: 82),
    ParaMeta(number: 8, englishName: 'Wa Lau Annana', arabicName: 'ولو أننا', startSurah: 6, startAyah: 111),
    ParaMeta(number: 9, englishName: 'Qalal Malao', arabicName: 'قال الملأ', startSurah: 7, startAyah: 88),
    ParaMeta(number: 10, englishName: 'Wa A\'lamu', arabicName: 'واعلموا', startSurah: 8, startAyah: 41),
    ParaMeta(number: 11, englishName: 'Yatazeroon', arabicName: 'يعتذرون', startSurah: 9, startAyah: 93),
    ParaMeta(number: 12, englishName: 'Wa Mamin Da\'abbah', arabicName: 'وما من دابة', startSurah: 11, startAyah: 6),
    ParaMeta(number: 13, englishName: 'Wa Ma Ubrioo', arabicName: 'وما أبرئ', startSurah: 12, startAyah: 53),
    ParaMeta(number: 14, englishName: 'Rubama', arabicName: 'ربما', startSurah: 15, startAyah: 1),
    ParaMeta(number: 15, englishName: 'Subhanallazi', arabicName: 'سبحان الذي', startSurah: 17, startAyah: 1),
    ParaMeta(number: 16, englishName: 'Qal Alam', arabicName: 'قال ألم', startSurah: 18, startAyah: 75),
    ParaMeta(number: 17, englishName: 'Aqtarabo', arabicName: 'اقترب', startSurah: 21, startAyah: 1),
    ParaMeta(number: 18, englishName: 'Qadd Aflaha', arabicName: 'قد أفلح', startSurah: 23, startAyah: 1),
    ParaMeta(number: 19, englishName: 'Wa Qalallazina', arabicName: 'وقال الذين', startSurah: 25, startAyah: 21),
    ParaMeta(number: 20, englishName: 'A\'man Khalaq', arabicName: 'أمن خلق', startSurah: 27, startAyah: 56),
    ParaMeta(number: 21, englishName: 'Utlu Ma Oohi', arabicName: 'اتل ما أوحي', startSurah: 29, startAyah: 46),
    ParaMeta(number: 22, englishName: 'Wa Manyaqnut', arabicName: 'ومن يقنت', startSurah: 33, startAyah: 31),
    ParaMeta(number: 23, englishName: 'Wa Mali', arabicName: 'وما لي', startSurah: 36, startAyah: 28),
    ParaMeta(number: 24, englishName: 'Faman Azlam', arabicName: 'فمن أظلم', startSurah: 39, startAyah: 32),
    ParaMeta(number: 25, englishName: 'Elahe Yuruddo', arabicName: 'إليه يرد', startSurah: 41, startAyah: 47),
    ParaMeta(number: 26, englishName: 'Ha\'a Meem', arabicName: 'حم', startSurah: 46, startAyah: 1),
    ParaMeta(number: 27, englishName: 'Qala Fama Khatbukum', arabicName: 'قال فما خطبكم', startSurah: 51, startAyah: 31),
    ParaMeta(number: 28, englishName: 'Qadd Sami Allah', arabicName: 'قد سمع الله', startSurah: 58, startAyah: 1),
    ParaMeta(number: 29, englishName: 'Tabarakallazi', arabicName: 'تبارك الذي', startSurah: 67, startAyah: 1),
    ParaMeta(number: 30, englishName: 'Amma Yatasa\'aloon', arabicName: 'عم يتساءلون', startSurah: 78, startAyah: 1),
  ];

  /// Helper lookup returning [SurahMeta] for a 1-based [surahNumber] (`1`..`114`).
  static SurahMeta getSurahByNumber(int surahNumber) {
    final int clamped = surahNumber.clamp(1, allSurahs.length);
    return allSurahs[clamped - 1];
  }
}