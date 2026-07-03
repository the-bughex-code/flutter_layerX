import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Installs the runtime dependencies that LayerX-generated code relies on.
///
/// The generated `lib/app/` tree imports a fixed set of packages (GetX,
/// ScreenUtil, http, logger, …). Historically this class only *appended* those
/// packages to `pubspec.yaml` as text and never resolved them, so a freshly
/// enabled project failed to compile until the user ran `flutter pub get`
/// manually — and any package missing from the list produced
/// "Target of URI doesn't exist" errors forever.
///
/// This implementation instead delegates to `flutter pub add`, which pins the
/// curated constraints below *and* resolves them in one step. If the Flutter
/// SDK cannot be invoked (e.g. it is not on `PATH`), it degrades gracefully by
/// writing the constraints into `pubspec.yaml` and asking the user to run
/// `flutter pub get`.
class DependencyInstaller {
  const DependencyInstaller._();

  /// Every package the generated code imports, pinned to the latest stable
  /// major whose public API the generated templates are written against.
  ///
  /// Caret ranges give users the latest compatible patch/minor while keeping
  /// the generated code API-stable and reproducible.
  static const Map<String, String> layerXDeps = {
    'get': '^4.7.3',
    'flutter_screenutil': '^5.9.3',
    'flutter_animate': '^4.5.0',
    'http': '^1.6.0',
    'shared_preferences': '^2.5.4',
    'logger': '^2.6.2',
    'google_fonts': '^6.3.3',
    'intl': '^0.20.2',
    'timezone': '^0.10.0',
    'flutter_local_notifications': '^19.5.0',
    'permission_handler': '^12.0.1',
    'flutter_timezone': '^5.0.1',
    'firebase_messaging': '^16.0.0',
    'geolocator': '^14.0.0',
    'googleapis_auth': '^2.0.0',
  };

  /// Ensures every [layerXDeps] entry is present in the project and resolved.
  static Future<void> install(String projectPath) async {
    final pubspec = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      throw Exception('pubspec.yaml not found at ${pubspec.path}');
    }

    final existing = _existingDependencies(pubspec);
    final missing = layerXDeps.entries
        .where((e) => !existing.contains(e.key))
        .toList();

    if (missing.isEmpty) {
      stdout.writeln('✅ All LayerX dependencies already present.');
      // Still make sure they are resolved on disk.
      final getExit = await _runFlutter(projectPath, const ['pub', 'get']);
      if (getExit == null) {
        stdout.writeln(
          '⚠️  Flutter not found on PATH — run `flutter pub get` to resolve '
          'dependencies.',
        );
      }
      return;
    }

    final addExit = await _runFlutter(projectPath, [
      'pub',
      'add',
      ...missing.map((e) => '${e.key}:${e.value}'),
    ]);

    if (addExit == 0) {
      stdout.writeln(
        '✅ Installed ${missing.length} LayerX '
        'dependenc${missing.length == 1 ? 'y' : 'ies'} via `flutter pub add`.',
      );
      return;
    }

    if (addExit == null) {
      // Flutter SDK could not be launched at all — write the constraints so the
      // generated code compiles once the user resolves them manually.
      _appendToPubspec(pubspec, missing);
      stdout.writeln(
        '⚠️  Flutter not found on PATH. Wrote ${missing.length} missing '
        'dependencies to pubspec.yaml — run `flutter pub get` to finish setup.',
      );
      return;
    }

    // Flutter ran but resolution failed. `flutter pub add` leaves pubspec.yaml
    // unchanged on failure, so surface the real resolver error rather than
    // writing constraints that already failed to resolve.
    throw Exception(
      '`flutter pub add` failed (exit code $addExit). See the resolver output '
      'above; pubspec.yaml was left unchanged.',
    );
  }

  /// Collects the keys already declared under `dependencies:`.
  static Set<String> _existingDependencies(File pubspec) {
    final result = <String>{};
    final doc = loadYaml(pubspec.readAsStringSync());
    if (doc is YamlMap && doc['dependencies'] is YamlMap) {
      for (final key in (doc['dependencies'] as YamlMap).keys) {
        result.add(key.toString());
      }
    }
    return result;
  }

  /// Runs `flutter <args>` in [projectPath]. Returns the process exit code, or
  /// `null` if the Flutter executable could not be launched at all — which lets
  /// callers distinguish "Flutter missing" from "Flutter ran but failed".
  static Future<int?> _runFlutter(String projectPath, List<String> args) async {
    final executable = Platform.isWindows ? 'flutter.bat' : 'flutter';
    try {
      final result = await Process.run(
        executable,
        args,
        workingDirectory: projectPath,
        runInShell: Platform.isWindows,
      );
      if (result.exitCode != 0) {
        final err = (result.stderr ?? '').toString().trim();
        if (err.isNotEmpty) stderr.writeln(err);
      }
      return result.exitCode;
    } on ProcessException {
      return null;
    }
  }

  /// Minimal, correct fallback that inserts the missing entries directly under
  /// the `dependencies:` key without touching anything else.
  static void _appendToPubspec(
    File pubspec,
    List<MapEntry<String, String>> missing,
  ) {
    final lines = pubspec.readAsLinesSync();
    final output = <String>[];
    var inserted = false;
    // Match a top-level `dependencies:` key, tolerating a trailing inline
    // comment (`dependencies: # ...`) so we never fail to find the block and
    // append a second, duplicate `dependencies:` mapping (invalid YAML).
    final depsKey = RegExp(r'^dependencies:\s*(#.*)?$');

    for (var i = 0; i < lines.length; i++) {
      output.add(lines[i]);
      if (!inserted && depsKey.hasMatch(lines[i].trim())) {
        output.add('  # LayerX auto-added dependencies');
        for (final entry in missing) {
          output.add('  ${entry.key}: ${entry.value}');
        }
        inserted = true;
      }
    }

    if (!inserted) {
      output
        ..add('dependencies:')
        ..add('  # LayerX auto-added dependencies');
      for (final entry in missing) {
        output.add('  ${entry.key}: ${entry.value}');
      }
    }

    pubspec.writeAsStringSync('${output.join('\n')}\n');
  }
}
