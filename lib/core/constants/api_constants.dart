/// API Constants for ERPNext/Frappe REST API
class ApiConstants {
  ApiConstants._();

  // ─── Auth Endpoints ───
  static const String login = '/api/method/login';
  static const String logout = '/api/method/logout';
  static const String loggedUser = '/api/method/frappe.auth.get_logged_user';

  // ─── Generic DocType CRUD ───
  static String resource(String doctype) => '/api/resource/$doctype';
  static String resourceDoc(String doctype, String name) =>
      '/api/resource/$doctype/$name';

  // ─── DocType Meta ───
  static String doctypeMeta(String doctype) =>
      '/api/method/frappe.client.get_list';
  static String doctypeSchema(String doctype) =>
      '/api/resource/DocType/$doctype';

  // ─── Workflow ───
  static const String getTransitions =
      '/api/method/frappe.model.workflow.get_transitions';
  static const String applyWorkflow =
      '/api/method/frappe.model.workflow.apply_workflow';

  // ─── Permissions ───
  static const String getPermissions =
      '/api/method/frappe.client.get_permissions';
  static const String hasPermission =
      '/api/method/frappe.client.has_permission';

  // ─── Comments ───
  static const String comments = '/api/resource/Comment';

  // ─── Versions (Change History) ───
  static const String versions = '/api/resource/Version';

  // ─── Attachments ───
  static const String files = '/api/resource/File';
  static const String uploadFile = '/api/method/upload_file';

  // ─── Notifications ───
  static const String notifications = '/api/resource/Notification Log';

  // ─── Print ───
  static const String printFormat = '/api/method/frappe.utils.print_format.download_pdf';

  // ─── Generic Method Call ───
  static String method(String methodPath) => '/api/method/$methodPath';

  // ─── Count ───
  static const String getCount = '/api/method/frappe.client.get_count';

  // ─── Link Options (for Link fields) ───
  static const String getLinkOptions =
      '/api/method/frappe.client.get_list';
}
