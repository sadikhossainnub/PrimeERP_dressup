import '../../data/models/doctype_meta_model.dart';
import '../../data/models/workflow_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/attachment_model.dart';

abstract class FrappeRepository {
  Future<Map<String, dynamic>> getDoc(
    String doctype,
    String name, {
    bool expandLinks = false,
  });
  Future<List<Map<String, dynamic>>> getList(
    String doctype, {
    List<String>? fields,
    List<dynamic>? filters,
    List<dynamic>? orFilters,
    int limitPageLength = 20,
    int limitStart = 0,
    String? orderBy,
    List<String>? expand,
  });
  Future<Map<String, dynamic>> saveDoc(Map<String, dynamic> doc);
  Future<void> deleteDoc(String doctype, String name);

  Future<DocTypeMetaModel> getDocTypeMeta(String doctype);

  Future<List<WorkflowTransitionModel>> getWorkflowTransitions(
    Map<String, dynamic> doc,
  );
  Future<Map<String, dynamic>> applyWorkflowAction(
    String doctype,
    String name,
    String action,
  );

  Future<List<CommentModel>> getComments(String doctype, String name);
  Future<void> addComment(String doctype, String name, String content);
  Future<List<AttachmentModel>> getAttachments(String doctype, String name);

  Future<dynamic> callMethod(
    String methodPath, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool usePost = false,
  });

  Future<int> getCount(String doctype, {List<dynamic>? filters});
}
