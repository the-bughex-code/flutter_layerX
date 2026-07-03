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
