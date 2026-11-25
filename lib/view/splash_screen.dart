import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../res/constants/app_constants.dart';
import '../res/constants/app_strings.dart';
import '../res/responsive/responsive_extensions.dart';
import '../res/responsive/responsive_scroll_body.dart';
import '../res/theme/app_theme.dart';
import '../view_model/splash_controller.dart';

/// Initial startup screen displaying brand identity while running local readiness checks.
class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.appColors.heroGradient,
        ),
        child: ResponsiveScrollBody(
          hasExpandedChildren: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),

              // Islamic Emblem Container
              Container(
                width: 96.sz,
                height: 96.sz,
                decoration: BoxDecoration(
                  color: context.appColors.onHeroSecondary.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.appColors.onHeroSecondary,
                    width: 2.sz,
                  ),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 46.sz,
                  color: context.appColors.onHeroSecondary,
                ),
              ),
              20.vSpace,

              // Bismillah Header (Always Arabic RTL)
              Text(
                AppStrings.bismillah.tr,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: AppTheme.arabicHadithTextStyle(
                  context: context,
                  fontSize: 23.sp,
                ).copyWith(
                  color: context.appColors.onHeroSecondary,
                ),
              ),
              8.vSpace,

              // App Name (Referenced exclusively from AppConstants)
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: context.textTheme.displaySmall?.copyWith(
                  color: context.appColors.onHeroPrimary,
                ),
              ),
              8.vSpace,

              Text(
                AppStrings.appTagline.tr,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.appColors.onHeroMuted,
                ),
              ),

              const Spacer(),

              // Reactive Status / Error + Retry Section
              Obx(() {
                if (controller.hasError) {
                  return Column(
                    children: <Widget>[
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.errorContainer,
                        ),
                      ),
                      12.vSpace,
                      ElevatedButton.icon(
                        onPressed: controller.onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.onHeroSecondary,
                          foregroundColor: context.colorScheme.onSecondary,
                        ),
                        icon: Icon(Icons.refresh_rounded, size: 20.sz),
                        label: Text(AppStrings.retry.tr),
                      ),
                    ],
                  );
                }

                return Column(
                  children: <Widget>[
                    SizedBox(
                      width: 28.sz,
                      height: 28.sz,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: context.appColors.onHeroSecondary,
                      ),
                    ),
                    12.vSpace,
                    Text(
                      controller.statusKey.value.tr,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.appColors.onHeroMuted,
                      ),
                    ),
                  ],
                );
              }),
              24.vSpace,
            ],
          ),
        ),
      ),
    );
  }
}