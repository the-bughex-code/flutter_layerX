import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_strings.dart';
import '../../../config/app_text_styles.dart';
import '../../../custom_widgets/animations/app_animations.dart';
import '../../../custom_widgets/buttons/app_button.dart';
import '../../../custom_widgets/inputs/app_text_field.dart';
import '../../view_model/login/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Form(
            key: controller.formKey,
            child: StaggeredColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                Container(
                  width: 56.r,
                  height: 56.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Text(
                    'LX',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(AppStrings.loginTitle, style: AppTextStyles.displayLarge),
                SizedBox(height: 8.h),
                Text(
                  AppStrings.loginSubtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textLightBlack,
                  ),
                ),
                SizedBox(height: 36.h),
                AppTextField(
                  controller: controller.emailController,
                  label: AppStrings.emailLabel,
                  isRequired: true,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                  validator: controller.validateEmail,
                ),
                SizedBox(height: 20.h),
                Obx(
                  () => AppTextField(
                    controller: controller.passwordController,
                    label: AppStrings.passwordLabel,
                    isRequired: true,
                    hint: '••••••••',
                    obscureText: controller.obscurePassword.value,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: controller.obscurePassword.value
                          ? 'Show password'
                          : 'Hide password',
                      icon: Icon(
                        controller.obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    validator: controller.validatePassword,
                  ),
                ),
                SizedBox(height: 36.h),
                Obx(
                  () => AppButton(
                    label: AppStrings.signIn,
                    width: double.infinity,
                    isLoading: controller.isLoading.value,
                    suffixIcon: Icons.arrow_forward_rounded,
                    onPressed: controller.login,
                  ),
                ),
                SizedBox(height: 16.h),
                Center(
                  child: Text(
                    AppStrings.loginHint,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
