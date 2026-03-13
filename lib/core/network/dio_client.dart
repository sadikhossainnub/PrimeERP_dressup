import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(ref.read(authInterceptorProvider));
  
  // Add logging in debug mode
  // if (kDebugMode) {
  //   dio.interceptors.add(LogInterceptor(
  //     requestHeader: true,
  //     requestBody: true,
  //     responseHeader: true,
  //     responseBody: true,
  //   ));
  // }

  return dio;
});
