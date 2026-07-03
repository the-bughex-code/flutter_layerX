import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_strings.dart';
import '../../../config/app_text_styles.dart';
import '../../../custom_widgets/animations/app_animations.dart';
import '../../view_model/splash/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingEffect(
              child: SpringIn(
                child: Container(
                  width: 96.r,
                  height: 96.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Text(
                    'LX',
                    style: AppTextStyles.displayLarge
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            FadeSlideIn(
              delay: const Duration(milliseconds: 250),
              child: Text(
                AppStrings.welcomeText,
                style: AppTextStyles.title.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
