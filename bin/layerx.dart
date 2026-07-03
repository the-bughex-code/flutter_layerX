import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:layerx_generator/layerx_generator.dart';

/// Entry point for the `layerx` executable.
///
/// After `dart pub global activate layerx_generator`, users run:
///
///   layerx enable            # in the project root
///   layerx enable --path .   # or an explicit path
///
/// The legacy `dart run layerx_generator --path .` entry point is still
/// supported for backward compatibility (see `bin/layerx_generator.dart`).
Future<void> main(List<String> arguments) async {
  final runner = CommandRunner<void>(
    'layerx',
    'Bootstrap the LayerX architecture.',
  )..addCommand(EnableCommand());

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exit(64);
  } catch (e) {
    stderr.writeln('❌ $e');
    exit(1);
  }
}

/// `layerx enable` — installs dependencies and generates the LayerX structure.
class EnableCommand extends Command<void> {
  EnableCommand() {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the Flutter project directory.',
        defaultsTo: '.',
      )
      ..addFlag(
        'no-deps',
        negatable: false,
        help: 'Generate files without installing dependencies.',
      );
  }

  @override
  String get name => 'enable';

  @override
  String get description =>
      'Install LayerX dependencies and generate the app structure.';

  @override
  Future<void> run() async {
    final results = argResults!;
    final projectPath = results['path'] as String;
    final installDeps = !(results['no-deps'] as bool);

    stdout.writeln('🚀 Enabling LayerX in: $projectPath');
    final generator = LayerXGenerator(projectPath, installDeps: installDeps);
    await generator.generate();
    stdout.writeln('🎉 LayerX is ready. Run your app with `flutter run`.');
  }
}
