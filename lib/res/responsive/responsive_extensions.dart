import 'package:flutter/widgets.dart';
import 'responsive_utils.dart';

/// Numeric extensions for concise, readable responsive sizing across all views.
extension ResponsiveNumExtension on num {
  /// Responsive general size (widths, heights, icon sizes, paddings).
  double get sz => ResponsiveUtils.scale(this);

  /// Responsive font size scaled smoothly to screen shortest side.
  double get sp => ResponsiveUtils.scaleFont(this);

  /// Responsive border radius value.
  double get r => ResponsiveUtils.scale(this);

  /// Vertical spacing widget (`12.vSpace`).
  SizedBox get vSpace => SizedBox(height: ResponsiveUtils.scale(this));

  /// Horizontal spacing widget (`8.hSpace`).
  SizedBox get hSpace => SizedBox(width: ResponsiveUtils.scale(this));
}

/// BuildContext extensions for quick device & orientation checks inside widgets.
extension ResponsiveContextExtension on BuildContext {
  bool get isSmallPhone => ResponsiveUtils.isSmallPhone;
  bool get isMobile => ResponsiveUtils.isMobile;
  bool get isTablet => ResponsiveUtils.isTablet;
  bool get isLandscape => ResponsiveUtils.isLandscape;
  bool get isPortrait => ResponsiveUtils.isPortrait;

  double get screenWidth => ResponsiveUtils.screenWidth;
  double get screenHeight => ResponsiveUtils.screenHeight;
  double get shortestSide => ResponsiveUtils.shortestSide;
}