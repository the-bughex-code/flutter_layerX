part of 'package:layerx_generator/src/layerx_generator.dart';


extension _AppPart on LayerXGenerator {
  Future<void> _createAppWidgetFile(String projectPath) async {
    final appDir = Directory(path.join(projectPath, 'lib', 'app'));

    await File(path.join(appDir.path, 'app_widget.dart')).writeAsString('''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'config/app_colors.dart';
import 'config/app_routes.dart';
import 'config/config.dart';

/// Root widget of the LayerX application.
///
/// Wires up [ScreenUtil] for responsive sizing and GetX for navigation and
/// state management. Styling is intentionally lightweight — extend the
/// [ThemeData] below or introduce your own design tokens as the app grows.
class LayerXApp extends StatelessWidget {
  const LayerXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConfig.appName,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: AppColors.primary,
            scaffoldBackgroundColor: AppColors.bgColor,
          ),
          initialRoute: AppRoutes.splashView,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
''');

    stdout.writeln('Created app_widget.dart');
  }

  Future<void> _updateMainFile(String projectPath) async {
    final mainFile = File(path.join(projectPath, 'lib', 'main.dart'));

    await mainFile.writeAsString('''
import 'package:flutter/material.dart';

import 'app/app_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Uncomment when Firebase / Notifications are enabled:
  // await Firebase.initializeApp();
  // await NotificationService.initialize();

  runApp(const LayerXApp());
}
''');

    stdout.writeln('Updated main.dart');
  }

  /// Replaces the default `test/widget_test.dart` (which references the
  /// removed `MyApp`) with a smoke test that boots [LayerXApp].
  Future<void> _createWidgetTest(String projectPath) async {
    final testDir = Directory(path.join(projectPath, 'test'));
    await testDir.create(recursive: true);

    final packageName = _readProjectName(projectPath);

    await File(path.join(testDir.path, 'widget_test.dart')).writeAsString('''
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:$packageName/app/app_widget.dart';
import 'package:$packageName/app/mvvm/view/login/login_view.dart';
import 'package:$packageName/app/mvvm/view/splash/splash_view.dart';

void main() {
  // Avoid network font fetches during tests.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('LayerXApp boots to splash then routes to login',
      (tester) async {
    await tester.pumpWidget(const LayerXApp());
    await tester.pump();
    expect(find.byType(SplashView), findsOneWidget);

    // Fire the splash delay, then let the login screen settle in.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });
}
''');

    stdout.writeln('Updated test/widget_test.dart');
  }

  /// Ensures the project's analyzer ignores `build/`.
  ///
  /// Plugins resolved through Swift Package Manager (e.g. `firebase_messaging`)
  /// check their full Dart source — including their own `test/` folders — into
  /// `build/ios/SourcePackages`. Without this exclude, `flutter analyze` reports
  /// dozens of errors from those third-party test files. This is standard
  /// practice for production Flutter projects.
  Future<void> _ensureAnalysisOptions(String projectPath) async {
    final file = File(path.join(projectPath, 'analysis_options.yaml'));

    if (!file.existsSync()) {
      await file.writeAsString('''
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - "**/*.g.dart"
    - "**/*.freezed.dart"
''');
      stdout.writeln('Created analysis_options.yaml');
      return;
    }

    final content = file.readAsStringSync();
    if (content.contains('build/**')) return;

    final lines = content.split('\n');
    final analyzerIdx = lines.indexWhere(
      (l) => RegExp(r'^analyzer:').hasMatch(l),
    );

    // No `analyzer:` block yet → append a complete one.
    if (analyzerIdx == -1) {
      final buffer = StringBuffer(content);
      if (!content.endsWith('\n')) buffer.writeln();
      buffer.write('''
analyzer:
  exclude:
    - build/**
    - "**/*.g.dart"
    - "**/*.freezed.dart"
''');
      await file.writeAsString(buffer.toString());
      stdout.writeln('Updated analysis_options.yaml (excluded build/).');
      return;
    }

    // An `analyzer:` block exists — merge the exclude into it rather than
    // adding a second (invalid) top-level key. Bound the search to this block.
    var blockEnd = lines.length;
    for (var i = analyzerIdx + 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isNotEmpty && !line.startsWith(' ') && !line.startsWith('\t')) {
        blockEnd = i;
        break;
      }
    }

    var excludeIdx = -1;
    for (var i = analyzerIdx + 1; i < blockEnd; i++) {
      if (RegExp(r'^\s+exclude:').hasMatch(lines[i])) {
        excludeIdx = i;
        break;
      }
    }

    if (excludeIdx != -1) {
      // Match the indentation of existing list items under `exclude:`.
      var itemIndent = '    ';
      if (excludeIdx + 1 < blockEnd) {
        final m = RegExp(r'^(\s*)-').firstMatch(lines[excludeIdx + 1]);
        if (m != null) itemIndent = m.group(1)!;
      }
      lines.insert(excludeIdx + 1, '$itemIndent- build/**');
    } else {
      lines.insert(analyzerIdx + 1, '  exclude:\n    - build/**');
    }

    await file.writeAsString(lines.join('\n'));
    stdout.writeln('Updated analysis_options.yaml (excluded build/).');
  }

  /// Reads the `name:` field from the project's pubspec without a YAML
  /// dependency inside the generated-code layer.
  String _readProjectName(String projectPath) {
    final pubspec = File(path.join(projectPath, 'pubspec.yaml'));
    if (pubspec.existsSync()) {
      for (final line in pubspec.readAsLinesSync()) {
        final match = RegExp(r'^name:\s*(\S+)').firstMatch(line.trim());
        if (match != null) return match.group(1)!;
      }
    }
    return 'app';
  }
}
