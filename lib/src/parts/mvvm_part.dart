part of 'package:layerx_generator/src/layerx_generator.dart';


extension _MvvmPart on LayerXGenerator {
  Future<void> _createMVVMSkeleton(String appDirPath) async {
    // ================= SPLASH =================
    await File(
      path.join(appDirPath, 'mvvm', 'view_model', 'splash', 'splash_controller.dart'),
    ).writeAsString(r'''
import 'package:get/get.dart';

import '../../../config/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    await Get.offAllNamed(AppRoutes.loginView);
  }
}
''');

    await File(
      path.join(appDirPath, 'mvvm', 'view', 'splash', 'splash_view.dart'),
    ).writeAsString(r'''
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
''');

    // ================= LOGIN =================
    await File(
      path.join(appDirPath, 'mvvm', 'view_model', 'login', 'login_controller.dart'),
    ).writeAsString(r'''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/app_routes.dart';
import '../../../custom_widgets/snackbars/app_snackbar.dart';
import '../../../repository/auth_repository.dart';
import '../../model/body_model/login_request_model.dart';

class LoginController extends GetxController {
  LoginController(this._authRepository);

  final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  void togglePasswordVisibility() => obscurePassword.toggle();

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Minimum 6 characters';
    return null;
  }

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    try {
      final response = await _authRepository.login(
        LoginRequestModel(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );

      if (response.success == true) {
        'Welcome, ${response.data?.name ?? 'there'} 👋'.showSuccess();
        // Navigating away disposes this controller, so we must not mutate any
        // state (isLoading) afterwards — return before the clean-up below.
        await Get.offAllNamed(AppRoutes.homeView);
        return;
      }

      (response.message ?? 'Login failed. Please try again.').showError();
    } catch (_) {
      'Something went wrong. Please try again.'.showError();
    }
    isLoading.value = false;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
''');

    await File(
      path.join(appDirPath, 'mvvm', 'view', 'login', 'login_view.dart'),
    ).writeAsString(r'''
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
                Text(AppStrings.loginTitle, style: AppTextStyles.displayLarge),
                SizedBox(height: 8.h),
                Text(
                  AppStrings.loginSubtitle,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textLightBlack),
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
''');

    // ================= HOME =================
    await File(
      path.join(appDirPath, 'mvvm', 'view_model', 'home', 'home_controller.dart'),
    ).writeAsString(r'''
import 'package:get/get.dart';

import '../../../config/app_strings.dart';

class HomeController extends GetxController {
  final String title = AppStrings.welcomeText;

  final String intro = AppStrings.homeIntro;

  final List<({String icon, String title, String body})> highlights = const [
    (
      icon: '🧩',
      title: 'Modular MVVM',
      body: 'Clean separation of views, controllers, models and repositories.',
    ),
    (
      icon: '⚡',
      title: 'GetX Powered',
      body: 'Routing, dependency injection and reactive state, out of the box.',
    ),
    (
      icon: '🎨',
      title: 'Design System',
      body: 'Reusable buttons, inputs, snackbars, haptics and animations.',
    ),
  ];
}
''');

    await File(
      path.join(appDirPath, 'mvvm', 'view', 'home', 'home_view.dart'),
    ).writeAsString(r'''
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
''');

    stdout.writeln('Created MVVM screens (splash, login, home).');
  }
}
