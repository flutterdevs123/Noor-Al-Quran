import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/qari_model.dart';
import '../models/quran_ayah_model.dart';
import '../res/components/mushaf_16_line_reader.dart';
import '../res/constants/app_constants.dart';
import '../res/responsive/responsive_extensions.dart';
import '../res/responsive/responsive_utils.dart';
import '../res/theme/app_theme.dart';
import '../view_model/audio_quran_controller.dart';
import '../view_model/quran_reader_controller.dart';

/// Full-screen Quran Majeed Reader supporting two seamless modes:
/// 1. **16-Line Mushaf Mode (`16 سطری قرآن مجید`)**: Authentic 16-line printed Mushaf
///    layout with 3D realistic page-turn animation and Ruku (`ع`) markers.
/// 2. **Ayah-by-Ayah & Translation Mode**: Premium separated Ayah cards with
///    Uthmani Arabic (`﴿١١٣﴾`), Nastaliq Urdu (`نستعلیق`), English translation,
///    and explicit Ruku section dividers.
class SurahReaderScreen extends StatefulWidget {
  const SurahReaderScreen({super.key});

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  final QuranReaderController controller = Get.find<QuranReaderController>();
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = <int, GlobalKey>{};
  int? _lastScrolledSurah;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTargetAyahIfNeeded(int surahNumber, int targetAyah, int total) {
    if (_lastScrolledSurah == surahNumber && targetAyah <= 1) return;
    _lastScrolledSurah = surahNumber;
    if (targetAyah <= 1 || total <= 1) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final double maxScroll = _scrollController.position.maxScrollExtent;
      final double estimatedOffset =
      ((targetAyah - 1) / total * maxScroll).clamp(0.0, maxScroll);
      _scrollController.jumpTo(estimatedOffset);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final BuildContext? itemCtx = _ayahKeys[targetAyah]?.currentContext;
        if (itemCtx != null) {
          Scrollable.ensureVisible(
            itemCtx,
            alignment: 0.08,
            duration: const Duration(milliseconds: 280),
          );
        }
      });
    });
  }

  void _openReaderSettingsSheet(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.sz, 4.sz, 20.sz, 24.sz),
          child: Obx(() {
            final settings = controller.settingsService;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Reader Mode & Typography Settings',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                12.vSpace,

                // Reading Mode Switcher inside Settings Sheet
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('16-Line Mushaf Mode (16 سطری قرآن)'),
                  subtitle: const Text(
                    'Classic 16-line printed Mushaf with 3D page-turn animation',
                  ),
                  value: settings.isMushaf16LineMode.value,
                  onChanged: settings.setMushaf16LineMode,
                ),

                // Urdu Translation Toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Urdu Translation (اردو ترجمہ - نستعلیق)'),
                  subtitle: const Text('Fateh Muhammad Jalandhry'),
                  value: settings.showUrduTranslation.value,
                  onChanged: settings.setShowUrduTranslation,
                ),

                // English Translation Toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('English Translation'),
                  subtitle: const Text('Muhammad Asad'),
                  value: settings.showEnglishTranslation.value,
                  onChanged: settings.setShowEnglishTranslation,
                ),
                8.vSpace,

                // Arabic Font Size Slider
                Text(
                  'Arabic Font Size (${settings.quranFontSize.value.toInt()} pt)',
                  style: textTheme.labelLarge,
                ),
                Slider(
                  min: AppConstants.minQuranFontSize,
                  max: AppConstants.maxQuranFontSize,
                  value: settings.quranFontSize.value,
                  onChanged: settings.setQuranFontSize,
                ),

                // Translation Font Size Slider
                Text(
                  'Translation Font Size (${settings.translationFontSize.value.toInt()} pt)',
                  style: textTheme.labelLarge,
                ),
                Slider(
                  min: AppConstants.minTranslationFontSize,
                  max: AppConstants.maxTranslationFontSize,
                  value: settings.translationFontSize.value,
                  onChanged: settings.setTranslationFontSize,
                ),
              ],
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AudioQuranController? audioCtrl =
    Get.isRegistered<AudioQuranController>()
        ? Get.find<AudioQuranController>()
        : null;

    return Obx(() {
      final SurahMeta surah = controller.activeSurah.value;
      final List<QuranAyahModel> ayahs = controller.activeAyahs;
      final bool isLoading = controller.isSurahLoading.value;
      final bool is16LineMode =
          controller.settingsService.isMushaf16LineMode.value;

      if (!isLoading && !is16LineMode && ayahs.isNotEmpty) {
        _scrollToTargetAyahIfNeeded(
          surah.number,
          controller.highlightedAyahNumber.value,
          ayahs.length,
        );
      }

      // Bismillah banner is shown before Ayah 1 for all Surahs except Surah 1 & Surah 9
      final bool showBismillahHeader = surah.number != 1 && surah.number != 9;

      return Scaffold(
        appBar: AppBar(
          titleSpacing: 4.sz,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${surah.number}. ${surah.englishName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${surah.revelationLabel} • ${surah.versesCount} Ayahs',
                style: textTheme.labelSmall,
              ),
            ],
          ),
          actions: <Widget>[
            // Quick Mode Toggle Pill: 16-Line Mushaf vs Ayah Translation
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.sz),
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () => controller.settingsService
                    .setMushaf16LineMode(!is16LineMode),
                child: Container(
                  padding: ResponsiveUtils.symmetricPadding(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: context.colorScheme.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        is16LineMode
                            ? Icons.auto_stories_rounded
                            : Icons.view_agenda_outlined,
                        size: 15.sz,
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                      4.hSpace,
                      Text(
                        is16LineMode ? '16-Line' : 'Tarjuma',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Listen Tilawat Button (Reuses AudioQuranController)
            if (audioCtrl != null)
              Obx(() {
                final bool isThisPlaying = audioCtrl.isPlaying.value &&
                    audioCtrl.currentSurah.value?.number == surah.number;
                return IconButton(
                  tooltip: isThisPlaying ? 'Pause Tilawat' : 'Listen Tilawat',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    if (isThisPlaying) {
                      audioCtrl.togglePlayPause();
                    } else {
                      controller.playActiveSurahAudio();
                    }
                  },
                  icon: Icon(
                    isThisPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: context.colorScheme.primary,
                    size: 24.sz,
                  ),
                );
              }),

            // Font Size & Display Settings Button
            IconButton(
              tooltip: 'Reader Display & Font Settings',
              visualDensity: VisualDensity.compact,
              onPressed: () => _openReaderSettingsSheet(context),
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ayahs.isEmpty
            ? _buildOfflineRetryState(context, textTheme, surah)
            : is16LineMode
            ? Mushaf16LineReader(
          key: ValueKey<int>(surah.number),
          surah: surah,
          ayahs: ayahs,
          initialAyahNumber:
          controller.highlightedAyahNumber.value,
          isAyahBookmarked:
          controller.settingsService.isAyahBookmarked,
          onPageAyahFocused: controller.markAyahAsLastRead,
          onToggleBookmark:
          controller.settingsService.toggleBookmarkAyah,
          onRequestNextSurah: surah.number < 114
              ? () => controller.openSurah(
            surahNumber: surah.number + 1,
          )
              : null,
          onRequestPreviousSurah: surah.number > 1
              ? () => controller.openSurah(
            surahNumber: surah.number - 1,
          )
              : null,
        )
            : ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            14.sz,
            10.sz,
            14.sz,
            28.sz,
          ),
          itemCount:
          ayahs.length + (showBismillahHeader ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (showBismillahHeader && index == 0) {
              return _buildBismillahCard(context, surah);
            }

            final int ayahIdx =
            showBismillahHeader ? index - 1 : index;
            final QuranAyahModel ayah = ayahs[ayahIdx];
            final bool isLastInSurah =
                ayahIdx == ayahs.length - 1;
            final bool isRukuEnd = isLastInSurah ||
                ayahs[ayahIdx + 1].ruku != ayah.ruku;

            final GlobalKey key = _ayahKeys.putIfAbsent(
              ayah.numberInSurah,
                  () => GlobalKey(),
            );

            return KeyedSubtree(
              key: key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildPremiumAyahCard(
                    context: context,
                    textTheme: textTheme,
                    ayah: ayah,
                  ),
                  if (isRukuEnd)
                    _buildRukuDividerBanner(
                      context: context,
                      textTheme: textTheme,
                      rukuNumber: ayah.ruku,
                    ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar:
        is16LineMode ? null : _buildSurahSwitcherBar(context, textTheme, surah),
      );
    });
  }

  Widget _buildBismillahCard(BuildContext context, SurahMeta surah) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.sz),
      padding: ResponsiveUtils.symmetricPadding(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: context.appColors.heroGradient,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: context.colorScheme.secondary.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: <Widget>[
          Text(
            'سُورَةُ ${surah.arabicName}',
            style: TextStyle(
              fontFamily: AppConstants.quranUthmaniFontFamily,
              fontSize: 21.sp,
              fontWeight: FontWeight.bold,
              color: context.appColors.onHeroSecondary,
            ),
          ),
          6.vSpace,
          Text(
            'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: AppConstants.quranUthmaniFontFamily,
              fontSize: 25.sp,
              color: context.appColors.onHeroPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAyahCard({
    required BuildContext context,
    required TextTheme textTheme,
    required QuranAyahModel ayah,
  }) {
    return Obx(() {
      final settings = controller.settingsService;
      final bool isHighlighted =
          controller.highlightedAyahNumber.value == ayah.numberInSurah;
      final bool isBookmarked =
      settings.isAyahBookmarked(ayah.surahNumber, ayah.numberInSurah);

      return Container(
        margin: EdgeInsets.only(bottom: 12.sz),
        decoration: BoxDecoration(
          color: isHighlighted
              ? context.appColors.ayahHighlight
              : context.appColors.mushafPaper,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isHighlighted
                ? context.colorScheme.primary
                : context.appColors.mushafBorder,
            width: isHighlighted ? 1.4 : 1.0,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () => controller.markAyahAsLastRead(ayah),
          child: Padding(
            padding: ResponsiveUtils.allPadding(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Top Metadata Strip: Ayah Number, Para, Page, Ruku & Quick Actions
                Container(
                  padding: ResponsiveUtils.symmetricPadding(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: ResponsiveUtils.symmetricPadding(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${ayah.surahNumber}:${ayah.numberInSurah}',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      8.hSpace,
                      Flexible(
                        child: Text(
                          'Para ${ayah.juz} • Pg ${ayah.page} • Ruku ${ayah.ruku}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall,
                        ),
                      ),
                      if (ayah.hasSajda) ...<Widget>[
                        6.hSpace,
                        Container(
                          padding: ResponsiveUtils.symmetricPadding(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.appColors.sajdahMarker
                                .withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Sajdah',
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: context.appColors.sajdahMarker,
                            ),
                          ),
                        ),
                      ],
                      IconButton(
                        tooltip: 'Copy Ayah',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.copy_rounded, size: 17.sz),
                        onPressed: () {
                          final String copyPayload =
                              '${ayah.arabicText} (${ayah.referenceKey})\n\n${ayah.urduTranslation}\n${ayah.englishTranslation}';
                          Clipboard.setData(ClipboardData(text: copyPayload));
                          Get.snackbar(
                            'Copied',
                            'Ayah ${ayah.referenceKey} copied to clipboard.',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                          );
                        },
                      ),
                      IconButton(
                        tooltip:
                        isBookmarked ? 'Remove Bookmark' : 'Bookmark Ayah',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 19.sz,
                          color:
                          isBookmarked ? context.colorScheme.primary : null,
                        ),
                        onPressed: () => settings.toggleBookmarkAyah(
                          ayah.surahNumber,
                          ayah.numberInSurah,
                        ),
                      ),
                    ],
                  ),
                ),
                14.vSpace,

                // 1. Uthmani Arabic Script with Ornate End-of-Ayah Rosette (`﴿١١٣﴾`)
                RichText(
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    style: AppTheme.quranTextStyle(
                      context: context,
                      fontSize: settings.quranFontSize.value.sp,
                      height: 2.05,
                    ),
                    children: <InlineSpan>[
                      TextSpan(text: '${ayah.arabicText} '),
                      TextSpan(
                        text: '﴿${ayah.arabicIndicNumber}﴾',
                        style: TextStyle(
                          fontFamily: AppConstants.quranUthmaniFontFamily,
                          fontSize: (settings.quranFontSize.value * 0.85).sp,
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Urdu Translation in Authentic Noto Nastaliq Urdu (`نستعلیق`)
                if (settings.showUrduTranslation.value &&
                    ayah.urduTranslation.isNotEmpty) ...<Widget>[
                  14.vSpace,
                  Container(
                    padding: ResponsiveUtils.symmetricPadding(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer
                          .withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border(
                        right: BorderSide(
                          color: context.colorScheme.primary,
                          width: 3.0,
                        ),
                      ),
                    ),
                    child: Text(
                      ayah.urduTranslation,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.notoNastaliqUrdu(
                        fontSize: settings.translationFontSize.value.sp,
                        height: 2.05,
                        letterSpacing: 0,
                        color: context.appColors.urduTranslationText,
                      ),
                    ),
                  ),
                ],

                // 3. English Translation in Clean Plus Jakarta Sans
                if (settings.showEnglishTranslation.value &&
                    ayah.englishTranslation.isNotEmpty) ...<Widget>[
                  10.vSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.sz),
                    child: Text(
                      ayah.englishTranslation,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: (settings.translationFontSize.value - 1.5).sp,
                        height: 1.55,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Ornamental Ruku Marker (`ع — رکوع نمبر X • Ruku X`) rendered whenever a Ruku ends.
  Widget _buildRukuDividerBanner({
    required BuildContext context,
    required TextTheme textTheme,
    required int rukuNumber,
  }) {
    final Color goldAccent = context.colorScheme.secondary;
    final String arabicRukuNum = QuranAyahModel.toArabicIndicDigits(rukuNumber);

    return Container(
      margin: EdgeInsets.only(bottom: 14.sz, top: 2.sz),
      padding: ResponsiveUtils.symmetricPadding(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: goldAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: goldAccent.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 28.sz,
            height: 28.sz,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: goldAccent.withValues(alpha: 0.22),
              border: Border.all(color: goldAccent, width: 1.2),
            ),
            child: Text(
              'ع',
              style: TextStyle(
                fontFamily: AppConstants.quranUthmaniFontFamily,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: goldAccent,
              ),
            ),
          ),
          10.hSpace,
          Text(
            'رکوع نمبر $arabicRukuNum  •  End of Ruku $rukuNumber',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineRetryState(
      BuildContext context,
      TextTheme textTheme,
      SurahMeta surah,
      ) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.allPadding(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.wifi_off_rounded,
              size: 48.sz,
              color: context.colorScheme.outline,
            ),
            12.vSpace,
            Text(
              'Surah ${surah.englishName} Not Saved Offline Yet',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            6.vSpace,
            Text(
              'Connect to the internet once to download this Surah for permanent offline reading.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
            16.vSpace,
            FilledButton.icon(
              onPressed: () =>
                  controller.loadSurahContent(surah.number, forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry Download'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahSwitcherBar(
      BuildContext context,
      TextTheme textTheme,
      SurahMeta surah,
      ) {
    final bool hasPrev = surah.number > 1;
    final bool hasNext = surah.number < 114;

    return SafeArea(
      top: false,
      child: Container(
        padding: ResponsiveUtils.symmetricPadding(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          border: Border(
            top: BorderSide(color: context.colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton.icon(
              onPressed: hasPrev
                  ? () {
                _lastScrolledSurah = null;
                controller.openSurah(surahNumber: surah.number - 1);
              }
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
              label: const Text('Previous Surah'),
            ),
            Text(
              '${surah.number} / 114',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              onPressed: hasNext
                  ? () {
                _lastScrolledSurah = null;
                controller.openSurah(surahNumber: surah.number + 1);
              }
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
              label: const Text('Next Surah'),
            ),
          ],
        ),
      ),
    );
  }
}