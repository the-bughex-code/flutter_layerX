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
