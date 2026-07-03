import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../services/haptic_service.dart';

enum _SnackType { success, error, warning, info }

/// Premium, dark-glass snackbars triggered from a plain [String]:
///
/// ```dart
/// 'Login successful'.showSuccess();
/// 'Please try again'.showError();
/// 'No changes to save'.showWarning();
/// ```
extension AppSnackbar on String {
  void showSuccess() => _AppSnackbars.show(this, _SnackType.success);
  void showError() => _AppSnackbars.show(this, _SnackType.error);
  void showWarning() => _AppSnackbars.show(this, _SnackType.warning);
  void showInfo() => _AppSnackbars.show(this, _SnackType.info);
}

class _AppSnackbars {
  static void show(String message, _SnackType type) {
    final config = _configFor(type);

    switch (type) {
      case _SnackType.success:
        HapticService.success();
      case _SnackType.error:
        HapticService.error();
      case _SnackType.warning:
      case _SnackType.info:
        HapticService.light();
    }

    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(config.icon, color: config.accent, size: 22.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.secondaryBlack.withValues(alpha: 0.9),
      borderColor: config.accent.withValues(alpha: 0.45),
      borderWidth: 1,
      borderRadius: 16.r,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 350),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    );
  }

  static _SnackConfig _configFor(_SnackType type) {
    switch (type) {
      case _SnackType.success:
        return const _SnackConfig(
          Icons.check_circle_rounded,
          AppColors.positiveGreen,
        );
      case _SnackType.error:
        return const _SnackConfig(Icons.error_rounded, AppColors.negativeRed);
      case _SnackType.warning:
        return const _SnackConfig(
          Icons.warning_amber_rounded,
          AppColors.warning,
        );
      case _SnackType.info:
        return const _SnackConfig(Icons.info_rounded, AppColors.primary);
    }
  }
}

class _SnackConfig {
  const _SnackConfig(this.icon, this.accent);
  final IconData icon;
  final Color accent;
}
