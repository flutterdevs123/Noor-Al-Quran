import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../res/constants/app_constants.dart';
import '../res/constants/app_strings.dart';
import '../res/routes/app_routes.dart';
import '../res/services/settings_service.dart';
import 'base_controller.dart';

/// Displays Noor Al-Quran splash screen for 3 seconds while running local readiness checks.
class SplashController extends BaseController {
  final SettingsService _settingsService = Get.find<SettingsService>();

  final RxString statusKey = AppStrings.splashInitializing.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeApp();
    });
  }

  /// Runs startup storage & locale checks in parallel with the 3-second splash display.
  Future<void> initializeApp() async {
    await runSafely<void>(
          () async {
        statusKey.value = AppStrings.splashVerifyingData;

        await Future.wait<void>(<Future<void>>[
          _performStartupChecks(),
          Future<void>.delayed(AppConstants.splashDisplayDuration),
        ]);

        Get.offAllNamed(AppRoutes.home);
      },
      fallbackErrorMessage: AppStrings.storageInitError.tr,
    );
  }

  Future<void> _performStartupChecks() async {
    final bool isStorageHealthy = _settingsService.verifyStorageIntegrity();
    if (!isStorageHealthy) {
      throw StateError(AppStrings.storageInitError.tr);
    }

    Get.changeThemeMode(_settingsService.themeMode.value);
    await Get.updateLocale(_settingsService.currentLocale.value);
  }

  @override
  Future<void> onRetry() => initializeApp();
}