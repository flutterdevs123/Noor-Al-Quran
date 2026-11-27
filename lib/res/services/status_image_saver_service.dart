import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import '../../models/daily_inspiration_model.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Renders a 9:16 WhatsApp/Instagram Status-ready graphic card for a given
/// [DailyInspirationModel] and saves the high-resolution PNG directly to the user's Gallery.
class StatusImageSaverService {
  static Future<bool> saveStatusImageToGallery({
    required BuildContext context,
    required DailyInspirationModel item,
    required bool isUrdu,
  }) async {
    if (kIsWeb) {
      debugPrint('[StatusImageSaverService] Gallery save requires Android/iOS.');
      return false;
    }

    final GlobalKey boundaryKey = GlobalKey();
    final OverlayState? overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return false;

    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext ctx) {
        return Positioned(
          left: -4000,
          top: -4000,
          child: Material(
            color: AppColors.transparent,
            child: RepaintBoundary(
              key: boundaryKey,
              child: _StatusPosterCanvas(
                item: item,
                isUrdu: isUrdu,
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(entry);

    try {
      // Allow two frames so fonts and Arabic/Urdu shaping lay out completely
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await WidgetsBinding.instance.endOfFrame;

      final RenderObject? renderObject =
      boundaryKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        return false;
      }

      final ui.Image image = await renderObject.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData == null) return false;
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Gal.putImageBytes automatically handles Android/iOS runtime permissions and saves to album
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await Gal.putImageBytes(
        pngBytes,
        album: AppConstants.appName,
        name: '${AppConstants.appName.replaceAll(' ', '_')}_${item.id}_$timestamp',
      );
      return true;
    } on GalException catch (e) {
      debugPrint('[StatusImageSaverService] GalException (${e.type}): ${e.toString()}');
      return false;
    } catch (e) {
      debugPrint('[StatusImageSaverService] Failed to save status image: $e');
      return false;
    } finally {
      entry.remove();
    }
  }
}

/// 9:16 Portrait Status Poster Widget (360 x 640 logical -> 1080 x 1920 @ 3x).
class _StatusPosterCanvas extends StatelessWidget {
  final DailyInspirationModel item;
  final bool isUrdu;

  const _StatusPosterCanvas({
    required this.item,
    required this.isUrdu,
  });

  @override
  Widget build(BuildContext context) {
    final String badgeText = item.isAyah
        ? AppStrings.dailyAyahBadge.tr
        : AppStrings.dailyHadithBadge.tr;

    return Container(
      width: 360,
      height: 640,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: AppColors.shareCardGradient,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.onHeroSecondary.withValues(alpha: 0.65),
            width: 1.5,
          ),
          color: AppColors.onHeroPrimary.withValues(alpha: 0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Top Bismillah Header
            Text(
              AppStrings.bismillah.tr,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: AppTheme.arabicHadithTextStyle(
                context: context,
                fontSize: 18,
                height: 1.6,
              ).copyWith(color: AppColors.onHeroSecondary),
            ),
            const SizedBox(height: 16),

            // Center Type Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.onHeroSecondary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.onHeroSecondary,
                    width: 1,
                  ),
                ),
                child: Text(
                  badgeText,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.onHeroSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Main Arabic Ayah / Hadith Text
            Text(
              item.arabicText,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: (item.isAyah
                  ? AppTheme.quranTextStyle(
                context: context,
                fontSize: 23,
                height: 1.95,
              )
                  : AppTheme.arabicHadithTextStyle(
                context: context,
                fontSize: 21,
                height: 1.85,
              ))
                  .copyWith(color: AppColors.onHeroPrimary),
            ),
            const SizedBox(height: 20),

            // Subtle Gold Divider
            Center(
              child: Container(
                width: 64,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.onHeroSecondary.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Localized Translation
            Text(
              item.localizedTranslation(isUrdu: isUrdu),
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.onHeroMuted,
                height: isUrdu ? 1.85 : 1.55,
              ),
            ),

            const Spacer(),

            // Dedicated Bottom Reference Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.onHeroPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.localizedReference(isUrdu: isUrdu),
                textAlign: TextAlign.center,
                style: context.textTheme.labelMedium?.copyWith(
                  color: AppColors.onHeroSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // App Brand Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.menu_book_rounded,
                  size: 14,
                  color: AppColors.onHeroSecondary.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 6),
                Text(
                  AppConstants.appName,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.onHeroMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}