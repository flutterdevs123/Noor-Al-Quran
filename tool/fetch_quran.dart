
import 'dart:convert';
import 'dart:io';

/// AlQuran Cloud API base URL.
const String baseUrl = 'https://api.alquran.cloud/v1/quran';

/// Output JSON location.
const String outputPath = 'assets/data/quran_complete.json';

/// Removes Arabic diacritics and tatweel only for comparison.
///
/// Original Quran text is never modified by this function.
String normalizeArabicForComparison(String word) {
  return word
      .replaceAll(
    RegExp(r'[\u0640\u064B-\u065F\u0670\u06D6-\u06ED]'),
    '',
  )
      .replaceAll('ٱ', 'ا')
      .trim();
}

/// Removes the opening Bismillah from Surah 2-8 and 10-114.
///
/// Only removes it when all four Arabic words match.
/// Original Quranic marks in the remaining text are preserved.
String stripBismillah(String text) {
  final String cleanedText = text
      .replaceAll('\uFEFF', '')
      .trim();

  final List<String> words =
  cleanedText.split(RegExp(r'\s+'));

  const List<String> expectedBismillah = [
    'بسم',
    'الله',
    'الرحمن',
    'الرحيم',
  ];

  if (words.length <= 4) {
    return cleanedText;
  }

  final List<String> firstFourWords = words
      .take(4)
      .map(normalizeArabicForComparison)
      .toList();

  final bool isBismillah = List.generate(
    4,
        (index) =>
    firstFourWords[index] == expectedBismillah[index],
  ).every((match) => match);

  if (isBismillah) {
    return words.sublist(4).join(' ').trim();
  }

  return cleanedText;
}

/// Cleans only invisible encoding characters.
/// Does not remove Quranic symbols or diacritics.
String cleanArabicText(String text) {
  return text
      .replaceAll('\uFEFF', '')
      .trim();
}

/// Converts API numeric values safely.
int readInt(dynamic value, String fieldName) {
  if (value is num) {
    return value.toInt();
  }

  throw FormatException(
    'Invalid or missing numeric field: $fieldName',
  );
}

/// Downloads and validates JSON from AlQuran Cloud.
Future<Map<String, dynamic>> fetchJson(
    HttpClient client,
    String url,
    ) async {
  final Uri uri = Uri.parse(url);

  final HttpClientRequest request =
  await client.getUrl(uri).timeout(
    const Duration(seconds: 60),
  );

  request.headers.set(
    HttpHeaders.acceptHeader,
    'application/json',
  );

  final HttpClientResponse response =
  await request.close().timeout(
    const Duration(seconds: 120),
  );

  final String body =
  await response.transform(utf8.decoder).join();

  if (response.statusCode != HttpStatus.ok) {
    throw HttpException(
      'HTTP ${response.statusCode} while downloading $url\n'
          'Response: $body',
      uri: uri,
    );
  }

  final dynamic decoded = jsonDecode(body);

  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'Invalid API response format.',
    );
  }

  if (decoded['code'] != 200) {
    throw FormatException(
      'API error: ${decoded['status'] ?? 'Unknown error'}',
    );
  }

  return decoded;
}

/// Extracts the Surah list from an API response.
List<dynamic> extractSurahs(
    Map<String, dynamic> response,
    ) {
  final dynamic data = response['data'];

  if (data is! Map<String, dynamic>) {
    throw const FormatException(
      'Invalid Quran data.',
    );
  }

  final dynamic surahs = data['surahs'];

  if (surahs is! List || surahs.length != 114) {
    throw const FormatException(
      'Expected exactly 114 Surahs.',
    );
  }

  return surahs;
}

/// Main downloader.
Future<void> main() async {
  final HttpClient client = HttpClient();

  client.connectionTimeout =
  const Duration(seconds: 30);

  try {
    stdout.writeln('');
    stdout.writeln('================================');
    stdout.writeln('       QURAN DOWNLOADER');
    stdout.writeln('================================');
    stdout.writeln('');

    stdout.writeln('Downloading Quran editions...');
    stdout.writeln('1. Uthmani Arabic');
    stdout.writeln('2. Urdu Jalandhry');
    stdout.writeln('3. English Asad');
    stdout.writeln('');

    /// Download all three editions simultaneously.
    final List<Map<String, dynamic>> responses =
    await Future.wait([
      fetchJson(
        client,
        '$baseUrl/quran-uthmani',
      ),
      fetchJson(
        client,
        '$baseUrl/ur.jalandhry',
      ),
      fetchJson(
        client,
        '$baseUrl/en.asad',
      ),
    ]);

    stdout.writeln('All editions downloaded successfully.');
    stdout.writeln('');

    /// Extract Surah lists.
    final List<dynamic> arSurahs =
    extractSurahs(responses[0]);

    final List<dynamic> urSurahs =
    extractSurahs(responses[1]);

    final List<dynamic> enSurahs =
    extractSurahs(responses[2]);

    /// Final Quran data.
    final Map<String, dynamic> output = {};

    int totalAyahs = 0;

    /// Process all 114 Surahs.
    for (int s = 0; s < 114; s++) {
      final Map<String, dynamic> arSurah =
      Map<String, dynamic>.from(arSurahs[s]);

      final Map<String, dynamic> urSurah =
      Map<String, dynamic>.from(urSurahs[s]);

      final Map<String, dynamic> enSurah =
      Map<String, dynamic>.from(enSurahs[s]);

      final int surahNumber =
      readInt(arSurah['number'], 'surah.number');

      if (surahNumber != s + 1 ||
          readInt(urSurah['number'], 'urdu.surah.number') !=
              surahNumber ||
          readInt(enSurah['number'], 'english.surah.number') !=
              surahNumber) {
        throw FormatException(
          'Surah numbering mismatch at index $s.',
        );
      }

      final List<dynamic> arAyahs =
      arSurah['ayahs'] as List<dynamic>;

      final List<dynamic> urAyahs =
      urSurah['ayahs'] as List<dynamic>;

      final List<dynamic> enAyahs =
      enSurah['ayahs'] as List<dynamic>;

      /// Ensure all editions have the same Ayah count.
      if (arAyahs.length != urAyahs.length ||
          arAyahs.length != enAyahs.length) {
        throw FormatException(
          'Ayah count mismatch in Surah $surahNumber.',
        );
      }

      final List<Map<String, dynamic>> formattedAyahs = [];

      /// Process individual Ayahs.
      for (int a = 0; a < arAyahs.length; a++) {
        final Map<String, dynamic> ar =
        Map<String, dynamic>.from(arAyahs[a]);

        final Map<String, dynamic> ur =
        Map<String, dynamic>.from(urAyahs[a]);

        final Map<String, dynamic> en =
        Map<String, dynamic>.from(enAyahs[a]);

        final int numberInSurah =
        readInt(ar['numberInSurah'], 'numberInSurah');

        final int globalAyahNumber =
        readInt(ar['number'], 'number');

        /// Verify Ayah numbering across editions.
        if (numberInSurah != a + 1 ||
            readInt(
              ur['numberInSurah'],
              'urdu.numberInSurah',
            ) !=
                numberInSurah ||
            readInt(
              en['numberInSurah'],
              'english.numberInSurah',
            ) !=
                numberInSurah) {
          throw FormatException(
            'Ayah numbering mismatch: '
                'Surah $surahNumber, Ayah ${a + 1}.',
          );
        }

        /// Original Arabic text.
        String arabicText =
        cleanArabicText(ar['text'] as String);

        /// Remove Bismillah from the beginning of
        /// Surahs 2-8 and 10-114, if it exists.
        if (surahNumber != 1 &&
            surahNumber != 9 &&
            numberInSurah == 1) {
          arabicText = stripBismillah(arabicText);
        }

        /// Preserve original Quranic Arabic characters.
        final String urduTranslation =
        cleanArabicText(ur['text'] as String);

        final String englishTranslation =
        cleanArabicText(en['text'] as String);

        /// Sajdah information.
        final dynamic sajdaRaw = ar['sajda'];

        final bool hasSajda =
            sajdaRaw == true || sajdaRaw is Map;

        /// Save complete Ayah information.
        formattedAyahs.add({
          'surahNumber': surahNumber,
          'numberInSurah': numberInSurah,
          'globalAyahNumber': globalAyahNumber,

          'arabicText': arabicText,

          'urduTranslation': urduTranslation,
          'englishTranslation': englishTranslation,

          /// Original Madani Mushaf metadata.
          'juz': readInt(ar['juz'], 'juz'),
          'page': readInt(ar['page'], 'page'),
          'ruku': readInt(ar['ruku'], 'ruku'),

          /// Additional reading metadata.
          'hizbQuarter': readInt(
            ar['hizbQuarter'],
            'hizbQuarter',
          ),

          'manzil': readInt(
            ar['manzil'],
            'manzil',
          ),

          'hasSajda': hasSajda,
        });

        totalAyahs++;
      }

      /// Save Surah data.
      output[surahNumber.toString()] = formattedAyahs;

      stdout.writeln(
        'Surah $surahNumber completed '
            '(${formattedAyahs.length} Ayahs)',
      );
    }

    /// Validate final Quran data.
    if (output.length != 114) {
      throw const FormatException(
        'Final Quran must contain 114 Surahs.',
      );
    }

    /// Generate JSON.
    final String jsonOutput =
    const JsonEncoder.withIndent('  ').convert(output);

    /// Save JSON file.
    final File outputFile = File(outputPath);

    await outputFile.parent.create(
      recursive: true,
    );

    await outputFile.writeAsString(
      jsonOutput,
      encoding: utf8,
      flush: true,
    );

    stdout.writeln('');
    stdout.writeln('================================');
    stdout.writeln('       DOWNLOAD SUCCESSFUL');
    stdout.writeln('================================');
    stdout.writeln('Total Surahs: ${output.length}');
    stdout.writeln('Total Ayahs: $totalAyahs');
    stdout.writeln('Output: ${outputFile.absolute.path}');
    stdout.writeln('');
  } catch (e, stackTrace) {
    stderr.writeln('');
    stderr.writeln('================================');
    stderr.writeln('          DOWNLOAD ERROR');
    stderr.writeln('================================');
    stderr.writeln(e);
    stderr.writeln(stackTrace);

    rethrow;
  } finally {
    client.close(force: true);
  }
}
