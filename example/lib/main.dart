import 'package:flutter/material.dart';

import 'app/app_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Uncomment when Firebase / Notifications are enabled:
  // await Firebase.initializeApp();
  // await NotificationService.initialize();

  runApp(const LayerXApp());
}
