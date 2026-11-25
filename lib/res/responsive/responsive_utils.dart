import 'package:flutter/widgets.dart';
import '../constants/app_constants.dart';

/// Core responsive calculation utility based on the device's shortest side.
/// Scaling by shortestSide prevents oversized UI elements in landscape mode.
class ResponsiveUtils {
  ResponsiveUtils._();

  static Size _lastSize = Size.zero;
  static double _screenWidth = AppConstants.designBaseWidth;
  static double _screenHeight = 812.0;
  static double _shortestSide = AppConstants.designBaseWidth;
  static double _longestSide = 812.0;
  static double _scaleFactor = 1.0;

  /// Updates cached screen metrics only when actual screen dimensions change.
  /// Keyboard appearance (viewInsets) does not alter [size], preventing unnecessary recalculations.
  static void update(Size size) {
    if (size.isEmpty || size == _lastSize) return;

    _lastSize = size;
    _screenWidth = size.width;
    _screenHeight = size.height;
    _shortestSide = size.shortestSide;
    _longestSide = size.longestSide;

    final double rawScale = _shortestSide / AppConstants.designBaseWidth;
    _scaleFactor = rawScale.clamp(
      AppConstants.minScaleFactor,
      AppConstants.maxScaleFactor,
    );
  }

  // ===========================================================================
  // SCREEN METRICS & DEVICE CLASSIFICATION
  // ===========================================================================
  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
  static double get shortestSide => _shortestSide;
  static double get longestSide => _longestSide;
  static double get scaleFactor => _scaleFactor;

  /// True for compact devices (e.g., 320px width phones).
  static bool get isSmallPhone => _shortestSide < 360.0;

  /// True for standard smartphones in either orientation.
  static bool get isMobile => _shortestSide < AppConstants.maxTabletContentWidth;

  /// True for tablets and large foldables (shortestSide >= 600px).
  static bool get isTablet => _shortestSide >= AppConstants.maxTabletContentWidth;

  /// True when viewport width exceeds viewport height.
  static bool get isLandscape => _screenWidth > _screenHeight;

  /// True when viewport height is greater than or equal to viewport width.
  static bool get isPortrait => _screenHeight >= _screenWidth;

  // ===========================================================================
  // SCALING HELPERS
  // ===========================================================================
  /// Scales dimensions (padding, icon size, radius, spacing) proportionally.
  static double scale(num value) => value.toDouble() * _scaleFactor;

  /// Scales typography sizes with safe clamping so text remains readable.
  static double scaleFont(num value) => value.toDouble() * _scaleFactor;

  /// Returns RTL-safe symmetric directional padding using scaled values.
  static EdgeInsetsDirectional symmetricPadding({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsetsDirectional.symmetric(
      horizontal: scale(horizontal),
      vertical: scale(vertical),
    );
  }

  /// Returns RTL-safe uniform directional padding using scaled values.
  static EdgeInsetsDirectional allPadding(double value) {
    return EdgeInsetsDirectional.all(scale(value));
  }

  /// Returns RTL-safe custom directional padding using scaled values.
  static EdgeInsetsDirectional onlyPadding({
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) {
    return EdgeInsetsDirectional.only(
      start: scale(start),
      top: scale(top),
      end: scale(end),
      bottom: scale(bottom),
    );
  }

  /// Computes adaptive grid column counts across mobile/tablet & portrait/landscape.
  static int adaptiveGridColumns({
    int mobilePortrait = 1,
    int mobileLandscape = 2,
    int tabletPortrait = 2,
    int tabletLandscape = 3,
  }) {
    if (isTablet) {
      return isLandscape ? tabletLandscape : tabletPortrait;
    }
    return isLandscape ? mobileLandscape : mobilePortrait;
  }
}