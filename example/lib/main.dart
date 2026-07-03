import 'package:flutter/material.dart';

import 'app/app_widget.dart';
import 'app/config/config.dart';
import 'app/services/logger_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LoggerService.banner(name: AppConfig.appName, env: 'debug');

  // ✅ Uncomment when Firebase / Notifications are enabled:
  // await Firebase.initializeApp();
  // await NotificationService.initialize();

  runApp(const LayerXApp());
}
