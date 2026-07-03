part of 'package:layerx_generator/src/layerx_generator.dart';

extension _NativeConfigPart on LayerXGenerator {
  /// Patches native config so the generated notification & location features
  /// work end-to-end. Idempotent and non-fatal — if a platform folder is
  /// absent (e.g. a package-only project) it is silently skipped.
  Future<void> _patchNativeConfig(String projectPath) async {
    await _patchAndroidManifest(projectPath);
    await _patchIosInfoPlist(projectPath);
  }

  /// Only the permissions the generated code actually relies on — each is
  /// justified inline so users can prune any feature they don't use.
  static const Map<String, String> _androidPermissions = {
    'android.permission.INTERNET': 'Networking (HttpsCalls)',
    'android.permission.POST_NOTIFICATIONS': 'Notifications (Android 13+)',
    'android.permission.VIBRATE': 'Haptics & notification vibration',
    'android.permission.WAKE_LOCK': 'Reliable notification delivery',
    'android.permission.RECEIVE_BOOT_COMPLETED':
        'Reschedule notifications after reboot',
    'android.permission.SCHEDULE_EXACT_ALARM':
        'Exact scheduled notifications (Android 12+)',
    'android.permission.ACCESS_FINE_LOCATION':
        'Precise location (LocationService)',
    'android.permission.ACCESS_COARSE_LOCATION':
        'Approximate location (LocationService)',
  };

  Future<void> _patchAndroidManifest(String projectPath) async {
    final file = File(
      path.join(
        projectPath,
        'android',
        'app',
        'src',
        'main',
        'AndroidManifest.xml',
      ),
    );
    if (!file.existsSync()) return;

    final content = file.readAsStringSync();
    final appIndex = content.indexOf('<application');
    if (appIndex == -1) return;

    final missing = _androidPermissions.entries
        .where((e) => !content.contains(e.key))
        .toList();
    if (missing.isEmpty) return;

    final block = StringBuffer(
      "    <!-- LayerX permissions — remove any feature you don't use -->\n",
    );
    for (final entry in missing) {
      block.writeln(
        '    <uses-permission android:name="${entry.key}"/> '
        '<!-- ${entry.value} -->',
      );
    }

    // Insert the block on its own lines, just before <application …>.
    final lineStart = content.lastIndexOf('\n', appIndex) + 1;
    final patched =
        content.substring(0, lineStart) +
        block.toString() +
        content.substring(lineStart);
    file.writeAsStringSync(patched);

    stdout.writeln(
      'Patched AndroidManifest.xml (+${missing.length} permissions).',
    );
  }

  Future<void> _patchIosInfoPlist(String projectPath) async {
    final file = File(path.join(projectPath, 'ios', 'Runner', 'Info.plist'));
    if (!file.existsSync()) return;

    final content = file.readAsStringSync();
    final closeIndex = content.lastIndexOf('</dict>');
    if (closeIndex == -1) return;

    final additions = StringBuffer();

    if (!content.contains('<key>NSLocationWhenInUseUsageDescription</key>')) {
      additions
        ..writeln('\t<key>NSLocationWhenInUseUsageDescription</key>')
        ..writeln(
          '\t<string>This app uses your location to provide '
          'location-based features.</string>',
        );
    }

    if (!content.contains('<key>UIBackgroundModes</key>')) {
      additions
        ..writeln('\t<key>UIBackgroundModes</key>')
        ..writeln('\t<array>')
        ..writeln('\t\t<string>remote-notification</string>')
        ..writeln('\t</array>');
    }

    if (additions.isEmpty) return;

    final patched =
        content.substring(0, closeIndex) +
        additions.toString() +
        content.substring(closeIndex);
    file.writeAsStringSync(patched);

    stdout.writeln('Patched ios/Runner/Info.plist.');
  }
}
