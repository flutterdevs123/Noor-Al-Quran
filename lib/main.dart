import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'res/constants/app_constants.dart';
import 'res/localization/app_translations.dart';
import 'res/responsive/responsive_wrapper.dart';
import 'res/routes/app_binding.dart';
import 'res/routes/app_pages.dart';
import 'res/services/settings_service.dart';
import 'res/theme/app_theme.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
        () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Global Flutter framework error capture
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('[FlutterError] ${details.exceptionAsString()}');
      };

      // Initialize Background Audio & Lockscreen Notification Media Service safely
      try {
        await JustAudioBackground.init(
          androidNotificationChannelId: 'com.nooralquran.app.channel.audio',
          androidNotificationChannelName: 'Quran Tilawat Playback',
          androidNotificationOngoing: true,
          androidShowNotificationBadge: true,
        );
      } catch (e) {
        debugPrint('[AudioBackgroundInitError] $e');
      }

      // Initialize persistent local settings service before rendering UI
      final SettingsService settingsService = await SettingsService().init();
      Get.put<SettingsService>(settingsService, permanent: true);

      runApp(const IqraQuranApp());
    },
        (Object error, StackTrace stackTrace) {
      debugPrint('[UncaughtZoneError] $error\n$stackTrace');
    },
  );
}

class IqraQuranApp extends StatelessWidget {
  const IqraQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsService settingsService = Get.find<SettingsService>();

    return Obx(() {
      final bool isUrdu = settingsService.isUrdu;

      return GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,

        // Multi-Language Localization (English Default, Urdu Switchable)
        translations: AppTranslations(),
        locale: settingsService.currentLocale.value,
        fallbackLocale: SettingsService.englishLocale,

        // Material 3 Light & Dark Themes with Dynamic Typography
        theme: AppTheme.lightTheme(isUrdu: isUrdu),
        darkTheme: AppTheme.darkTheme(isUrdu: isUrdu),
        themeMode: settingsService.themeMode.value,

        // Global Dependency Injection & Routing
        initialBinding: AppBinding(),
        initialRoute: AppPages.initialRoute,
        getPages: AppPages.pages,
        defaultTransition: Transition.fadeIn,
        transitionDuration: AppConstants.routeTransitionDuration,

        // Root Responsive Scaling & Tablet Width Constraint
        builder: (BuildContext context, Widget? child) {
          return ResponsiveWrapper(
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
    });
  }
}