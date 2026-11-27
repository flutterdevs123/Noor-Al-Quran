import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final List<Map<String, String>> sources = <Map<String, String>>[
      <String, String>{
        'title': 'MP3Quran.net',
        'role': 'Complete High-Quality Quran Audio Recitations (Top 20 Qaris)',
        'desc':
        'We gratefully acknowledge MP3Quran.net for providing authentic, verified, and uninterrupted audio streams of the Holy Quran recited by world-renowned Qaris.',
        'url': 'https://mp3quran.net',
      },
      <String, String>{
        'title': 'Quran.com (Quran Foundation)',
        'role': 'Verified Quranic Metadata, Chapter Indexing & Translations',
        'desc':
        'Special thanks to the Quran.com open-source initiative for maintaining 100% verified Surah metadata, Ayah counts, and authentic translations.',
        'url': 'https://quran.com',
      },
      <String, String>{
        'title': 'Tanzil.net',
        'role': 'Verified Uthmani & IndoPak Quranic Arabic Script',
        'desc':
        'Heartfelt gratitude to Tanzil Project for providing meticulously verified, error-free Quranic text scripts used across Islamic applications worldwide.',
        'url': 'https://tanzil.net',
      },
      <String, String>{
        'title': 'AlAdhan Islamic Network',
        'role': 'Hijri Calendar & Accurate Prayer Timing Calculations',
        'desc':
        'Thanks to AlAdhan API for reliable Hijri-Gregorian date conversions and daily Salah schedules.',
        'url': 'https://aladhan.com',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits & Data Sources'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'JazakAllah Khair to Our Data Providers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Noor-Al-Quran relies on trusted, authentic Islamic open-data platforms to ensure 100% accuracy in Quranic text, audio recitations, and Islamic dates. All audio copyrights remain with their respective Qaris and publishers.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onPrimaryContainer.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...sources.map((Map<String, String> item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: colors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: colors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item['title']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Visit Official Website',
                          onPressed: () => _openUrl(item['url']!),
                          icon: Icon(
                            Icons.open_in_new_rounded,
                            size: 20,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item['role']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['desc']!,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}