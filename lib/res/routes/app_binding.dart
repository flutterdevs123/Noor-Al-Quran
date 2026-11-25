import 'package:get/get.dart';
import '../services/settings_service.dart';

/// Global dependency injection binding registered at application startup.
/// Permanent services (Settings, Database, Audio, Integrity) live here.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SettingsService>()) {
      Get.put<SettingsService>(SettingsService(), permanent: true);
    }
  }
}