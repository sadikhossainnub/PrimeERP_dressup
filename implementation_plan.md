# Flutter ERPNext Mobile App — Full Implementation Plan
**Project:** `frappe_mobile` — Unified app for Dress Up & Paperware Factory  
**Author:** Abu Sayed | **Stack:** Flutter 3.x · Riverpod · Dio · GoRouter · Hive  
**Target:** Android (primary) · iOS (secondary)  
**ERPNext Servers:** `erp.dressup.com.bd` · `erp.paperwarefactory.com`

---

## Table of Contents
1. [Project Architecture](#1-project-architecture)
2. [Folder Structure](#2-folder-structure)
3. [Dependencies](#3-dependencies)
4. [Phase 1 — Foundation](#4-phase-1--foundation)
5. [Phase 2 — DocType Engine](#5-phase-2--doctype-engine)
6. [Phase 3 — Dashboard & Reports](#6-phase-3--dashboard--reports)
7. [Phase 4 — Files, Print & Barcode](#7-phase-4--files-print--barcode)
8. [Phase 5 — Notifications & Realtime](#8-phase-5--notifications--realtime)
9. [Phase 6 — Offline & Multi-Instance](#9-phase-6--offline--multi-instance)
10. [Phase 7 — Business Modules](#10-phase-7--business-modules)
11. [Frappe API Reference](#11-frappe-api-reference)
12. [State Management Pattern](#12-state-management-pattern)
13. [Error Handling Strategy](#13-error-handling-strategy)
14. [Security Checklist](#14-security-checklist)
15. [Release Checklist](#15-release-checklist)

---

## 1. Project Architecture

```
Clean Architecture (Feature-based)
┌─────────────────────────────────────────────────────┐
│  Presentation Layer  (Widgets, Pages, Providers)    │
├─────────────────────────────────────────────────────┤
│  Domain Layer        (Entities, UseCases, Repos)    │
├─────────────────────────────────────────────────────┤
│  Data Layer          (API, Local DB, Models)        │
├─────────────────────────────────────────────────────┤
│  Core               (DI, Router, Theme, Constants)  │
└─────────────────────────────────────────────────────┘
```

### Key Design Decisions
- **Riverpod** — state management, dependency injection
- **Dio** — HTTP client with interceptors (auth, retry, logging)
- **GoRouter** — declarative routing with auth guard
- **Hive** — lightweight local storage for offline cache + settings
- **flutter_secure_storage** — store session tokens securely
- **Dynamic Form Engine** — one engine renders ALL DocType forms

---

## 2. Folder Structure

```
lib/
├── main.dart
├── app.dart                          # MaterialApp + ProviderScope
│
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart        # All Frappe API paths
│   │   └── app_constants.dart
│   ├── di/
│   │   └── providers.dart            # Global Riverpod providers
│   ├── router/
│   │   ├── app_router.dart           # GoRouter config
│   │   └── route_guards.dart         # Auth guard
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── network/
│   │   ├── dio_client.dart           # Base Dio setup
│   │   ├── auth_interceptor.dart     # Attach session token
│   │   ├── error_interceptor.dart    # 401 → re-login
│   │   └── api_response.dart         # Generic response wrapper
│   ├── storage/
│   │   ├── secure_storage.dart       # flutter_secure_storage
│   │   └── hive_storage.dart         # Hive boxes
│   └── utils/
│       ├── date_utils.dart
│       ├── frappe_utils.dart         # name_case, doctype_to_route
│       └── validators.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_api.dart
│   │   │   └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── auth_repository.dart
│   │   │   └── user_entity.dart
│   │   └── presentation/
│   │       ├── login_page.dart
│   │       ├── server_select_page.dart   # Multi-instance
│   │       └── auth_provider.dart
│   │
│   ├── dashboard/
│   │   ├── data/
│   │   │   └── dashboard_api.dart
│   │   ├── domain/
│   │   │   └── dashboard_entity.dart
│   │   └── presentation/
│   │       ├── dashboard_page.dart
│   │       ├── kpi_card_widget.dart
│   │       ├── chart_widget.dart
│   │       └── dashboard_provider.dart
│   │
│   ├── doctype/                          # ★ Core engine
│   │   ├── data/
│   │   │   ├── doctype_api.dart
│   │   │   ├── doctype_meta_api.dart     # /api/method/frappe.desk.form.load.getdoc
│   │   │   └── doctype_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── doctype_repository.dart
│   │   │   ├── doctype_meta.dart         # FieldType, DocField, DocMeta
│   │   │   └── doc_entity.dart
│   │   └── presentation/
│   │       ├── list/
│   │       │   ├── doctype_list_page.dart
│   │       │   ├── doctype_list_tile.dart
│   │       │   └── list_filter_sheet.dart
│   │       ├── form/
│   │       │   ├── doctype_form_page.dart
│   │       │   ├── form_provider.dart
│   │       │   └── fields/              # One widget per field type
│   │       │       ├── field_text.dart
│   │       │       ├── field_int.dart
│   │       │       ├── field_float.dart
│   │       │       ├── field_select.dart
│   │       │       ├── field_link.dart       # Searchable popup
│   │       │       ├── field_date.dart
│   │       │       ├── field_datetime.dart
│   │       │       ├── field_check.dart
│   │       │       ├── field_attach.dart
│   │       │       ├── field_small_text.dart
│   │       │       ├── field_text_editor.dart
│   │       │       ├── field_table.dart      # Child table
│   │       │       └── field_factory.dart    # FieldType → Widget
│   │       └── comments/
│   │           ├── comment_section.dart
│   │           └── activity_timeline.dart
│   │
│   ├── reports/
│   │   ├── data/
│   │   │   └── report_api.dart
│   │   └── presentation/
│   │       ├── report_list_page.dart
│   │       ├── report_view_page.dart
│   │       └── report_filter_widget.dart
│   │
│   ├── files/
│   │   ├── data/
│   │   │   └── file_api.dart
│   │   └── presentation/
│   │       ├── attachment_list.dart
│   │       └── file_upload_widget.dart
│   │
│   ├── notifications/
│   │   ├── data/
│   │   │   └── notification_api.dart
│   │   └── presentation/
│   │       ├── notification_list_page.dart
│   │       └── notification_badge.dart
│   │
│   ├── barcode/
│   │   └── presentation/
│   │       └── barcode_scanner_page.dart
│   │
│   └── settings/
│       └── presentation/
│           ├── settings_page.dart
│           └── server_profile_page.dart
│
└── shared/
    ├── widgets/
    │   ├── app_bar_widget.dart
    │   ├── loading_widget.dart
    │   ├── error_widget.dart
    │   ├── empty_state_widget.dart
    │   ├── confirm_dialog.dart
    │   └── frappe_badge.dart           # Workflow status badge
    └── models/
        └── pagination_model.dart
```

---

## 3. Dependencies

```yaml
# pubspec.yaml
name: frappe_mobile
description: ERPNext Mobile for Dress Up & Paperware Factory

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.13.0"

dependencies:
  flutter:
    sdk: flutter

  # State Management & DI
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^13.2.0

  # Network
  dio: ^5.4.3
  pretty_dio_logger: ^1.3.1

  # Local Storage
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0

  # UI
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  fl_chart: ^0.67.0          # Dashboard charts
  data_table_2: ^2.5.14      # Report table

  # File & Media
  image_picker: ^1.1.2
  file_picker: ^8.0.0+1
  path_provider: ^2.1.3
  open_file: ^3.3.2
  share_plus: ^9.0.0

  # Barcode
  mobile_scanner: ^5.2.1

  # Notifications
  firebase_messaging: ^14.9.4
  flutter_local_notifications: ^17.2.2
  firebase_core: ^2.32.0

  # Utilities
  intl: ^0.19.0
  json_annotation: ^4.9.0
  equatable: ^2.0.5
  dartz: ^0.10.1             # Either for error handling
  connectivity_plus: ^6.0.3
  url_launcher: ^6.3.0

  # PDF viewer
  flutter_pdfview: ^1.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  json_serializable: ^6.8.0
  hive_generator: ^2.0.1
  riverpod_generator: ^2.4.0
  flutter_lints: ^3.0.0
```

---

## 4. Phase 1 — Foundation

**Duration:** 3–4 days  
**Goal:** App shell, auth, multi-server profile, navigation

### 4.1 Multi-Server Profile System

```dart
// core/storage/server_profile.dart
@HiveType(typeId: 0)
class ServerProfile extends HiveObject {
  @HiveField(0) String name;         // "Dress Up", "Paperware"
  @HiveField(1) String baseUrl;      // "https://erp.dressup.com.bd"
  @HiveField(2) String? sessionToken;
  @HiveField(3) String? userId;
  @HiveField(4) bool isActive;
}
```

**Supported servers:**
- `https://erp.dressup.com.bd`
- `https://erp.paperwarefactory.com`

### 4.2 Dio Client Setup

```dart
// core/network/dio_client.dart
class DioClient {
  static Dio create(String baseUrl, SecureStorage storage) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.addAll([
      AuthInterceptor(storage),       // Attach sid cookie
      ErrorInterceptor(),             // Handle 401, 403, 500
      RetryInterceptor(dio),          // Retry on network error
      if (kDebugMode) PrettyDioLogger(),
    ]);

    return dio;
  }
}
```

### 4.3 Auth Flow

```
Server Select Page
      ↓
  Login Page  ──[POST /api/method/login]──→  Frappe
      ↓  (success: sid token)
  Save to SecureStorage
      ↓
  Home Dashboard
```

**Login API call:**
```dart
// POST /api/method/login
// Body: { "usr": "admin", "pwd": "password" }
// Response: { "message": "Logged In", "home_page": "/app", "full_name": "..." }
// Cookie: sid=xxx (save this for all subsequent requests)
```

### 4.4 Router Structure

```dart
// core/router/app_router.dart
final router = GoRouter(
  redirect: (ctx, state) => authGuard(ctx, state),
  routes: [
    GoRoute(path: '/login', builder: (_,__) => LoginPage()),
    GoRoute(path: '/server-select', builder: (_,__) => ServerSelectPage()),
    ShellRoute(
      builder: (ctx, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_,__) => DashboardPage()),
        GoRoute(
          path: '/list/:doctype',
          builder: (_, state) => DoctypeListPage(
            doctype: state.pathParameters['doctype']!,
          ),
        ),
        GoRoute(
          path: '/form/:doctype/:name',
          builder: (_, state) => DoctypeFormPage(
            doctype: state.pathParameters['doctype']!,
            name: state.pathParameters['name']!,
          ),
        ),
        GoRoute(
          path: '/form/:doctype/new',
          builder: (_, state) => DoctypeFormPage(
            doctype: state.pathParameters['doctype']!,
            name: 'new-doc-1',
            isNew: true,
          ),
        ),
        GoRoute(path: '/reports', builder: (_,__) => ReportListPage()),
        GoRoute(
          path: '/report/:name',
          builder: (_, state) => ReportViewPage(
            reportName: state.pathParameters['name']!,
          ),
        ),
        GoRoute(path: '/notifications', builder: (_,__) => NotificationListPage()),
        GoRoute(path: '/settings', builder: (_,__) => SettingsPage()),
      ],
    ),
  ],
);
```

### 4.5 Main Shell (Bottom Navigation)

```dart
// Bottom nav items:
// [Dashboard] [Modules] [Quick Actions +] [Reports] [Settings]
```

---

## 5. Phase 2 — DocType Engine

**Duration:** 7–10 days  
**Goal:** Full CRUD for any DocType, dynamic form rendering

### 5.1 Fetch DocType Meta

```dart
// GET /api/method/frappe.desk.form.load.getdoc?doctype={DocType}&name={name}
// OR for new doc meta only:
// GET /api/method/frappe.desk.form.utils.get_doctype_for_doclist?doctype={DocType}

// Returns: fields[], permissions{}, workflow_state_field, title_field, etc.
```

**DocField types to handle:**

| Frappe FieldType | Flutter Widget |
|---|---|
| `Data` | TextField |
| `Int` | TextField (numberKeyboard) |
| `Float` / `Currency` | TextField (decimalKeyboard) |
| `Small Text` | TextField (multiline 3 lines) |
| `Text Editor` | Basic multiline TextField |
| `Date` | DatePicker |
| `Datetime` | DateTimePicker |
| `Select` | DropdownField |
| `Link` | SearchableLinkField (popup) |
| `Check` | SwitchTile |
| `Attach` / `Attach Image` | FilePickerField |
| `Table` | ChildTableWidget |
| `Section Break` | SectionHeader (grey divider) |
| `Column Break` | ColumnBreak (layout) |
| `HTML` | Skip |
| `Heading` | HeadingText |

### 5.2 Field Factory

```dart
// features/doctype/presentation/form/fields/field_factory.dart
Widget buildField(DocField field, DocFormState state) {
  if (field.hidden == 1) return const SizedBox.shrink();
  if (!checkPermissionAndDependsOn(field, state)) return const SizedBox.shrink();

  return switch (field.fieldtype) {
    'Data'          => FieldText(field: field, state: state),
    'Int'           => FieldInt(field: field, state: state),
    'Float' ||
    'Currency'      => FieldFloat(field: field, state: state),
    'Select'        => FieldSelect(field: field, state: state),
    'Link'          => FieldLink(field: field, state: state),
    'Date'          => FieldDate(field: field, state: state),
    'Datetime'      => FieldDatetime(field: field, state: state),
    'Check'         => FieldCheck(field: field, state: state),
    'Small Text' ||
    'Text'          => FieldSmallText(field: field, state: state),
    'Attach' ||
    'Attach Image'  => FieldAttach(field: field, state: state),
    'Table'         => FieldTable(field: field, state: state),
    'Section Break' => SectionBreakWidget(field: field),
    _               => const SizedBox.shrink(),
  };
}
```

### 5.3 Link Field (Searchable Popup)

```dart
// GET /api/method/frappe.client.search_link
// ?doctype=Customer&txt=abc&query=&filters=[]&page_length=20

// Show bottom sheet with search + paginated results
// On select → update field value
```

### 5.4 Child Table Widget

```dart
// ChildTableWidget displays a DataTable for child DocType rows
// Features:
//   - Add row → opens mini form for child DocType fields
//   - Edit row → tap to open mini form
//   - Delete row → swipe or long press
//   - Reorder rows (optional)
```

### 5.5 Document Actions

```dart
// Save (draft)
PUT /api/resource/{DocType}/{name}
Body: { ...fieldValues }

// Submit
POST /api/method/frappe.client.submit
Body: { "doc": { "doctype": "Sales Invoice", "name": "...", ...} }

// Cancel
POST /api/method/frappe.client.cancel
Body: { "doctype": "Sales Invoice", "name": "..." }

// Amend (creates new doc with amended_from set)
// Just open new form with amended_from = original.name

// Delete
DELETE /api/resource/{DocType}/{name}
```

### 5.6 Depends On / Mandatory Evaluation

```dart
// field.depends_on = "eval:doc.status == 'Open'"
// field.mandatory_depends_on = "eval:doc.type == 'Credit'"
// Parse these expressions using simple eval engine:

bool evaluateExpr(String expr, Map<String, dynamic> doc) {
  // Remove "eval:" prefix
  // Replace "doc.fieldname" with actual values
  // Use dart_eval or simple regex-based evaluator
}
```

---

## 6. Phase 3 — Dashboard & Reports

**Duration:** 3–4 days

### 6.1 Home Dashboard

```dart
// GET /api/method/frappe.desk.desktop.get_desktop_page_data
// Returns: shortcuts[], cards[], charts[]

// Render:
// - Shortcuts as grid of icon+label tappable cards
// - Number cards (KPI) as colored stat cards
// - Charts using fl_chart (LineChart, BarChart, PieChart)
```

**Dashboard layout:**
```
┌──────────────────────────────────┐
│  Good morning, Abu Sayed   🔔    │
│  erp.dressup.com.bd              │
├──────────────────────────────────┤
│  [KPI] Total Revenue  ₹4.2L     │
│  [KPI] Open Orders    12         │
├──────────────────────────────────┤
│  Monthly Sales ─────────────     │
│  [Bar Chart]                     │
├──────────────────────────────────┤
│  Shortcuts                       │
│  [Inv] [PO] [SO] [Item] [...]    │
└──────────────────────────────────┘
```

### 6.2 Report View

```dart
// List all reports:
// GET /api/resource/Report?filters=[["report_type","in",["Query Report","Script Report"]]]

// Run a report:
// GET /api/method/frappe.desk.query_report.run
// ?report_name=Stock Balance&filters={"company":"Dress Up"}

// Response: { columns: [], result: [[...], [...]] }
// Render: data_table_2 widget with sticky header
// Actions: Export to CSV, Share PDF
```

---

## 7. Phase 4 — Files, Print & Barcode

**Duration:** 2–3 days

### 7.1 File Upload

```dart
// POST /api/method/upload_file
// Form data: {
//   "file": <binary>,
//   "doctype": "Sales Invoice",
//   "docname": "SINV-00001",
//   "is_private": 0
// }

// Sources:
//   - Gallery (image_picker)
//   - Camera (image_picker)
//   - Files (file_picker)
```

### 7.2 Print Format PDF

```dart
// GET /api/method/frappe.utils.print_format.download_pdf
// ?doctype=Sales Invoice&name=SINV-00001&format=Standard&no_letterhead=0
// Response: PDF binary stream

// Save to temp file → open with flutter_pdfview
// Or share via share_plus
```

### 7.3 Barcode / QR Scanner

```dart
// Use mobile_scanner package
// On scan result → auto-fill Link/Data field
// Use case 1: Scan Item barcode → populate Item field in Sales Invoice
// Use case 2: Scan Serial No → open Serial No document
// Use case 3: Scan QR on document → open that document in app

// GET /api/resource/Item?filters=[["barcode","=","<scanned_code>"]]
```

---

## 8. Phase 5 — Notifications & Realtime

**Duration:** 2–3 days

### 8.1 Push Notifications via FCM

```dart
// Step 1: Frappe server-side → install frappe-firebase-push or custom hook
// Step 2: On app login → send FCM token to server
// POST /api/method/your_app.api.register_fcm_token
// Body: { "token": "<fcm_token>", "user": "admin@example.com" }

// Step 3: Handle incoming notification
// Notification types:
//   - Document assigned to user
//   - Workflow state changed
//   - Mention in comment
//   - Custom alert
```

### 8.2 In-App Notifications

```dart
// GET /api/method/frappe.client.get_list
// ?doctype=Notification Log&filters=[["for_user","=","<current_user>"]]
// &fields=["subject","type","document_type","document_name","read","creation"]
// &order_by=creation desc&limit=50

// Mark as read:
// PUT /api/resource/Notification Log/{name}
// Body: { "read": 1 }
```

### 8.3 Socket.io Realtime (Optional but powerful)

```dart
// Package: socket_io_client
// Connect to: wss://erp.dressup.com.bd/

// Events to listen:
// 'doc_update'     → refresh current form if same docname
// 'list_update'    → refresh list if same doctype
// 'msgprint'       → show snackbar
// 'progress'       → background job progress

import 'package:socket_io_client/socket_io_client.dart' as IO;

final socket = IO.io(baseUrl, <String, dynamic>{
  'transports': ['websocket'],
  'extraHeaders': {'Cookie': 'sid=$sessionToken'},
});

socket.on('doc_update', (data) {
  // Invalidate relevant provider
});
```

---

## 9. Phase 6 — Offline & Multi-Instance

**Duration:** 2–3 days

### 9.1 Offline Cache Strategy

```dart
// Cache levels:
// L1 - DocType Meta (rarely changes) → Hive, expires 24h
// L2 - List data (frequently viewed) → Hive, expires 30min
// L3 - Individual docs (opened recently) → Hive, expires 1h
// L4 - Offline write queue → Hive, sync on reconnect

// Connectivity check:
final isOnline = await Connectivity().checkConnectivity()
    .then((r) => r != ConnectivityResult.none);

// If offline → serve from cache + show banner
// If online → fetch fresh + update cache
```

### 9.2 Offline Write Queue

```dart
@HiveType(typeId: 2)
class OfflineAction extends HiveObject {
  @HiveField(0) String method;     // 'create' | 'update' | 'delete'
  @HiveField(1) String doctype;
  @HiveField(2) String? name;
  @HiveField(3) String jsonPayload;
  @HiveField(4) DateTime createdAt;
  @HiveField(5) bool synced;
}

// On reconnect → process queue FIFO
// On conflict → show resolution dialog
```

### 9.3 Multi-Instance Switching

```dart
// Server profiles stored in Hive
// Switching server:
//   1. Save current session
//   2. Load selected profile
//   3. Re-initialize DioClient with new baseUrl
//   4. Invalidate all cached providers
//   5. Navigate to Dashboard

// UI: Settings → Switch Server → Select profile card → Switch
// Show which server is active in AppBar subtitle
```

---

## 10. Phase 7 — Business Modules

**Duration:** Ongoing  
**Goal:** Quick-access shortcuts for Dress Up & Paperware specific workflows

### 10.1 Dress Up Module

```
Quick Actions:
├── New Sales Order
├── New Sales Invoice
├── POS Entry (link to POS page in browser if not native)
├── Customer List
├── Item List
├── Stock Entry
├── Loyalty Points → GET /api/method/...get_loyalty_points
└── WooCommerce Sync Status → erp.dressup.com.bd custom API
```

### 10.2 Paperware Factory Module

```
Quick Actions:
├── New Work Order
├── Production Costing Sheet (custom DocType)
├── Paper Cup Recipe (custom DocType)
├── Raw Material Stock
├── Purchase Order
├── Delivery Note
└── Pre-Costing Calculator (link to custom Frappe page)
```

### 10.3 Module Navigator

```dart
// GET /api/method/frappe.desk.desktop.get_desktop_page_data
// Returns all modules the current user has access to
// Render as grid with module icons
// Tap module → show DocType shortcuts within that module
```

---

## 11. Frappe API Reference

### Authentication
```
POST   /api/method/login                               Login
POST   /api/method/logout                              Logout
GET    /api/method/frappe.auth.get_logged_user         Current user
```

### DocType CRUD
```
GET    /api/resource/{DocType}                         List
GET    /api/resource/{DocType}/{name}                  Read
POST   /api/resource/{DocType}                         Create
PUT    /api/resource/{DocType}/{name}                  Update
DELETE /api/resource/{DocType}/{name}                  Delete
```

### Common Query Params (GET list)
```
?fields=["name","customer","status","grand_total"]
&filters=[["status","=","Open"],["company","=","Dress Up"]]
&or_filters=[["owner","=","me"],["assigned_to","=","me"]]
&order_by=creation desc
&limit=20
&limit_start=0                                         Pagination offset
```

### Document Actions
```
POST   /api/method/frappe.client.submit                Submit doc
POST   /api/method/frappe.client.cancel                Cancel doc
POST   /api/method/frappe.client.set_value             Set single field
POST   /api/method/frappe.client.get_value             Get single field
POST   /api/method/frappe.client.get_list              Advanced list
```

### Meta & Desk
```
GET    /api/method/frappe.desk.form.load.getdoc        Form meta + doc
GET    /api/method/frappe.client.search_link           Link field search
GET    /api/method/frappe.desk.desktop.get_desktop_page_data   Dashboard
GET    /api/method/frappe.desk.query_report.run        Run report
```

### File
```
POST   /api/method/upload_file                         Upload attachment
GET    /api/method/frappe.utils.print_format.download_pdf   Print PDF
```

### Notification
```
GET    /api/resource/Notification Log                  Notification list
GET    /api/method/frappe.client.get_count             Unread count
```

### Useful Filters Cheatsheet
```dart
// Open Sales Orders for current user
[["Sales Order", "status", "=", "To Deliver and Bill"],
 ["Sales Order", "owner", "=", frappe.session.user]]

// Items low on stock
[["Bin", "actual_qty", "<", 10]]

// This month's invoices
[["Sales Invoice", "posting_date", ">=", "2025-01-01"],
 ["Sales Invoice", "docstatus", "=", 1]]
```

---

## 12. State Management Pattern

```dart
// ============================================================
// Example: DocType List Provider
// ============================================================
@riverpod
class DoctypeListNotifier extends _$DoctypeListNotifier {
  @override
  Future<PaginatedResult<DocEntity>> build(String doctype) async {
    return _fetch(doctype, page: 0);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(
      doctype: ref.read(currentDoctypeProvider),
      page: 0,
    ));
  }

  Future<void> loadMore() async { ... }

  Future<void> applyFilter(List<Filter> filters) async { ... }

  Future<PaginatedResult<DocEntity>> _fetch({
    required String doctype,
    required int page,
    List<Filter>? filters,
  }) async {
    final repo = ref.read(doctypeRepositoryProvider);
    return repo.getList(
      doctype: doctype,
      fields: await _getListFields(doctype),
      filters: filters ?? [],
      limit: 20,
      limitStart: page * 20,
    );
  }
}

// ============================================================
// Example: Form Provider
// ============================================================
@riverpod
class DocFormNotifier extends _$DocFormNotifier {
  @override
  Future<DocFormState> build(String doctype, String name) async {
    final meta = await ref.watch(doctypeMetaProvider(doctype).future);
    final doc = name == 'new'
        ? DocEntity.empty(doctype)
        : await ref.watch(docEntityProvider(doctype, name).future);
    return DocFormState(meta: meta, doc: doc, isDirty: false);
  }

  void setValue(String fieldname, dynamic value) {
    state = state.whenData((s) => s.copyWith(
      doc: s.doc.copyWith(data: {...s.doc.data, fieldname: value}),
      isDirty: true,
    ));
  }

  Future<void> save() async { ... }
  Future<void> submit() async { ... }
}
```

---

## 13. Error Handling Strategy

```dart
// core/network/api_response.dart
sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiError<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  const ApiError(this.message, {this.statusCode});
}

// ============================================================
// HTTP Error Codes from Frappe
// ============================================================
// 401 → Session expired → redirect to login
// 403 → No permission → show permission denied page
// 404 → Document not found → show not found page
// 417 → Frappe validation error → show field error
// 500 → Server error → show generic error + log

// ============================================================
// Error Interceptor
// ============================================================
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear session → redirect to login
      authNotifier.logout();
    } else if (err.response?.statusCode == 417) {
      // Extract Frappe exc_type and message
      final msg = err.response?.data['_server_messages'] ?? err.message;
      throw FrappeValidationException(msg);
    }
    handler.next(err);
  }
}
```

---

## 14. Security Checklist

- [ ] Store `sid` cookie in `flutter_secure_storage` (never SharedPreferences)
- [ ] Clear storage completely on logout
- [ ] Certificate pinning for production servers (optional but recommended)
- [ ] Obfuscate release build: `flutter build apk --obfuscate --split-debug-info=...`
- [ ] No hardcoded URLs or credentials in source code
- [ ] Server URLs stored in profile, not constants
- [ ] Validate SSL certificates (Dio default: enabled)
- [ ] Sensitive fields (Password) never stored in Hive
- [ ] API responses never logged in release builds

---

## 15. Release Checklist

### Android
- [ ] `applicationId` set in `build.gradle`
- [ ] Signing keystore configured
- [ ] `minSdkVersion 21`, `targetSdkVersion 34`
- [ ] Permissions in `AndroidManifest.xml`:
  - `INTERNET`, `CAMERA`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`
  - `VIBRATE` (notifications)
- [ ] ProGuard/R8 rules for Hive, Dio, Firebase
- [ ] `flutter build appbundle --release` for Play Store

### iOS
- [ ] Bundle ID configured
- [ ] Provisioning profile set
- [ ] `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` in `Info.plist`
- [ ] `flutter build ipa --release` for App Store

### Pre-release Testing
- [ ] Test on Dress Up server: `erp.dressup.com.bd`
- [ ] Test on Paperware server: `erp.paperwarefactory.com`
- [ ] Test offline mode (airplane mode)
- [ ] Test session expiry handling
- [ ] Test with user with limited permissions
- [ ] Test on Android 8, 10, 13 (min 3 versions)

---

## Development Timeline (Estimated)

```
Week 1  │ Phase 1: Foundation + Auth + Multi-server + Router
Week 2  │ Phase 2: DocType Engine — List + Form + basic fields
Week 3  │ Phase 2: DocType Engine — Link field + Child table + Submit
Week 4  │ Phase 3: Dashboard + Reports
Week 5  │ Phase 4: Files + Print + Barcode
Week 6  │ Phase 5: Notifications + Socket.io
Week 7  │ Phase 6: Offline support + Sync queue
Week 8  │ Phase 7: Business modules (Dress Up + Paperware shortcuts)
Week 9  │ Testing, bug fixes, performance tuning
Week 10 │ Release build + Play Store submission
```

---

## Quick Start Commands

```bash
# Create project
flutter create frappe_mobile --org com.sadikhossainnub --platforms android,ios

# Get dependencies
flutter pub get

# Generate code (Hive adapters, Riverpod providers, JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Run debug
flutter run --debug

# Build release APK
flutter build apk --release --obfuscate --split-debug-info=build/symbols

# Build App Bundle (Play Store)
flutter build appbundle --release
```

---

*Last updated: 2025 | Repository: github.com/sadikhossainnub/frappe_mobile*
