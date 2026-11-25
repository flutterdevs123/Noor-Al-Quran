import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../res/constants/app_strings.dart';
import '../res/routes/app_routes.dart';
import '../res/services/settings_service.dart';
import 'base_controller.dart';

/// Handles startup initialization checks and navigates directly to the Dashboard.
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

  /// Performs startup readiness checks (local storage, theme/locale) without fake delays.
  Future<void> initializeApp() async {
    await runSafely<void>(
          () async {
        statusKey.value = AppStrings.splashVerifyingData;

        final bool isStorageHealthy = _settingsService.verifyStorageIntegrity();
        if (!isStorageHealthy) {
          throw StateError(AppStrings.storageInitError.tr);
        }

        // Apply persisted theme & locale before entering Dashboard.
        Get.changeThemeMode(_settingsService.themeMode.value);
        await Get.updateLocale(_settingsService.currentLocale.value);

        // Navigate directly to Dashboard (no login/auth required).
        Get.offAllNamed(AppRoutes.home);
      },
      fallbackErrorMessage: AppStrings.storageInitError.tr,
    );
  }

  @override
  Future<void> onRetry() => initializeApp();
}