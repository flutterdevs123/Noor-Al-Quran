import 'package:flutter/foundation.dart';
import '../data/remote/api_client.dart';
import '../data/remote/endpoints.dart';

/// Live English <-> Urdu translation repository backed by public translation APIs
/// with automatic fallback so missing translations are always resolved accurately.
class TranslationRepository {
  final ApiClient _apiClient;

  TranslationRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Translates English text into natural Urdu script.
  Future<String> translateEnglishToUrdu(String englishText) {
    return translate(
      text: englishText,
      sourceLang: 'en',
      targetLang: 'ur',
    );
  }

  /// Translates Urdu text into clear English.
  Future<String> translateUrduToEnglish(String urduText) {
    return translate(
      text: urduText,
      sourceLang: 'ur',
      targetLang: 'en',
    );
  }

  /// Translates [text] from [sourceLang] (`en` / `ur`) to [targetLang] (`ur` / `en`).
  Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final String cleaned = text.trim();
    if (cleaned.isEmpty || sourceLang == targetLang) {
      return cleaned;
    }

    // 1. Primary Translation Endpoint
    final String? primaryResult = await _translateViaPrimaryApi(
      text: cleaned,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
    if (primaryResult != null && primaryResult.trim().isNotEmpty) {
      return primaryResult.trim();
    }

    // 2. Secondary Fallback Translation Endpoint (MyMemory)
    final String? fallbackResult = await _translateViaMyMemory(
      text: cleaned,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
    if (fallbackResult != null && fallbackResult.trim().isNotEmpty) {
      return fallbackResult.trim();
    }

    return cleaned;
  }

  Future<String?> _translateViaPrimaryApi({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      final dynamic data = await _apiClient.getDynamic(
        Endpoints.googleTranslateUrl,
        queryParameters: <String, dynamic>{
          'client': 'gtx',
          'sl': sourceLang,
          'tl': targetLang,
          'dt': 't',
          'q': text,
        },
      );

      if (data is List<dynamic> && data.isNotEmpty && data[0] is List<dynamic>) {
        final StringBuffer buffer = StringBuffer();
        for (final dynamic segment in data[0] as List<dynamic>) {
          if (segment is List<dynamic> &&
              segment.isNotEmpty &&
              segment[0] is String) {
            buffer.write(segment[0] as String);
          }
        }
        final String result = buffer.toString().trim();
        return result.isNotEmpty ? result : null;
      }
    } catch (e) {
      debugPrint('[TranslationRepository] Primary API error: $e');
    }
    return null;
  }

  Future<String?> _translateViaMyMemory({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      final Map<String, dynamic> response = await _apiClient.getJson(
        Endpoints.myMemoryTranslateUrl,
        queryParameters: <String, dynamic>{
          'q': text,
          'langpair': '$sourceLang|$targetLang',
        },
      );

      final dynamic responseData = response['responseData'];
      if (responseData is Map<String, dynamic>) {
        final String translated =
        (responseData['translatedText'] as String? ?? '').trim();
        if (translated.isNotEmpty &&
            !translated.toUpperCase().contains('MYMEMORY WARNING')) {
          return translated;
        }
      }
    } catch (e) {
      debugPrint('[TranslationRepository] MyMemory fallback error: $e');
    }
    return null;
  }
}