import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../custom_widgets/animations/app_animations.dart';
import '../../view_model/home/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: StaggeredColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Container(
                width: 64.r,
                height: 64.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'LX',
                  style: AppTextStyles.title.copyWith(color: AppColors.white),
                ),
              ),
              SizedBox(height: 24.h),
              Text(controller.title, style: AppTextStyles.displayLarge),
              SizedBox(height: 12.h),
              Text(
                controller.intro,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textLightBlack),
              ),
              SizedBox(height: 32.h),
              for (final h in controller.highlights)
                Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: _HighlightCard(
                    icon: h.icon,
                    title: h.title,
                    body: h.body,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final String icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: AppTextStyles.headline),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle),
                SizedBox(height: 4.h),
                Text(body, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
