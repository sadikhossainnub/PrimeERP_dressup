import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';

class FrappeRemoteDataSource {
  final Dio _dio;

  FrappeRemoteDataSource(this._dio);

  // ─── DocType CRUD ───

  Future<Map<String, dynamic>> getDoc(
    String doctype,
    String name, {
    bool expandLinks = false,
  }) async {
    try {
      final queryParameters = {
        if (expandLinks) 'expand_links': 'True',
      };
      final response = await _dio.get(
        ApiConstants.resourceDoc(doctype, name),
        queryParameters: queryParameters,
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getList(
    String doctype, {
    List<String>? fields,
    List<dynamic>? filters,
    List<dynamic>? orFilters,
    int limitPageLength = 20,
    int limitStart = 0,
    String? orderBy,
    List<String>? expand,
    bool asDict = true,
  }) async {
    try {
      final queryParameters = {
        'fields': fields != null ? jsonEncode(fields) : null,
        'filters': filters != null ? jsonEncode(filters) : null,
        'or_filters': orFilters != null ? jsonEncode(orFilters) : null,
        'expand': expand != null ? jsonEncode(expand) : null,
        'limit_page_length': limitPageLength,
        'limit_start': limitStart,
        'order_by': orderBy,
        'as_dict': asDict ? 'True' : 'False',
      }..removeWhere((key, value) => value == null);

      final response = await _dio.get(
        ApiConstants.resource(doctype),
        queryParameters: queryParameters,
      );
      
      if (asDict) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        // Handle List<List> if needed, but return as List<Map> with dummy keys or actual values
        throw UnimplementedError('asDict=False is not fully supported in result mapping yet');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> saveDoc(Map<String, dynamic> doc) async {
    try {
      final String doctype = doc['doctype'];
      final String? name = doc['name'];

      Response response;
      if (name != null) {
        response = await _dio.put(
          ApiConstants.resourceDoc(doctype, name),
          data: doc,
        );
      } else {
        response = await _dio.post(
          ApiConstants.resource(doctype),
          data: doc,
        );
      }
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteDoc(String doctype, String name) async {
    try {
      await _dio.delete(ApiConstants.resourceDoc(doctype, name));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── DocType Metadata ───

  Future<Map<String, dynamic>> getDocTypeMeta(String doctype) async {
    try {
      final response = await _dio.get(ApiConstants.doctypeSchema(doctype));
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── Workflow ───

  Future<List<Map<String, dynamic>>> getWorkflowTransitions(
    Map<String, dynamic> doc,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.getTransitions,
        data: {'doc': doc},
      );
      return List<Map<String, dynamic>>.from(response.data['message'] ?? []);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> applyWorkflowAction(
    String doctype,
    String name,
    String action,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.applyWorkflow,
        data: {
          'doctype': doctype,
          'docname': name,
          'action': action,
        },
      );
      return response.data['doc'];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── Comments ───

  Future<void> addComment(
    String doctype,
    String name,
    String content,
  ) async {
    try {
      await _dio.post(
        ApiConstants.comments,
        data: {
          'reference_doctype': doctype,
          'reference_name': name,
          'content': content,
          'comment_type': 'Comment',
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── Generic Method Calls ───

  Future<dynamic> callMethod(
    String methodPath, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool usePost = false,
  }) async {
    try {
      Response response;
      if (usePost) {
        response = await _dio.post(
          ApiConstants.method(methodPath),
          data: data,
        );
      } else {
        response = await _dio.get(
          ApiConstants.method(methodPath),
          queryParameters: queryParameters,
        );
      }
      return response.data['message'];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<int> getCount(String doctype, {List<dynamic>? filters}) async {
    try {
      final response = await _dio.get(
        ApiConstants.getCount,
        queryParameters: {
          'doctype': doctype,
          if (filters != null) 'filters': jsonEncode(filters),
        },
      );
      return response.data['message'] as int;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getComments(
    String doctype,
    String name,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.comments,
        queryParameters: {
          'filters': jsonEncode([
            ['reference_doctype', '=', doctype],
            ['reference_name', '=', name],
          ]),
          'fields': jsonEncode(['*']),
          'order_by': 'creation desc',
        },
      );
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── Attachments ───

  Future<List<Map<String, dynamic>>> getAttachments(
    String doctype,
    String name,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.files,
        queryParameters: {
          'filters': jsonEncode([
            ['attached_to_doctype', '=', doctype],
            ['attached_to_name', '=', name],
          ]),
          'fields': jsonEncode(['*']),
        },
      );
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> uploadFile({
    required File file,
    required String doctype,
    required String name,
    bool isPrivate = true,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'doctype': doctype,
        'docname': name,
        'is_private': isPrivate ? 1 : 0,
      });

      final response = await _dio.post(ApiConstants.uploadFile, data: formData);
      return response.data['message'];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── Helper for Error Handling ───

  Exception _handleDioError(DioException e) {
    final response = e.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final data = response.data;

      String message = 'Server error occurred';
      if (data is Map && data.containsKey('_server_messages')) {
        try {
          final messages = jsonDecode(data['_server_messages'] as String);
          if (messages is List && messages.isNotEmpty) {
            message = jsonDecode(messages[0])['message'] ?? message;
          }
        } catch (_) {}
      } else if (data is Map && data.containsKey('message')) {
        message = data['message'].toString();
      }

      if (statusCode == 401) return UnauthorizedException(message);
      if (statusCode == 403) return ForbiddenException(message);
      
      return ServerException(
        message: message,
        statusCode: statusCode,
        responseData: data is Map<String, dynamic> ? data : null,
      );
    }
    
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException('Connection timed out');
    }

    return NetworkException('Network error occurred');
  }
}
