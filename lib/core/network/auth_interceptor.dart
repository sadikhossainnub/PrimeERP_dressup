import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(const FlutterSecureStorage());
});

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final apiKey = await _storage.read(key: AppConstants.keyApiKey);
    final apiSecret = await _storage.read(key: AppConstants.keyApiSecret);
    final baseUrl = await _storage.read(key: AppConstants.keyBaseUrl);

    if (baseUrl != null && baseUrl.isNotEmpty) {
      options.baseUrl = baseUrl;
    }

    if (apiKey != null && apiSecret != null) {
      options.headers['Authorization'] = 'token $apiKey:$apiSecret';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Clear session on 401
      await _storage.delete(key: AppConstants.keyIsLoggedIn);
      // Handle redirect to login via router/state management if needed
    }
    return handler.next(err);
  }
}
