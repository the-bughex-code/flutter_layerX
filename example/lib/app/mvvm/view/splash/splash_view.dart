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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingEffect(
                child: SpringIn(
                  child: Container(
                    width: 104.r,
                    height: 104.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.25),
                          blurRadius: 40,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Text(
                      'LX',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 250),
                child: Text(
                  AppStrings.welcomeText,
                  style: AppTextStyles.title.copyWith(color: AppColors.white),
                ),
              ),
              SizedBox(height: 8.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Clean architecture, ready to ship',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
