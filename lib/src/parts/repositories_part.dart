part of 'package:layerx_generator/src/layerx_generator.dart';


extension _RepositoriesPart on LayerXGenerator {
  Future<void> _createRepositoryFiles(String appDirPath) async {
    final repoDir = Directory(path.join(appDirPath, 'repository'));
    final apiRepoDir = Directory(path.join(repoDir.path, 'apis'));

    await repoDir.create(recursive: true);
    await apiRepoDir.create(recursive: true);

    // Keep the placeholder data-source folders under version control (empty
    // directories are not tracked by git or included in a published package).
    for (final sub in ['firebase', 'localdb']) {
      final dir = Directory(path.join(repoDir.path, sub));
      await dir.create(recursive: true);
      await File(path.join(dir.path, '.gitkeep')).writeAsString(
        '# Placeholder — add your $sub data sources here.\n',
      );
    }

    // Top-level auth repository (repository/auth_repository.dart).
    await File(
      path.join(repoDir.path, 'auth_repository.dart'),
    ).writeAsString(r'''
import 'dart:convert';

import '../config/app_urls.dart';
import '../mvvm/model/api_response_model/api_response.dart';
import '../mvvm/model/body_model/login_request_model.dart';
import '../mvvm/model/response_model/login_response_model.dart';
import '../services/https_calls.dart';

/// Repository for authentication-related API calls.
///
/// Repositories are the only layer that talks to [HttpsCalls]; controllers
/// depend on repositories, never on the network client directly. [HttpsCalls]
/// is injected so it can be swapped for a fake in tests.
class AuthRepository {
  AuthRepository({HttpsCalls? httpsCalls})
      : _httpsCalls = httpsCalls ?? HttpsCalls();

  final HttpsCalls _httpsCalls;

  /// Demo login — accepts any credentials so the sample runs without a
  /// backend. Delete the demo block and uncomment the real call to go live.
  Future<ApiResponse<LoginResponseModel>> login(
    LoginRequestModel request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // Real implementation:
    // final response = await _httpsCalls.postApiHits(
    //   AppUrls.login, utf8.encode(jsonEncode(request.toJson())));
    // return ApiResponseHandler.process(response, AppUrls.login,
    //     (json) => LoginResponseModel.fromJson(json as Map<String, dynamic>));

    return ApiResponse<LoginResponseModel>(
      success: true,
      message: 'Login successful',
      data: LoginResponseModel(
        token: 'demo-token',
        name: request.email.contains('@')
            ? request.email.split('@').first
            : request.email,
      ),
    );
  }

  /// Invalidates the current session on the backend.
  Future<ApiResponse<void>> logout() async {
    final response =
        await _httpsCalls.postApiHits(AppUrls.logout, utf8.encode('{}'));
    return ApiResponse<void>(success: response.statusCode == 200);
  }
}
''');

    // API repositories live under repository/apis/.
    await File(
      path.join(apiRepoDir.path, 'data_repository.dart'),
    ).writeAsString(r'''
import '../../mvvm/model/api_response_model/api_response.dart';
import '../../services/https_calls.dart';

/// Repository for general data/API calls.
class DataRepository {
  DataRepository({HttpsCalls? httpsCalls})
      : _httpsCalls = httpsCalls ?? HttpsCalls();

  final HttpsCalls _httpsCalls;

  /// Sample endpoint — replace with your real data calls.
  Future<ApiResponse<void>> fetchExample() async {
    final response = await _httpsCalls.getApiHits('example');
    return ApiResponse<void>(success: response.statusCode == 200);
  }
}
''');

    stdout.writeln('Created repository files.');
  }
}
