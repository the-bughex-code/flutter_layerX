part of 'package:layerx_generator/src/layerx_generator.dart';

extension _ServicesPart on LayerXGenerator {
  Future<void> _createServiceFiles(String appDirPath) async {
    final servicesDir = Directory(path.join(appDirPath, 'services'));

    await File(
      path.join(servicesDir.path, 'haptic_service.dart'),
    ).writeAsString('''
import 'package:flutter/services.dart';

/// Centralized haptic feedback.
///
/// Call these instead of [HapticFeedback] directly so intensity stays
/// consistent across the app. [success] and [error] are short multi-tap
/// patterns rather than single impacts.
class HapticService {
  const HapticService._();

  static Future<void> light() => HapticFeedback.lightImpact();

  static Future<void> medium() => HapticFeedback.mediumImpact();

  static Future<void> heavy() => HapticFeedback.heavyImpact();

  static Future<void> selection() => HapticFeedback.selectionClick();

  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.lightImpact();
  }

  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 110));
    await HapticFeedback.heavyImpact();
  }
}
''');

    await File(
      path.join(servicesDir.path, 'logger_service.dart'),
    ).writeAsString(r'''
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A developer-friendly logging console for the LayerX app.
///
/// Wraps the `logger` package with a colorful, emoji-tagged printer and adds
/// helpers for HTTP request/response logs, pretty JSON, section dividers and
/// execution timing. All output is gated behind [kDebugMode], so nothing is
/// printed in release builds.
class LoggerService {
  LoggerService._();

  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  static final Logger _logger = Logger(
    filter: ProductionFilter(),
    level: kDebugMode ? Level.trace : Level.warning,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 6,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      levelEmojis: {
        Level.trace: '🔍',
        Level.debug: '🐛',
        Level.info: '💡',
        Level.warning: '⚠️',
        Level.error: '❌',
        Level.fatal: '💀',
      },
    ),
  );

  // ---- Core levels (backward compatible) --------------------------------

  static void d(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // ---- Developer console helpers ----------------------------------------

  /// A success line.
  static void s(dynamic message) {
    if (kDebugMode) _logger.i('✅ $message');
  }

  /// A labelled section divider.
  static void divider([String title = '']) {
    if (!kDebugMode) return;
    _logger.i(title.isEmpty
        ? '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
        : '━━━━━ $title ━━━━━');
  }

  /// A boot banner — call once from `main()` to announce the app in the console.
  static void banner({String name = 'LayerX', String? version, String? env}) {
    if (!kDebugMode) return;
    final tags = <String>[
      if (version != null) 'v$version',
      if (env != null) env.toUpperCase(),
    ];
    final subtitle = tags.isEmpty ? '' : '  •  ${tags.join('  •  ')}';
    _logger.i(
      '🚀  $name$subtitle\n'
      '✨  Clean architecture · GetX · zero boilerplate\n'
      '🟢  Console ready — happy shipping!',
    );
  }

  /// A warning line with a lightbulb — great for actionable hints.
  static void hint(dynamic message) {
    if (kDebugMode) _logger.w('💡 $message');
  }

  /// Pretty-prints any JSON-encodable value.
  static void json(Object? data, {String label = 'JSON'}) {
    if (kDebugMode) _logger.i('🧾 $label\n${_safeJson(data)}');
  }

  /// Logs an outgoing HTTP request.
  static void request(String method, String url, {Object? body}) {
    if (!kDebugMode) return;
    final buffer = StringBuffer('🚀 → $method  $url');
    if (body != null) buffer.write('\n📦 Body: ${_safeJson(body)}');
    _logger.d(buffer.toString());
  }

  /// Logs an incoming HTTP response.
  static void response(
    int statusCode,
    String url, {
    Object? body,
    Duration? elapsed,
  }) {
    if (!kDebugMode) return;
    final ok = statusCode >= 200 && statusCode < 300;
    final time = elapsed == null ? '' : ' • ${elapsed.inMilliseconds}ms';
    final buffer = StringBuffer('${ok ? '✅' : '❌'} ← $statusCode  $url$time');
    if (body != null) buffer.write('\n📦 ${_safeJson(body)}');
    ok ? _logger.i(buffer.toString()) : _logger.e(buffer.toString());
  }

  /// Runs [action], logging how long it took (and any failure).
  static Future<T> timed<T>(String label, Future<T> Function() action) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      stopwatch.stop();
      if (kDebugMode) {
        _logger.i('⏱️ $label took ${stopwatch.elapsedMilliseconds}ms');
      }
      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      if (kDebugMode) {
        _logger.e('⏱️ $label failed after ${stopwatch.elapsedMilliseconds}ms',
            error: error, stackTrace: stackTrace);
      }
      rethrow;
    }
  }

  static String _safeJson(Object? data) {
    try {
      return _encoder.convert(data);
    } catch (_) {
      return '$data';
    }
  }
}
''');

    await File(
      path.join(servicesDir.path, 'shared_preferences_service.dart'),
    ).writeAsString('''
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

class SharedPreferencesService {
  static const String _keyUserData = 'user_data';
  static const String _deviceToken = 'deviceToken';
  static const String _apiToken = 'apiToken';

  Future<void> saveDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceToken, token);
    LoggerService.i('Saved device token');
  }

  Future<String?> readDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceToken);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiToken, token);
    LoggerService.i('Saved API token');
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiToken);
  }

  Future<void> saveUserData(dynamic userData) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(userData.toJson());
    await prefs.setString(_keyUserData, data);
    LoggerService.i('Saved user data');
  }

  Future<dynamic> readUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUserData);
    if (data == null) return null;
    return json.decode(data);
  }

  Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
''');

    await File(
      path.join(servicesDir.path, 'global_variables.dart'),
    ).writeAsString('''
import '../config/app_enums.dart';

/// Global variables for the LayerX app.
class GlobalVariables {
  static List<String> errorMessages = ['Failed, Try Again'];
  static String route = '';
  static UserRole userRole = UserRole.user;
}
''');

    await File(
      path.join(servicesDir.path, 'json_extractor.dart'),
    ).writeAsString('''
import 'dart:convert';
import 'package:logger/logger.dart';
import 'global_variables.dart';

class MessageExtractor {
  final Logger _logger = Logger();

  void extractAndStoreMessage(String endPoint, String responseBody) {
    GlobalVariables.errorMessages.clear();

    try {
      _logger.i("💡 API EndPoint: \$endPoint - Raw Response: \$responseBody");

      final dynamic decoded = jsonDecode(responseBody);

      if (decoded is! Map<String, dynamic>) {
        GlobalVariables.errorMessages.add("Unexpected server response format.");
        return;
      }

      final jsonMap = decoded;

      if (jsonMap['errors'] is Map<String, dynamic>) {
        final errorsMap = jsonMap['errors'] as Map<String, dynamic>;
        for (final entry in errorsMap.entries) {
          final value = entry.value;
          if (value is List) {
            for (final msg in value) {
              if (msg != null && msg.toString().trim().isNotEmpty) {
                GlobalVariables.errorMessages.add(msg.toString().trim());
              }
            }
          } else if (value is String && value.trim().isNotEmpty) {
            GlobalVariables.errorMessages.add(value.trim());
          }
        }
      } else if (jsonMap['errors'] is List) {
        final errorsList = jsonMap['errors'] as List;
        for (final error in errorsList) {
          if (error != null && error.toString().trim().isNotEmpty) {
            GlobalVariables.errorMessages.add(error.toString().trim());
          }
        }
      } else if (jsonMap['data'] is List) {
        final dataList = jsonMap['data'] as List;
        for (final error in dataList) {
          if (error != null && error.toString().trim().isNotEmpty) {
            GlobalVariables.errorMessages.add(error.toString().trim());
          }
        }
      }

      if (GlobalVariables.errorMessages.isEmpty &&
          jsonMap['message'] != null &&
          jsonMap['message'].toString().trim().isNotEmpty) {
        GlobalVariables.errorMessages.add(jsonMap['message'].toString().trim());
      }

      if (GlobalVariables.errorMessages.isEmpty) {
        GlobalVariables.errorMessages.add("Something went wrong.");
      }
    } catch (e, st) {
      _logger.e("❌ Error extracting message: \$e", error: e, stackTrace: st);
      GlobalVariables.errorMessages.add("Connection issue. Please retry.");
    }

    _logger.i("✅ Extracted Errors: \${GlobalVariables.errorMessages}");
  }
}
''');

    await File(
      path.join(servicesDir.path, 'location_service.dart'),
    ).writeAsString('''
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'logger_service.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      LoggerService.w('Location services are disabled');
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
      throw Exception('Location permission denied forever.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
''');

    await File(
      path.join(servicesDir.path, 'api_response_handler.dart'),
    ).writeAsString('''
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../custom_widgets/dialogs/no_internet_dialog.dart';
import '../mvvm/model/api_response_model/api_response.dart';
import 'json_extractor.dart';
import 'logger_service.dart';

/// Handles API responses with standardized processing.
class ApiResponseHandler {
  static Future<ApiResponse<T>> process<T>(
    dynamic response,
    String? endPoint,
    T Function(dynamic dataJson) fromJson,
  ) async {
    MessageExtractor().extractAndStoreMessage(endPoint ?? '', response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        final parsedJson = response.body.length > 100000
            ? await compute<String, dynamic>(_parseJson, response.body)
            : jsonDecode(response.body);
        LoggerService.i('✅ API response processed: \$endPoint');
        return ApiResponse<T>.fromJson(parsedJson, fromJson);

      case 401:
        _handleUnauthorized(endPoint);
        break;

      case 422:
        return _handleError<T>(response, 'Validation Error');

      case 500:
        return _handleError<T>(response, 'Internal Server Error');

      case 503:
        return _handleNoInternet<T>();

      default:
        return _handleError<T>(
          response,
          'API Error: \${response.statusCode} - \${response.reasonPhrase}',
        );
    }

    return ApiResponse<T>(message: 'Unexpected error occurred');
  }

  static dynamic _parseJson(String responseBody) {
    return jsonDecode(responseBody);
  }

  static void _handleUnauthorized(String? endPoint) {
    LoggerService.w('⛔ Unauthorized. Checking endpoint...');

    if ((endPoint ?? '').toLowerCase().contains('login') ||
        (endPoint ?? '').toLowerCase().contains('delete-account')) {
      LoggerService.w('🔁 401 on login endpoint. Skipping redirect.');
      return;
    }

    LoggerService.w('⛔ Unauthorized. Redirecting to login.');
    // Get.offAllNamed(AppRoutes.loginView);
    throw Exception('Unauthorized access. Please log in.');
  }

  static ApiResponse<T> _handleNoInternet<T>() {
    LoggerService.w('📴 No internet detected (503)');
    if (!(Get.isDialogOpen ?? false)) {
      Future.delayed(Duration.zero, () {
        NoInternetDialog.show(
          title: 'Network Error',
          message:
              'Unable to connect to the server. Please check your internet '
              'connection and try again.',
          closeText: 'Dismiss',
          onClose: () {},
        );
      });
    }
    return ApiResponse<T>(
      success: false,
      message: 'No internet connection. Please try again.',
    );
  }

  static ApiResponse<T> _handleError<T>(dynamic response, String errorMessage) {
    try {
      final errorResponse = jsonDecode(response.body);
      final message =
          errorResponse['message'] ?? 'Something went wrong. Please try again.';
      return ApiResponse<T>(message: message);
    } catch (e, stack) {
      LoggerService.e('❌ Error parsing error response',
          error: e, stackTrace: stack);
      return ApiResponse<T>(message: errorMessage);
    }
  }

  static void logUnhandledError(dynamic e, StackTrace stackTrace) {
    LoggerService.e('⚠️ Unhandled error', error: e, stackTrace: stackTrace);
  }
}
''');

    await File(
      path.join(servicesDir.path, 'https_calls.dart'),
    ).writeAsString(_httpsCallsContent());

    stdout.writeln('Created service files.');
  }
}
