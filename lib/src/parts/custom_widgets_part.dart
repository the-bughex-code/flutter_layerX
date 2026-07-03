part of 'package:layerx_generator/src/layerx_generator.dart';

extension _CustomWidgetsPart on LayerXGenerator {
  Future<void> _createCustomWidgetFiles(String appDirPath) async {
    final root = Directory(path.join(appDirPath, 'custom_widgets'));

    for (final sub in [
      'dialogs',
      'buttons',
      'inputs',
      'snackbars',
      'animations',
    ]) {
      await Directory(path.join(root.path, sub)).create(recursive: true);
    }

    await File(
      path.join(root.path, 'dialogs', 'no_internet_dialog.dart'),
    ).writeAsString(_noInternetDialogContent());

    await File(
      path.join(root.path, 'buttons', 'app_button.dart'),
    ).writeAsString(_appButtonContent());

    await File(
      path.join(root.path, 'inputs', 'app_text_field.dart'),
    ).writeAsString(_appTextFieldContent());

    await File(
      path.join(root.path, 'snackbars', 'app_snackbar.dart'),
    ).writeAsString(_appSnackbarContent());

    await File(
      path.join(root.path, 'animations', 'app_animations.dart'),
    ).writeAsString(_appAnimationsContent());

    stdout.writeln('✅ Created custom widget files in custom_widgets/');
  }

  String _noInternetDialogContent() => r'''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../buttons/app_button.dart';

/// Lightweight dialog shown when the app cannot reach the server. Presented
/// through GetX so it can be triggered from anywhere without a [BuildContext].
class NoInternetDialog {
  const NoInternetDialog._();

  static Future<void> show({
    required String title,
    required String message,
    String closeText = 'Dismiss',
    VoidCallback? onClose,
  }) {
    return Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 44.r, color: AppColors.primary),
              SizedBox(height: 16.h),
              Text(title, textAlign: TextAlign.center, style: AppTextStyles.title),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
              SizedBox(height: 20.h),
              AppButton(
                label: closeText,
                width: double.infinity,
                onPressed: () {
                  if (Get.isDialogOpen ?? false) Get.back();
                  onClose?.call();
                },
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
''';

  String _appButtonContent() => r'''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../services/haptic_service.dart';

/// A premium, reusable button with a press-scale animation, ripple, optional
/// gradient, leading/trailing icons, a loading state and haptic feedback.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.suffixIcon,
    this.gradient,
    this.color,
    this.textColor,
    this.height,
    this.width,
    this.borderRadius,
    this.isLoading = false,
    this.enableHaptics = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? suffixIcon;
  final Gradient? gradient;
  final Color? color;
  final Color? textColor;
  final double? height;
  final double? width;
  final double? borderRadius;
  final bool isLoading;
  final bool enableHaptics;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _handleTap() {
    if (!_enabled) return;
    if (widget.enableHaptics) HapticService.light();
    widget.onPressed!.call();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius ?? 14.r);
    final textColor = widget.textColor ?? AppColors.white;
    final background =
        widget.gradient == null ? (widget.color ?? AppColors.primary) : null;

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Opacity(
        opacity: _enabled ? 1 : 0.6,
        child: Material(
          color: background,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: radius,
            ),
            child: InkWell(
              borderRadius: radius,
              onTap: _enabled ? _handleTap : null,
              onHighlightChanged:
                  _enabled ? (v) => setState(() => _pressed = v) : null,
              child: Container(
                height: widget.height ?? 52.h,
                width: widget.width,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: widget.isLoading
                    ? SizedBox(
                        height: 22.r,
                        width: 22.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: textColor, size: 20.r),
                            SizedBox(width: 8.w),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.button
                                  .copyWith(color: textColor),
                            ),
                          ),
                          if (widget.suffixIcon != null) ...[
                            SizedBox(width: 8.w),
                            Icon(widget.suffixIcon,
                                color: textColor, size: 20.r),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
''';

  String _appTextFieldContent() => r'''
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

/// A premium, reusable text field with a floating label, required marker,
/// prefix/suffix, focus & error styling, a soft shadow and responsive sizing.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.isRequired = false,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onTap,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool isRequired;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() => _focused = _focusNode.hasFocus);

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: AppTextStyles.label,
              children: [
                if (widget.isRequired)
                  TextSpan(
                    text: ' *',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.negativeRed),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: _focused
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.black.withValues(alpha: 0.04),
                blurRadius: _focused ? 16 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            readOnly: widget.readOnly,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textLightBlack),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: widget.readOnly ? AppColors.bgColor : AppColors.white,
              counterText: '',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              border: _border(AppColors.borderColor),
              enabledBorder: _border(AppColors.borderColor),
              focusedBorder: _border(AppColors.primary, width: 1.5),
              errorBorder: _border(AppColors.negativeRed),
              focusedErrorBorder: _border(AppColors.negativeRed, width: 1.5),
              errorStyle:
                  AppTextStyles.caption.copyWith(color: AppColors.negativeRed),
            ),
          ),
        ),
      ],
    );
  }
}
''';

  String _appSnackbarContent() => r'''
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
            Icons.check_circle_rounded, AppColors.positiveGreen);
      case _SnackType.error:
        return const _SnackConfig(Icons.error_rounded, AppColors.negativeRed);
      case _SnackType.warning:
        return const _SnackConfig(
            Icons.warning_amber_rounded, AppColors.warning);
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
''';

  String _appAnimationsContent() => r'''
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Fade + slide-up entrance animation.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
    this.offset = 24,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: Curves.easeOut)
        .moveY(begin: offset, end: 0, duration: duration, curve: Curves.easeOutCubic);
  }
}

/// Springy scale + fade entrance animation.
class SpringIn extends StatelessWidget {
  const SpringIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: const Duration(milliseconds: 300))
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
        );
  }
}

/// Scales its child down while pressed — wrap any tappable widget.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Continuous, subtle vertical floating loop.
class FloatingEffect extends StatelessWidget {
  const FloatingEffect({
    super.key,
    required this.child,
    this.offset = 6,
    this.duration = const Duration(milliseconds: 1800),
  });

  final Widget child;
  final double offset;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(begin: 0, end: offset, duration: duration, curve: Curves.easeInOut);
  }
}

/// A [Column] whose children fade/slide in one after another.
class StaggeredColumn extends StatelessWidget {
  const StaggeredColumn({
    super.key,
    required this.children,
    this.interval = const Duration(milliseconds: 90),
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
  });

  final List<Widget> children;
  final Duration interval;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (var i = 0; i < children.length; i++)
          FadeSlideIn(delay: interval * i, child: children[i]),
      ],
    );
  }
}
''';
}
