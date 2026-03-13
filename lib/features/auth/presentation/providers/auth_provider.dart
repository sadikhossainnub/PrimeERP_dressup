import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final _storage = const FlutterSecureStorage();

  @override
  AuthState build() {
    _checkAuthStatus();
    return AuthState();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _storage.read(key: AppConstants.keyIsLoggedIn) == 'true';
    if (isLoggedIn) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      
      final response = await dio.post(
        ApiConstants.login,
        data: {
          'usr': username,
          'pwd': password,
        },
      );

      if (response.statusCode == 200 && response.data['message'] == 'Logged In') {
        await _storage.write(key: AppConstants.keyIsLoggedIn, value: 'true');
        await _storage.write(key: AppConstants.keyUsername, value: username);
        
        state = state.copyWith(isLoading: false, isAuthenticated: true);
      } else {
        final String errorMsg = response.data['message']?.toString() ?? 'Unknown error';
        state = state.copyWith(
          isLoading: false, 
          error: 'Login failed: $errorMsg'
        );
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (e is DioException) {
        errorMsg = e.response?.data?['message']?.toString() ?? e.message ?? errorMsg;
      }
      state = state.copyWith(isLoading: false, error: errorMsg);
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = AuthState();
  }

  Future<void> saveConfig({
    required String baseUrl,
    required String apiKey,
    required String apiSecret,
  }) async {
    await _storage.write(key: AppConstants.keyBaseUrl, value: baseUrl);
    await _storage.write(key: AppConstants.keyApiKey, value: apiKey);
    await _storage.write(key: AppConstants.keyApiSecret, value: apiSecret);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
