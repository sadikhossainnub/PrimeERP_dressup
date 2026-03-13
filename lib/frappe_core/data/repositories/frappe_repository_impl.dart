import '../datasources/frappe_remote_ds.dart';
import '../../domain/repositories/frappe_repository.dart';
import '../models/doctype_meta_model.dart';
import '../models/workflow_model.dart';
import '../models/comment_model.dart';
import '../models/attachment_model.dart';

class FrappeRepositoryImpl implements FrappeRepository {
  final FrappeRemoteDataSource _remoteDataSource;

  FrappeRepositoryImpl(this._remoteDataSource);

  @override
  Future<DocTypeMetaModel> getDocTypeMeta(String doctype) async {
    final data = await _remoteDataSource.getDocTypeMeta(doctype);
    return DocTypeMetaModel.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> getDoc(
    String doctype,
    String name, {
    bool expandLinks = false,
  }) {
    return _remoteDataSource.getDoc(doctype, name, expandLinks: expandLinks);
  }

  @override
  Future<List<Map<String, dynamic>>> getList(
    String doctype, {
    List<String>? fields,
    List<dynamic>? filters,
    List<dynamic>? orFilters,
    int limitPageLength = 20,
    int limitStart = 0,
    String? orderBy,
    List<String>? expand,
  }) {
    return _remoteDataSource.getList(
      doctype,
      fields: fields,
      filters: filters,
      orFilters: orFilters,
      limitPageLength: limitPageLength,
      limitStart: limitStart,
      orderBy: orderBy,
      expand: expand,
    );
  }

  @override
  Future<Map<String, dynamic>> saveDoc(Map<String, dynamic> doc) {
    return _remoteDataSource.saveDoc(doc);
  }

  @override
  Future<void> deleteDoc(String doctype, String name) {
    return _remoteDataSource.deleteDoc(doctype, name);
  }

  @override
  Future<List<WorkflowTransitionModel>> getWorkflowTransitions(Map<String, dynamic> doc) async {
    final data = await _remoteDataSource.getWorkflowTransitions(doc);
    return data.map((json) => WorkflowTransitionModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> applyWorkflowAction(
    String doctype,
    String name,
    String action,
  ) {
    return _remoteDataSource.applyWorkflowAction(doctype, name, action);
  }

  @override
  Future<List<CommentModel>> getComments(String doctype, String name) async {
    final data = await _remoteDataSource.getComments(doctype, name);
    return data.map((json) => CommentModel.fromJson(json)).toList();
  }

  @override
  Future<void> addComment(String doctype, String name, String content) {
    return _remoteDataSource.addComment(doctype, name, content);
  }

  @override
  Future<List<AttachmentModel>> getAttachments(String doctype, String name) async {
    final data = await _remoteDataSource.getAttachments(doctype, name);
    return data.map((json) => AttachmentModel.fromJson(json)).toList();
  }

  @override
  Future<dynamic> callMethod(
    String methodPath, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool usePost = false,
  }) {
    return _remoteDataSource.callMethod(
      methodPath,
      data: data,
      queryParameters: queryParameters,
      usePost: usePost,
    );
  }

  @override
  Future<int> getCount(String doctype, {List<dynamic>? filters}) {
    return _remoteDataSource.getCount(doctype, filters: filters);
  }
}
