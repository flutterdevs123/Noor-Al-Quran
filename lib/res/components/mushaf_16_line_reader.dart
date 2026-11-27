import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/qari_model.dart';
import '../../models/quran_ayah_model.dart';
import '../constants/app_constants.dart';
import '../responsive/responsive_extensions.dart';
import '../responsive/responsive_utils.dart';
import '../theme/app_theme.dart';

/// Represents one authentic Madani Mushaf page (`1`..`604`) within a Surah.
class _MadaniMushafPage {
  final int pageIndex;
  final int totalSurahPages;
  final int mushafPageNumber;
  final int juzNumber;
  final bool showBismillahBanner;
  final List<QuranAyahModel> ayahs;
  final List<int> completedRukus;
  final bool hasSajdahOnPage;

  const _MadaniMushafPage({
    required this.pageIndex,
    required this.totalSurahPages,
    required this.mushafPageNumber,
    required this.juzNumber,
    required this.showBismillahBanner,
    required this.ayahs,
    required this.completedRukus,
    required this.hasSajdahOnPage,
  });
}

/// Authentic 15-Line Madani Mushaf Reader (`صفحات القرآن`) with:
/// - True 604-page Madani Mushaf pagination (`ayah.page`)
/// - 3D perspective page-flip animation (RTL Arabic swipe + tap zones)
/// - FittedBox ornamental verse rosettes so 1-, 2-, and 3-digit numbers never clip
/// - Dedicated outer margin column for Ruku (`ع`) and Sajdah (`سجدہ`) markers
/// - Per-Ayah tap highlighting & Nastaliq Urdu / English translation sheet
class Mushaf16LineReader extends StatefulWidget {
  final SurahMeta surah;
  final List<QuranAyahModel> ayahs;
  final int initialAyahNumber;
  final int? playingAyahNumber;
  final bool Function(int surahNum, int ayahNum) isAyahBookmarked;
  final ValueChanged<QuranAyahModel> onPageAyahFocused;
  final Future<void> Function(int surahNum, int ayahNum) onToggleBookmark;
  final VoidCallback? onRequestNextSurah;
  final VoidCallback? onRequestPreviousSurah;

  const Mushaf16LineReader({
    super.key,
    required this.surah,
    required this.ayahs,
    required this.initialAyahNumber,
    this.playingAyahNumber,
    required this.isAyahBookmarked,
    required this.onPageAyahFocused,
    required this.onToggleBookmark,
    this.onRequestNextSurah,
    this.onRequestPreviousSurah,
  });

  @override
  State<Mushaf16LineReader> createState() => _Mushaf16LineReaderState();
}

class _Mushaf16LineReaderState extends State<Mushaf16LineReader> {
  static const int _madaniLinesPerPage = 15;

  late final List<_MadaniMushafPage> _madaniPages;
  late final PageController _pageController;
  double _currentPageValue = 0.0;
  int _activePageIndex = 0;
  int? _selectedAyahNumber;

  @override
  void initState() {
    super.initState();
    _selectedAyahNumber = widget.initialAyahNumber;
    _madaniPages = _groupAyahsByMadaniMushafPage(widget.ayahs);

    int initialPageIdx = 0;
    for (int i = 0; i < _madaniPages.length; i++) {
      if (_madaniPages[i].ayahs.any(
            (QuranAyahModel a) => a.numberInSurah >= widget.initialAyahNumber,
      )) {
        initialPageIdx = i;
        break;
      }
    }

    _activePageIndex = initialPageIdx;
    _currentPageValue = initialPageIdx.toDouble();
    _pageController = PageController(initialPage: initialPageIdx)
      ..addListener(_handlePageScroll);
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    super.dispose();
  }

  /// Groups [ayahs] by their exact Madani Mushaf `page` (`1`..`604`) so
  /// page numbers, Ayah ranges, and 15-line layout match printed Mushafs.
  List<_MadaniMushafPage> _groupAyahsByMadaniMushafPage(
      List<QuranAyahModel> ayahs,
      ) {
    if (ayahs.isEmpty) return const <_MadaniMushafPage>[];

    final Map<int, List<QuranAyahModel>> grouped = <int, List<QuranAyahModel>>{};
    for (final QuranAyahModel ayah in ayahs) {
      grouped.putIfAbsent(ayah.page, () => <QuranAyahModel>[]).add(ayah);
    }

    final List<int> sortedPageNumbers = grouped.keys.toList()..sort();
    final List<_MadaniMushafPage> result = <_MadaniMushafPage>[];

    for (int idx = 0; idx < sortedPageNumbers.length; idx++) {
      final int mushafPage = sortedPageNumbers[idx];
      final List<QuranAyahModel> pageAyahs = grouped[mushafPage]!;

      final List<int> completedRukus = <int>[];
      for (final QuranAyahModel ay in pageAyahs) {
        final int globalIdx = ayahs.indexOf(ay);
        final bool isSurahEnd = globalIdx == ayahs.length - 1;
        final bool isRukuEnd =
            isSurahEnd || ayahs[globalIdx + 1].ruku != ay.ruku;
        if (isRukuEnd && !completedRukus.contains(ay.ruku)) {
          completedRukus.add(ay.ruku);
        }
      }

      result.add(
        _MadaniMushafPage(
          pageIndex: idx,
          totalSurahPages: sortedPageNumbers.length,
          mushafPageNumber: mushafPage,
          juzNumber: pageAyahs.first.juz,
          showBismillahBanner:
          idx == 0 && widget.surah.number != 1 && widget.surah.number != 9,
          ayahs: pageAyahs,
          completedRukus: completedRukus,
          hasSajdahOnPage: pageAyahs.any((QuranAyahModel a) => a.hasSajda),
        ),
      );
    }

    return result;
  }

  void _handlePageScroll() {
    if (!mounted || !_pageController.hasClients) return;
    setState(() {
      _currentPageValue =
          _pageController.page ?? _activePageIndex.toDouble();
    });
  }

  void _turnToPage(int targetIndex) {
    if (!_pageController.hasClients) return;
    if (targetIndex < 0) {
      HapticFeedback.lightImpact();
      widget.onRequestPreviousSurah?.call();
      return;
    }
    if (targetIndex >= _madaniPages.length) {
      HapticFeedback.lightImpact();
      widget.onRequestNextSurah?.call();
      return;
    }

    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 440),
      curve: Curves.easeOutCubic,
    );
  }

  /// Dynamically calibrates font size so all Ayahs on this Madani Mushaf page
  /// fit cleanly inside the 15-line frame with zero vertical overflow.
  double _computeCalibratedFontSize({
    required _MadaniMushafPage pageData,
    required double maxTextWidth,
    required double availableTextHeight,
    required double lineHeightMultiplier,
  }) {
    final String combinedText = pageData.ayahs
        .map((QuranAyahModel a) => '${a.arabicText} (${a.arabicIndicNumber}) ')
        .join();

    double candidateFont = 23.0;
    const double minFont = 14.5;

    while (candidateFont > minFont) {
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: combinedText,
          style: TextStyle(
            fontFamily: AppConstants.quranUthmaniFontFamily,
            fontSize: candidateFont,
            height: lineHeightMultiplier,
            letterSpacing: 0,
          ),
        ),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: maxTextWidth);

      if (painter.height <= availableTextHeight) {
        return candidateFont;
      }
      candidateFont -= 0.5;
    }
    return minFont;
  }

  /// Opens a focused Translation & Bookmark bottom sheet when an Ayah is tapped.
  void _onAyahTapped(
      BuildContext context,
      _MadaniMushafPage pageData,
      QuranAyahModel tappedAyah,
      ) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedAyahNumber = tappedAyah.numberInSurah;
    });
    widget.onPageAyahFocused(tappedAyah);

    final TextTheme textTheme = Theme.of(context).textTheme;
    bool showAllOnPage = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.52,
          minChildSize: 0.36,
          maxChildSize: 0.88,
          builder: (BuildContext _, ScrollController scrollCtrl) {
            return StatefulBuilder(
              builder: (BuildContext _, StateSetter setSheetState) {
                final List<QuranAyahModel> itemsToShow = showAllOnPage
                    ? pageData.ayahs
                    : <QuranAyahModel>[tappedAyah];

                return Column(
                  children: <Widget>[
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(
                        horizontal: 18,
                        vertical: 4,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              showAllOnPage
                                  ? 'Mushaf Page ${pageData.mushafPageNumber} (${pageData.ayahs.length} Ayahs)'
                                  : 'Ayah ${tappedAyah.referenceKey} • Ruku ${tappedAyah.ruku}',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                showAllOnPage = !showAllOnPage;
                              });
                            },
                            child: Text(
                              showAllOnPage
                                  ? 'Selected Ayah Only'
                                  : 'All Page Ayahs (${pageData.ayahs.length})',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollCtrl,
                        padding: ResponsiveUtils.allPadding(16),
                        itemCount: itemsToShow.length,
                        separatorBuilder: (_, __) => 12.vSpace,
                        itemBuilder: (BuildContext _, int idx) {
                          final QuranAyahModel ay = itemsToShow[idx];
                          final bool bookmarked = widget.isAyahBookmarked(
                            ay.surahNumber,
                            ay.numberInSurah,
                          );

                          return Container(
                            padding: ResponsiveUtils.allPadding(14),
                            decoration: BoxDecoration(
                              color: context.appColors.mushafPaper,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: context.appColors.mushafBorder,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      padding: ResponsiveUtils.symmetricPadding(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.colorScheme.primary,
                                        borderRadius:
                                        BorderRadius.circular(20.r),
                                      ),
                                      child: Text(
                                        ay.referenceKey,
                                        style: textTheme.labelSmall?.copyWith(
                                          color: context.colorScheme.onPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    8.hSpace,
                                    Text(
                                      'Para ${ay.juz} • Page ${ay.page} • Ruku ${ay.ruku}',
                                      style: textTheme.labelSmall,
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      tooltip: 'Copy Ayah',
                                      visualDensity: VisualDensity.compact,
                                      icon: Icon(Icons.copy_rounded, size: 18.sz),
                                      onPressed: () {
                                        final String payload =
                                            '${ay.arabicText} (${ay.referenceKey})\n\n${ay.urduTranslation}\n${ay.englishTranslation}';
                                        Clipboard.setData(
                                          ClipboardData(text: payload),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      tooltip: 'Bookmark Ayah',
                                      visualDensity: VisualDensity.compact,
                                      icon: Icon(
                                        bookmarked
                                            ? Icons.bookmark_rounded
                                            : Icons.bookmark_border_rounded,
                                        color: bookmarked
                                            ? context.colorScheme.primary
                                            : null,
                                      ),
                                      onPressed: () async {
                                        await widget.onToggleBookmark(
                                          ay.surahNumber,
                                          ay.numberInSurah,
                                        );
                                        setSheetState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                8.vSpace,
                                Text(
                                  '${ay.arabicText} ﴿${ay.arabicIndicNumber}﴾',
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  style: AppTheme.quranTextStyle(
                                    context: context,
                                    fontSize: 22.sp,
                                    height: 1.95,
                                  ),
                                ),
                                if (ay.urduTranslation.isNotEmpty) ...<Widget>[
                                  10.vSpace,
                                  Text(
                                    ay.urduTranslation,
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                    style: GoogleFonts.notoNastaliqUrdu(
                                      fontSize: 15.5.sp,
                                      height: 2.05,
                                      letterSpacing: 0,
                                      color:
                                      context.appColors.urduTranslationText,
                                    ),
                                  ),
                                ],
                                if (ay.englishTranslation.isNotEmpty) ...<Widget>[
                                  10.vSpace,
                                  Text(
                                    ay.englishTranslation,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5.sp,
                                      height: 1.5,
                                      color:
                                      context.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (_madaniPages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double outerWidth = constraints.maxWidth - 16.sz;
        final double outerHeight = constraints.maxHeight - 12.sz;

        // Reserve 34.sz on the left margin for Ruku (`ع`) & Sajdah markers
        final double marginStripWidth = 34.sz;
        final double innerTextWidth =
        (outerWidth - marginStripWidth - 36.sz).clamp(200.0, 900.0);
        final double bodyAvailableHeight =
        (outerHeight - 86.sz).clamp(260.0, 1200.0);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.sz, vertical: 6.sz),
          child: PageView.builder(
            controller: _pageController,
            reverse: true, // Authentic Arabic RTL: swipe Left-to-Right for next page
            itemCount: _madaniPages.length,
            onPageChanged: (int newIdx) {
              HapticFeedback.selectionClick();
              setState(() => _activePageIndex = newIdx);
              if (_madaniPages[newIdx].ayahs.isNotEmpty) {
                widget.onPageAyahFocused(_madaniPages[newIdx].ayahs.first);
              }
            },
            itemBuilder: (BuildContext context, int index) {
              final _MadaniMushafPage pageData = _madaniPages[index];
              final double delta = index - _currentPageValue;

              // Realistic 3D Book Page-Flip Perspective Transform
              final double clampedDelta = delta.clamp(-1.0, 1.0);
              final double rotationY = -clampedDelta * (math.pi / 3.5);
              final double scale = 1.0 - (clampedDelta.abs() * 0.03);
              final double shadowOpacity =
              (clampedDelta.abs() * 0.26).clamp(0.0, 0.26);

              return Transform(
                alignment: clampedDelta >= 0
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0011)
                  ..rotateY(rotationY)
                  ..scale(scale, scale),
                child: Stack(
                  children: <Widget>[
                    _buildMadaniPageCard(
                      context: context,
                      textTheme: textTheme,
                      pageData: pageData,
                      marginStripWidth: marginStripWidth,
                      innerTextWidth: innerTextWidth,
                      bodyAvailableHeight: bodyAvailableHeight,
                    ),

                    if (shadowOpacity > 0.01)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.r),
                              gradient: LinearGradient(
                                begin: clampedDelta >= 0
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                end: clampedDelta >= 0
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                colors: <Color>[
                                  Colors.black.withValues(alpha: shadowOpacity),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMadaniPageCard({
    required BuildContext context,
    required TextTheme textTheme,
    required _MadaniMushafPage pageData,
    required double marginStripWidth,
    required double innerTextWidth,
    required double bodyAvailableHeight,
  }) {
    final Color borderClr = context.appColors.mushafBorder;
    final Color goldAccent = context.colorScheme.secondary;
    final double bannerHeight = pageData.showBismillahBanner ? 44.sz : 0.0;
    final double netTextHeight =
    (bodyAvailableHeight - bannerHeight - 6.sz).clamp(200.0, 1100.0);

    const double lineHeightMultiplier = 1.88;
    final double calibratedFontSize = _computeCalibratedFontSize(
      pageData: pageData,
      maxTextWidth: innerTextWidth,
      availableTextHeight: netTextHeight,
      lineHeightMultiplier: lineHeightMultiplier,
    );

    final String arabicJuz =
    QuranAyahModel.toArabicIndicDigits(pageData.juzNumber);
    final String arabicMushafPage =
    QuranAyahModel.toArabicIndicDigits(pageData.mushafPageNumber);
    final String arabicCurrentIdx =
    QuranAyahModel.toArabicIndicDigits(pageData.pageIndex + 1);
    final String arabicTotalIdx =
    QuranAyahModel.toArabicIndicDigits(pageData.totalSurahPages);

    final bool isFirstPage = pageData.pageIndex == 0;
    final bool isLastPage =
        pageData.pageIndex == pageData.totalSurahPages - 1;

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.mushafPaper,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderClr, width: 1.8),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(4.sz),
        padding: EdgeInsets.fromLTRB(8.sz, 7.sz, 10.sz, 7.sz),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: goldAccent.withValues(alpha: 0.45),
            width: 1.0,
          ),
        ),
        child: Column(
          children: <Widget>[
            // Compact Top Header: Uniform Arabic-Indic Numerals, NO duplicate Surah name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'الجزء $arabicJuz',
                  style: TextStyle(
                    fontFamily: AppConstants.quranUthmaniFontFamily,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ),
                ),
                Container(
                  padding: ResponsiveUtils.symmetricPadding(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer
                        .withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'صفحة $arabicMushafPage  •  $arabicCurrentIdx / $arabicTotalIdx',
                    style: TextStyle(
                      fontFamily: AppConstants.quranUthmaniFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Text(
                  'الركوع ${QuranAyahModel.toArabicIndicDigits(pageData.ayahs.first.ruku)}',
                  style: TextStyle(
                    fontFamily: AppConstants.quranUthmaniFontFamily,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ),
                ),
              ],
            ),
            4.vSpace,
            Divider(height: 1, color: borderClr),

            // Main Mushaf Body: Outer Side Margin (Ruku `ع` & Sajdah) + 15-Line Text Frame
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Left Outer Margin Strip for Ruku (`ع`) & Sajdah (`سجدہ`) Markers
                  Container(
                    width: marginStripWidth,
                    padding: EdgeInsets.symmetric(vertical: 8.sz),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: borderClr.withValues(alpha: 0.45),
                          width: 0.8,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        if (pageData.completedRukus.isNotEmpty)
                          ...pageData.completedRukus.map(
                                (int rukuNum) => _buildMarginRukuBadge(
                              context: context,
                              rukuNumber: rukuNum,
                              goldAccent: goldAccent,
                            ),
                          ),
                        if (pageData.hasSajdahOnPage)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.sz,
                              vertical: 4.sz,
                            ),
                            decoration: BoxDecoration(
                              color: context.appColors.sajdahMarker
                                  .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: context.appColors.sajdahMarker,
                                width: 0.9,
                              ),
                            ),
                            child: Text(
                              'سجدہ',
                              style: TextStyle(
                                fontFamily: AppConstants.quranUthmaniFontFamily,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: context.appColors.sajdahMarker,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  8.hSpace,

                  // 15-Line Ruled Quran Text Area
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        // Faint 15-Line Printed Mushaf Guide Rules
                        Column(
                          children: List<Widget>.generate(
                            _madaniLinesPerPage,
                                (_) => Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: borderClr.withValues(alpha: 0.22),
                                      width: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Compact Bismillah-Only Opening Banner + Justified Ayahs
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            if (pageData.showBismillahBanner)
                              _buildBismillahOnlyBanner(
                                context,
                                bannerHeight,
                              ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: 2.sz),
                                child: RichText(
                                  textAlign: TextAlign.justify,
                                  textDirection: TextDirection.rtl,
                                  overflow: TextOverflow.clip,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontFamily:
                                      AppConstants.quranUthmaniFontFamily,
                                      fontSize: calibratedFontSize,
                                      height: lineHeightMultiplier,
                                      letterSpacing: 0,
                                      color: context.appColors.quranArabicText,
                                    ),
                                    children: _buildInteractiveAyahSpans(
                                      context: context,
                                      pageData: pageData,
                                      fontSize: calibratedFontSize,
                                      goldAccent: goldAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // High-Contrast, Unambiguous RTL Navigation Footer
            Divider(height: 1, color: borderClr),
            5.vSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Left Button (RTL Forward = Next Page, or Next Surah on last page)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.symmetric(horizontal: 8.sz),
                    foregroundColor: context.colorScheme.onSurface,
                  ),
                  onPressed: () => _turnToPage(pageData.pageIndex + 1),
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 20.sz,
                    color: context.colorScheme.primary,
                  ),
                  label: Text(
                    isLastPage ? 'Next Surah' : 'Next Page',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ),

                // Center Helper Pill
                Container(
                  padding: ResponsiveUtils.symmetricPadding(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'Tap any Ayah for Tarjuma',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ),

                // Right Button (RTL Backward = Prev Page, or Prev Surah on page 1)
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.symmetric(horizontal: 8.sz),
                    foregroundColor: context.colorScheme.onSurface,
                  ),
                  onPressed: (isFirstPage && widget.surah.number == 1)
                      ? null
                      : () => _turnToPage(pageData.pageIndex - 1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        isFirstPage ? 'Prev Surah' : 'Prev Page',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: (isFirstPage && widget.surah.number == 1)
                              ? context.colorScheme.outline
                              : context.colorScheme.onSurface,
                        ),
                      ),
                      2.hSpace,
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20.sz,
                        color: (isFirstPage && widget.surah.number == 1)
                            ? context.colorScheme.outline
                            : context.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds interactive `InlineSpan`s for every Ayah on the page, using a
  /// `FittedBox` gold rosette `WidgetSpan` so 1-, 2-, and 3-digit verse numbers
  /// (`١` .. `٢٨٦`) always stay centered inside the ornament without clipping.
  List<InlineSpan> _buildInteractiveAyahSpans({
    required BuildContext context,
    required _MadaniMushafPage pageData,
    required double fontSize,
    required Color goldAccent,
  }) {
    final List<InlineSpan> spans = <InlineSpan>[];

    for (final QuranAyahModel ayah in pageData.ayahs) {
      final bool isSelected =
          _selectedAyahNumber == ayah.numberInSurah ||
              widget.playingAyahNumber == ayah.numberInSurah;

      spans.add(
        TextSpan(
          text: '${ayah.arabicText} ',
          style: isSelected
              ? TextStyle(
            backgroundColor: context.appColors.ayahHighlight,
          )
              : null,
          recognizer: TapGestureRecognizer()
            ..onTap = () => _onAyahTapped(context, pageData, ayah),
        ),
      );

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: () => _onAyahTapped(context, pageData, ayah),
            child: Container(
              width: fontSize * 1.18,
              height: fontSize * 1.18,
              margin: EdgeInsets.symmetric(horizontal: 2.sz),
              padding: EdgeInsets.all(2.5.sz),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: goldAccent.withValues(alpha: 0.16),
                border: Border.all(
                  color: goldAccent,
                  width: 1.35,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  ayah.arabicIndicNumber,
                  style: TextStyle(
                    fontFamily: AppConstants.quranUthmaniFontFamily,
                    fontSize: fontSize * 0.68,
                    fontWeight: FontWeight.bold,
                    color: goldAccent,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      spans.add(const TextSpan(text: ' '));
    }

    return spans;
  }

  /// Side-margin Ruku badge (`ع` + Arabic-Indic Ruku number) matching printed Mushafs.
  Widget _buildMarginRukuBadge({
    required BuildContext context,
    required int rukuNumber,
    required Color goldAccent,
  }) {
    final String arabicRuku = QuranAyahModel.toArabicIndicDigits(rukuNumber);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.sz, vertical: 4.sz),
      decoration: BoxDecoration(
        color: goldAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: goldAccent, width: 1.1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'ع',
            style: TextStyle(
              fontFamily: AppConstants.quranUthmaniFontFamily,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: goldAccent,
              height: 1.0,
            ),
          ),
          2.vSpace,
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              arabicRuku,
              style: TextStyle(
                fontFamily: AppConstants.quranUthmaniFontFamily,
                fontSize: 10.5.sp,
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Compact Bismillah-only opening banner (Surah name stays solely in the AppBar).
  Widget _buildBismillahOnlyBanner(BuildContext context, double height) {
    return Container(
      height: height,
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: 4.sz),
      padding: EdgeInsets.symmetric(horizontal: 12.sz),
      decoration: BoxDecoration(
        gradient: context.appColors.heroGradient,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.colorScheme.secondary.withValues(alpha: 0.45),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: AppConstants.quranUthmaniFontFamily,
            fontSize: 20.sp,
            color: context.appColors.onHeroPrimary,
          ),
        ),
      ),
    );
  }
}