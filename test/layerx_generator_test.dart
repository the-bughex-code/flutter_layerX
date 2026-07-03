import 'dart:io';
import 'package:layerx_generator/layerx_generator.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

void main() {
  group('LayerXGenerator', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory('test_temp');
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      await tempDir.create();

      // Setup minimal Flutter project structure
      await Directory(p.join(tempDir.path, 'lib')).create();
      await File(p.join(tempDir.path, 'pubspec.yaml')).writeAsString('''
name: test_project
dependencies:
  flutter:
    sdk: flutter
''');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // `installDeps: false` keeps this a fast, hermetic unit test — it exercises
    // file generation without shelling out to `flutter pub add`.
    test('generates directory structure', () async {
      final generator = LayerXGenerator(tempDir.path, installDeps: false);
      await generator.generate();

      // Check if key directories exist
      expect(Directory('${tempDir.path}/lib/app/config').existsSync(), true);
      expect(
        Directory('${tempDir.path}/lib/app/mvvm/model').existsSync(),
        true,
      );
      expect(
        Directory('${tempDir.path}/lib/app/repository').existsSync(),
        true,
      );
      expect(Directory('${tempDir.path}/lib/app/services').existsSync(), true);
      expect(
        Directory('${tempDir.path}/lib/app/custom_widgets').existsSync(),
        true,
      );

      // Check if placeholder files exist
      expect(
        File('${tempDir.path}/lib/app/config/app_colors.dart').existsSync(),
        true,
      );
      expect(
        File(
          '${tempDir.path}/lib/app/mvvm/model/api_response_model/api_response.dart',
        ).existsSync(),
        true,
      );
    });

    test('does not generate the removed AppTheme', () async {
      final generator = LayerXGenerator(tempDir.path, installDeps: false);
      await generator.generate();

      expect(
        File('${tempDir.path}/lib/app/config/app_theme.dart').existsSync(),
        false,
      );
    });

    test('generates the NoInternetDialog custom widget', () async {
      final generator = LayerXGenerator(tempDir.path, installDeps: false);
      await generator.generate();

      expect(
        File(
          '${tempDir.path}/lib/app/custom_widgets/dialogs/no_internet_dialog.dart',
        ).existsSync(),
        true,
      );
    });

    test('rewrites widget_test.dart to use the project name', () async {
      final generator = LayerXGenerator(tempDir.path, installDeps: false);
      await generator.generate();

      final widgetTest =
          File('${tempDir.path}/test/widget_test.dart').readAsStringSync();
      expect(widgetTest.contains('package:test_project/app/app_widget.dart'),
          true);
      expect(widgetTest.contains('MyApp'), false);
    });

    test('excludes build/ from analysis', () async {
      final generator = LayerXGenerator(tempDir.path, installDeps: false);
      await generator.generate();

      final options =
          File('${tempDir.path}/analysis_options.yaml').readAsStringSync();
      expect(options.contains('build/**'), true);
    });

    test('merges build/ exclude into an existing analyzer block', () async {
      // Simulate an existing project that already configures the analyzer.
      await File('${tempDir.path}/analysis_options.yaml').writeAsString('''
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"

linter:
  rules:
    - prefer_const_constructors
''');

      final generator = LayerXGenerator(tempDir.path, installDeps: false);
      await generator.generate();

      final raw =
          File('${tempDir.path}/analysis_options.yaml').readAsStringSync();
      expect(raw.contains('build/**'), true);

      // The result must remain valid YAML with both excludes intact.
      final doc = loadYaml(raw) as YamlMap;
      final exclude = (doc['analyzer'] as YamlMap)['exclude'] as YamlList;
      expect(exclude.contains('build/**'), true);
      expect(exclude.contains('**/*.g.dart'), true);
      // The pre-existing linter section must survive untouched.
      expect((doc['linter'] as YamlMap)['rules'], isNotNull);
    });
  });
}
