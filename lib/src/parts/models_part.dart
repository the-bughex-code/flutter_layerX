part of 'package:layerx_generator/src/layerx_generator.dart';

extension _ModelsPart on LayerXGenerator {
  Future<void> _createModelFiles(String appDirPath) async {
    final bodyModelDir = Directory(
      path.join(appDirPath, 'mvvm', 'model', 'body_model'),
    );
    final responseModelDir = Directory(
      path.join(appDirPath, 'mvvm', 'model', 'response_model'),
    );
    final apiResponseModelDir = Directory(
      path.join(appDirPath, 'mvvm', 'model', 'api_response_model'),
    );

    await bodyModelDir.create(recursive: true);
    await responseModelDir.create(recursive: true);
    await apiResponseModelDir.create(recursive: true);

    // ---- Request body model -------------------------------------------------
    await File(
      path.join(bodyModelDir.path, 'login_request_model.dart'),
    ).writeAsString(r'''
/// Request body for the login endpoint.
class LoginRequestModel {
  const LoginRequestModel({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
''');

    // ---- Response model -----------------------------------------------------
    await File(
      path.join(responseModelDir.path, 'login_response_model.dart'),
    ).writeAsString(r'''
/// Parsed `data` payload returned by the login endpoint.
class LoginResponseModel {
  const LoginResponseModel({this.token, this.name});

  final String? token;
  final String? name;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        token: json['token'] as String?,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'name': name,
      };
}
''');

    // ---- Generic API envelope (unchanged public behavior) -------------------
    await File(
      path.join(apiResponseModelDir.path, 'api_response.dart'),
    ).writeAsString(r'''
/// Generic API response model for flexible data parsing.
class ApiResponse<T> {
  final bool? success;
  final String? message;
  final int? code;
  final T? data;
  final String? token;

  ApiResponse({
    this.success,
    this.message,
    this.code,
    this.data,
    this.token,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    final status = json['status'];
    final success = json['success'];
    final isSuccess = success == true || status == 'success';

    final skipKeys = {'status', 'success', 'code', 'error', 'message', 'token'};
    dynamic extractedData;

    if (json['data'] != null) {
      extractedData = json['data'];
    } else {
      for (final entry in json.entries) {
        if (!skipKeys.contains(entry.key) &&
            (entry.value is Map<String, dynamic> || entry.value is List)) {
          extractedData = entry.value;
          break;
        }
      }
    }

    return ApiResponse(
      success: isSuccess,
      message: json['message'] as String?,
      code: json['code'] as int?,
      data: extractedData != null ? fromJsonT(extractedData) : null,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'success': success,
      'message': message,
      'code': code,
      'data': data != null ? toJsonT(data as T) : null,
      'token': token,
    };
  }
}
''');

    stdout.writeln('Created model files.');
  }
}
