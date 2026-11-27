import 'package:get/get.dart';
import '../../view_model/audio_quran_controller.dart';
import '../../view_model/quran_reader_controller.dart';
import '../services/settings_service.dart';

/// Global dependency injection binding registered at application startup.
/// Permanent services (Settings, Audio, Offline Quran Reader) live here.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SettingsService>()) {
      Get.put<SettingsService>(SettingsService(), permanent: true);
    }
    if (!Get.isRegistered<AudioQuranController>()) {
      Get.put<AudioQuranController>(AudioQuranController(), permanent: true);
    }
    if (!Get.isRegistered<QuranReaderController>()) {
      Get.put<QuranReaderController>(QuranReaderController(), permanent: true);
    }
  }
}