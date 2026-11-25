import 'package:flutter/widgets.dart';
import '../constants/app_constants.dart';

/// Adaptive layout builder supporting distinct layouts for:
/// - Mobile Portrait ([mobile])
/// - Mobile Landscape ([landscape])
/// - Tablet Portrait ([tablet])
/// - Tablet Landscape ([tabletLandscape])
class ResponsiveBuilder extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder? landscape;
  final WidgetBuilder? tablet;
  final WidgetBuilder? tabletLandscape;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.landscape,
    this.tablet,
    this.tabletLandscape,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isLandscape = screenSize.width > screenSize.height;
    final bool isTablet = screenSize.shortestSide >= AppConstants.maxTabletContentWidth;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (isTablet) {
          if (isLandscape && tabletLandscape != null) {
            return tabletLandscape!(context);
          }
          if (tablet != null) {
            return tablet!(context);
          }
          if (isLandscape && landscape != null) {
            return landscape!(context);
          }
        }

        if (isLandscape && landscape != null) {
          return landscape!(context);
        }

        return mobile(context);
      },
    );
  }
}