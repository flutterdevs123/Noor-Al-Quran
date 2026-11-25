import 'package:flutter/material.dart';
import 'responsive_utils.dart';

/// Safe, overflow-proof scrollable container for full screens.
/// Guarantees full viewport width & minimum viewport height even on small 320px displays
/// or in landscape orientation when the soft keyboard is visible.
class ResponsiveScrollBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool useSafeArea;
  final bool topSafeArea;
  final bool bottomSafeArea;
  final bool hasExpandedChildren;
  final Future<void> Function()? onRefresh;

  const ResponsiveScrollBody({
    super.key,
    required this.child,
    this.padding,
    this.physics,
    this.controller,
    this.useSafeArea = true,
    this.topSafeArea = true,
    this.bottomSafeArea = true,
    this.hasExpandedChildren = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry resolvedPadding =
        padding ?? ResponsiveUtils.symmetricPadding(horizontal: 16, vertical: 16);

    Widget scrollView = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Widget innerChild = Padding(
          padding: resolvedPadding,
          child: child,
        );

        if (hasExpandedChildren) {
          innerChild = IntrinsicHeight(child: innerChild);
        }

        return SingleChildScrollView(
          controller: controller,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: onRefresh != null
              ? const AlwaysScrollableScrollPhysics()
              : (physics ?? const BouncingScrollPhysics()),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              minHeight: constraints.maxHeight,
            ),
            child: innerChild,
          ),
        );
      },
    );

    if (onRefresh != null) {
      scrollView = RefreshIndicator(
        onRefresh: onRefresh!,
        color: Theme.of(context).colorScheme.primary,
        child: scrollView,
      );
    }

    if (useSafeArea) {
      return SafeArea(
        top: topSafeArea,
        bottom: bottomSafeArea,
        child: scrollView,
      );
    }

    return scrollView;
  }
}