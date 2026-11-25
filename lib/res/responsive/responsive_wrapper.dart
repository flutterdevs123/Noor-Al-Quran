import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'responsive_utils.dart';

/// Root responsive wrapper intended for `GetMaterialApp.builder`.
/// - Updates [ResponsiveUtils] only when screen [Size] changes (ignores keyboard insets).
/// - Clamps system text scaling between [AppConstants.minSystemTextScale] and [AppConstants.maxSystemTextScale].
/// - Constrains max content width to [AppConstants.maxTabletContentWidth] on wide screens while keeping full-bleed background.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final bool constrainMaxWidth;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.constrainMaxWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    // Subscribes ONLY to screen Size changes; keyboard opening (viewInsets) will NOT rebuild this widget.
    final Size screenSize = MediaQuery.sizeOf(context);
    ResponsiveUtils.update(screenSize);

    // Clamp accessibility font scaling to protect Urdu Nastaliq & Arabic layouts from overflow.
    final TextScaler clampedTextScaler = MediaQuery.textScalerOf(context).clamp(
      minScaleFactor: AppConstants.minSystemTextScale,
      maxScaleFactor: AppConstants.maxSystemTextScale,
    );

    final MediaQueryData baseMediaQuery = MediaQuery.of(context);
    final bool shouldConstrain =
        constrainMaxWidth && screenSize.width > AppConstants.maxTabletContentWidth;

    Widget content = child;

    if (shouldConstrain) {
      content = ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxTabletContentWidth,
            ),
            child: content,
          ),
        ),
      );
    }

    return MediaQuery(
      data: baseMediaQuery.copyWith(textScaler: clampedTextScaler),
      child: content,
    );
  }
}