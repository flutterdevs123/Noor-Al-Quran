import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../res/responsive/responsive_extensions.dart';
import '../res/responsive/responsive_scroll_body.dart';
import '../res/responsive/responsive_utils.dart';
import '../res/theme/app_theme.dart';

/// Strongly-typed data model representing an accredited Quran, Hadith,
/// or Islamic calendar data source.
class CreditSourceItem {
  final String title;
  final String role;
  final String description;
  final String url;
  final IconData icon;

  const CreditSourceItem({
    required this.title,
    required this.role,
    required this.description,
    required this.url,
    required this.icon,
  });
}

/// Copyright-safe attribution and acknowledgements screen for all Quran text,
/// translation, tilawat audio, and prayer timing providers.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  static const List<CreditSourceItem> _verifiedSources = <CreditSourceItem>[
    CreditSourceItem(
      title: 'AlQuran.cloud API',
      role: 'Uthmani Arabic Script, Urdu (Jalandhry) & English (Asad) Translations',
      description:
      'We gratefully acknowledge AlQuran.cloud for providing verified Uthmani Quranic text alongside authentic Urdu (Fateh Muhammad Jalandhry) and English (Muhammad Asad) translations for offline reading.',
      url: 'https://alquran.cloud',
      icon: Icons.auto_stories_rounded,
    ),
    CreditSourceItem(
      title: 'MP3Quran.net',
      role: 'Complete High-Quality Quran Audio Recitations (Top 20 Qaris)',
      description:
      'We sincerely thank MP3Quran.net for providing authentic, verified, and uninterrupted audio streams of the Holy Quran recited by world-renowned Qaris.',
      url: 'https://mp3quran.net',
      icon: Icons.headphones_rounded,
    ),
    CreditSourceItem(
      title: 'Quran.com (Quran Foundation)',
      role: 'Verified Quranic Metadata, Chapter Indexing & Translations',
      description:
      'Special thanks to the Quran.com open-source initiative for maintaining 100% verified Surah metadata, Ayah counts, and authentic translations.',
      url: 'https://quran.com',
      icon: Icons.menu_book_rounded,
    ),
    CreditSourceItem(
      title: 'Tanzil.net & King Fahd Complex',
      role: 'Verified Uthmani & IndoPak Quranic Typography',
      description:
      'Heartfelt gratitude to the Tanzil Project and King Fahd Glorious Quran Printing Complex for verified Quranic text scripts and the Uthman Taha Naskh typeface.',
      url: 'https://tanzil.net',
      icon: Icons.verified_rounded,
    ),
    CreditSourceItem(
      title: 'AlAdhan Islamic Network',
      role: 'Hijri Calendar & Accurate Prayer Timing Calculations',
      description:
      'Thanks to AlAdhan API for reliable Hijri-Gregorian date conversions and daily Salah schedules.',
      url: 'https://aladhan.com',
      icon: Icons.access_time_filled_rounded,
    ),
  ];

  Future<void> _openSourceUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits & Data Sources'),
        centerTitle: true,
      ),
      body: ResponsiveScrollBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header Gratitude Banner
            Container(
              padding: ResponsiveUtils.allPadding(16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'JazakAllah Khair to Our Data Providers',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  6.vSpace,
                  Text(
                    'Noor-Al-Quran relies on trusted, authentic Islamic open-data platforms to ensure 100% accuracy in Quranic text, translations, audio recitations, and Islamic dates. All audio copyrights remain with their respective Qaris and publishers.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onPrimaryContainer.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            16.vSpace,

            // Strongly-Typed Source Cards
            ..._verifiedSources.map(
                  (CreditSourceItem item) => _buildSourceCard(
                item: item,
                colors: colors,
                textTheme: textTheme,
              ),
            ),
            20.vSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard({
    required CreditSourceItem item,
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sz),
      child: Card(
        elevation: 0,
        color: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: Padding(
          padding: ResponsiveUtils.allPadding(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 38.sz,
                    height: 38.sz,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      item.icon,
                      size: 20.sz,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  10.hSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                        Text(
                          item.role,
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Visit Official Website',
                    onPressed: () => _openSourceUrl(item.url),
                    icon: Icon(
                      Icons.open_in_new_rounded,
                      size: 20.sz,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              10.vSpace,
              Text(
                item.description,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}