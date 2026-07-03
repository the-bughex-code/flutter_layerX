import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/padding_extensions.dart';
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
              Container(
                width: 64.r,
                height: 64.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'LX',
                  style: AppTextStyles.title.copyWith(color: AppColors.white),
                ),
              ).paddingBottom(24.h),
              Text(
                controller.title,
                style: AppTextStyles.displayLarge,
              ).paddingBottom(12.h),
              Text(
                controller.intro,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textLightBlack,
                ),
              ).paddingBottom(32.h),
              for (final h in controller.highlights)
                _HighlightCard(
                  icon: h.icon,
                  title: h.title,
                  body: h.body,
                ).paddingBottom(14.h),
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
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(icon, style: AppTextStyles.subtitle),
          ).paddingRight(14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle).paddingBottom(4.h),
                Text(body, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
