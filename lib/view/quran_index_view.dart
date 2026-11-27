import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/qari_model.dart';
import '../res/responsive/responsive_extensions.dart';
import '../res/responsive/responsive_utils.dart';
import '../res/theme/app_theme.dart';
import '../view_model/quran_reader_controller.dart';

/// Standalone route wrapper around [QuranIndexView] with an [AppBar].
class QuranIndexScreen extends StatelessWidget {
  const QuranIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Al-Quran Al-Kareem'),
        centerTitle: true,
      ),
      body: const QuranIndexView(),
    );
  }
}

/// Reusable Offline Quran Index body hosting:
/// - Continue Reading hero card (`lastReadSurah:lastReadAyah`)
/// - 1-Tap Complete Quran Offline Download progress banner (`X / 114 Surahs`)
/// - Search input & 3-segment index switcher (114 Surahs, 30 Paras, Bookmarks)
class QuranIndexView extends GetView<QuranReaderController> {
  const QuranIndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Top Header: Continue Reading + Offline Download Manager
        Padding(
          padding: EdgeInsets.fromLTRB(14.sz, 10.sz, 14.sz, 6.sz),
          child: Column(
            children: <Widget>[
              _buildContinueReadingBanner(context),
              8.vSpace,
              _buildOfflineDownloadBanner(context),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: ResponsiveUtils.symmetricPadding(
            horizontal: 14,
            vertical: 4,
          ),
          child: TextField(
            onChanged: (String val) => controller.searchQuery.value = val,
            decoration: InputDecoration(
              hintText: 'Search Surah or Para (e.g. Al-Kahf, 18, Amma)...',
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              filled: true,
              fillColor: context.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.45),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Segmented Index Switcher (Surahs | Paras | Bookmarks)
        Padding(
          padding: ResponsiveUtils.symmetricPadding(
            horizontal: 14,
            vertical: 6,
          ),
          child: Obx(() {
            return SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(value: 0, label: Text('Surahs (114)')),
                ButtonSegment<int>(value: 1, label: Text('Paras (30)')),
                ButtonSegment<int>(value: 2, label: Text('Bookmarks')),
              ],
              selected: <int>{controller.activeIndexTab.value},
              onSelectionChanged: (Set<int> selection) {
                controller.activeIndexTab.value = selection.first;
              },
            );
          }),
        ),

        // Active Index List
        Expanded(
          child: Obx(() {
            switch (controller.activeIndexTab.value) {
              case 1:
                return _buildParasList(context);
              case 2:
                return _buildBookmarksList(context);
              default:
                return _buildSurahsList(context);
            }
          }),
        ),
      ],
    );
  }

  Widget _buildContinueReadingBanner(BuildContext context) {
    return Obx(() {
      final int surahNum = controller.settingsService.lastReadSurah.value;
      final int ayahNum = controller.settingsService.lastReadAyah.value;
      final SurahMeta meta = QuranAudioData.getSurahByNumber(surahNum);

      return InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => controller.openSurah(
          surahNumber: surahNum,
          initialAyah: ayahNum,
        ),
        child: Container(
          padding: ResponsiveUtils.allPadding(14),
          decoration: BoxDecoration(
            gradient: context.appColors.heroGradient,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44.sz,
                height: 44.sz,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 22.sz,
                  color: context.appColors.onHeroPrimary,
                ),
              ),
              12.hSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Continue Reading',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.appColors.onHeroSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    2.vSpace,
                    Text(
                      '${meta.number}. Surah ${meta.englishName} • Ayah $ayahNum',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.appColors.onHeroPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                meta.arabicName,
                style: TextStyle(
                  fontFamily: 'KFGQPCUthmanTahaNaskh',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.onHeroPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOfflineDownloadBanner(BuildContext context) {
    return Obx(() {
      final int count = controller.downloadedSurahsCount.value;
      final bool isDownloading = controller.isDownloadingAllQuran.value;
      final bool isComplete = count >= 114;

      return Container(
        padding: ResponsiveUtils.symmetricPadding(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: context.colorScheme.outlineVariant),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  isComplete
                      ? Icons.offline_pin_rounded
                      : Icons.cloud_download_outlined,
                  size: 18.sz,
                  color: isComplete ? Colors.green : context.colorScheme.primary,
                ),
                8.hSpace,
                Expanded(
                  child: Text(
                    isComplete
                        ? 'Complete Quran Offline Ready (114/114)'
                        : 'Offline Storage: $count / 114 Surahs Saved',
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!isComplete)
                  TextButton(
                    onPressed: isDownloading
                        ? null
                        : controller.downloadCompleteQuranOffline,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.symmetric(horizontal: 10.sz),
                    ),
                    child: Text(
                      isDownloading ? 'Saving...' : 'Download All',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            if (isDownloading) ...<Widget>[
              6.vSpace,
              LinearProgressIndicator(
                value: count / 114.0,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSurahsList(BuildContext context) {
    final List<SurahMeta> surahs = controller.filteredSurahs;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(14.sz, 4.sz, 14.sz, 20.sz),
      itemCount: surahs.length,
      separatorBuilder: (_, __) => 8.vSpace,
      itemBuilder: (BuildContext context, int index) {
        final SurahMeta surah = surahs[index];
        return Obx(() {
          final bool isOffline =
          controller.cachedSurahNumbers.contains(surah.number);

          return Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () => controller.openSurah(surahNumber: surah.number),
              child: Padding(
                padding: ResponsiveUtils.symmetricPadding(
                  horizontal: 12,
                  vertical: 11,
                ),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: context.colorScheme.primaryContainer,
                      child: Text(
                        '${surah.number}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    12.hSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  surah.englishName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (isOffline) ...<Widget>[
                                6.hSpace,
                                Icon(
                                  Icons.offline_pin_rounded,
                                  size: 14.sz,
                                  color: Colors.green,
                                ),
                              ],
                            ],
                          ),
                          2.vSpace,
                          Text(
                            '${surah.revelationLabel} • ${surah.versesCount} Ayahs • Para ${surah.startJuz}',
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    8.hSpace,
                    Text(
                      surah.arabicName,
                      style: TextStyle(
                        fontFamily: 'KFGQPCUthmanTahaNaskh',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildParasList(BuildContext context) {
    final List<ParaMeta> paras = controller.filteredParas;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(14.sz, 4.sz, 14.sz, 20.sz),
      itemCount: paras.length,
      separatorBuilder: (_, __) => 8.vSpace,
      itemBuilder: (BuildContext context, int index) {
        final ParaMeta para = paras[index];
        final SurahMeta startSurahMeta =
        QuranAudioData.getSurahByNumber(para.startSurah);

        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => controller.openSurah(
              surahNumber: para.startSurah,
              initialAyah: para.startAyah,
            ),
            child: Padding(
              padding: ResponsiveUtils.symmetricPadding(
                horizontal: 12,
                vertical: 11,
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: context.colorScheme.secondaryContainer,
                    child: Text(
                      '${para.number}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  12.hSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Para ${para.number} • ${para.englishName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        2.vSpace,
                        Text(
                          'Starts at Surah ${startSurahMeta.englishName} (${para.startSurah}:${para.startAyah})',
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  8.hSpace,
                  Text(
                    para.arabicName,
                    style: TextStyle(
                      fontFamily: 'KFGQPCUthmanTahaNaskh',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookmarksList(BuildContext context) {
    final List<String> bookmarks = controller.settingsService.bookmarkedAyahs;

    if (bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: ResponsiveUtils.allPadding(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.bookmark_border_rounded,
                size: 48.sz,
                color: context.colorScheme.outline,
              ),
              10.vSpace,
              Text(
                'No Bookmarked Ayahs Yet',
                style: context.textTheme.titleMedium,
              ),
              4.vSpace,
              Text(
                'Tap the bookmark icon on any Ayah while reading to save it here.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(14.sz, 4.sz, 14.sz, 20.sz),
      itemCount: bookmarks.length,
      separatorBuilder: (_, __) => 8.vSpace,
      itemBuilder: (BuildContext context, int index) {
        final String key = bookmarks[index];
        final List<String> parts = key.split(':');
        final int surahNum = int.tryParse(parts.first) ?? 1;
        final int ayahNum =
        parts.length > 1 ? (int.tryParse(parts[1]) ?? 1) : 1;
        final SurahMeta meta = QuranAudioData.getSurahByNumber(surahNum);

        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(
              Icons.bookmark_rounded,
              color: context.colorScheme.primary,
            ),
            title: Text(
              'Surah ${meta.englishName} ($surahNum:$ayahNum)',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('${meta.revelationLabel} • Para ${meta.startJuz}'),
            trailing: IconButton(
              tooltip: 'Remove Bookmark',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () =>
                  controller.settingsService.toggleBookmarkAyah(surahNum, ayahNum),
            ),
            onTap: () => controller.openSurah(
              surahNumber: surahNum,
              initialAyah: ayahNum,
            ),
          ),
        );
      },
    );
  }
}