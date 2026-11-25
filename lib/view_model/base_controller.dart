import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../res/constants/app_strings.dart';

/// Base ViewModel class inherited by all screen controllers.
/// Centralizes reactive loading state, error messages, retry hooks, and safe async execution.
abstract class BaseController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Returns true when an error message is currently present.
  bool get hasError => errorMessage.value.isNotEmpty;

  /// Clears any existing error message.
  void clearError() {
    errorMessage.value = '';
  }

  /// Override in child controllers to define retry behavior for failed operations.
  Future<void> onRetry() async {}

  /// Executes an asynchronous [action] with automatic loading state and error capture.
  /// Set [showLoader] to false for silent background refreshes.
  Future<T?> runSafely<T>(
      Future<T> Function() action, {
        bool showLoader = true,
        String? fallbackErrorMessage,
        VoidCallback? onErrorCallback,
      }) async {
    try {
      clearError();
      if (showLoader) {
        isLoading.value = true;
      }
      return await action();
    } catch (error, stackTrace) {
      debugPrint('[$runtimeType] Error: $error\n$stackTrace');
      errorMessage.value = fallbackErrorMessage ?? AppStrings.unexpectedError.tr;
      onErrorCallback?.call();
      return null;
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }
}