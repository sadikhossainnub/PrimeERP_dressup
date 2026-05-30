// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentFrappeUserHash() => r'ac532cbe0e3fdd863c7eb3fbaf6fa016839356c5';

/// Fetch current logged-in user's profile and roles
/// GET /api/method/frappe.client.get?doctype=User&name={username}&fields=[...]
/// Caches in Hive with 10 min TTL
///
/// Copied from [currentFrappeUser].
@ProviderFor(currentFrappeUser)
final currentFrappeUserProvider =
    AutoDisposeFutureProvider<FrappeUserModel>.internal(
      currentFrappeUser,
      name: r'currentFrappeUserProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentFrappeUserHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentFrappeUserRef = AutoDisposeFutureProviderRef<FrappeUserModel>;
String _$userRolesHash() => r'e6c0e7a7b7edc5dd396eff877c2542b5ff6c7162';

/// Get user's roles list
///
/// Copied from [userRoles].
@ProviderFor(userRoles)
final userRolesProvider = AutoDisposeFutureProvider<List<String>>.internal(
  userRoles,
  name: r'userRolesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRolesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRolesRef = AutoDisposeFutureProviderRef<List<String>>;
String _$isSystemManagerHash() => r'4b97de1651c32ec356cf05ba230fef93be1cf82f';

/// Check if user is System Manager or Administrator
///
/// Copied from [isSystemManager].
@ProviderFor(isSystemManager)
final isSystemManagerProvider = AutoDisposeFutureProvider<bool>.internal(
  isSystemManager,
  name: r'isSystemManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isSystemManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsSystemManagerRef = AutoDisposeFutureProviderRef<bool>;
String _$allDoctypePermissionsHash() =>
    r'1206fcf1c4ac1db258c738ef85251cc0eda990ef';

/// Batch fetch all DocType permissions for user's roles (Frappe v15 Endpoint F)
/// GET /api/method/frappe.client.get_list
///   ?doctype=DocPerm
///   &filters=[["role","in",{roles}],["permlevel","=",0]]
///   &fields=[...]
/// Returns: Map<String, UserPermissions> where key = doctype name
/// Permissions are additive across roles (OR logic)
///
/// Copied from [allDoctypePermissions].
@ProviderFor(allDoctypePermissions)
final allDoctypePermissionsProvider =
    AutoDisposeFutureProvider<Map<String, UserPermissions>>.internal(
      allDoctypePermissions,
      name: r'allDoctypePermissionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allDoctypePermissionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllDoctypePermissionsRef =
    AutoDisposeFutureProviderRef<Map<String, UserPermissions>>;
String _$doctypePermissionHash() => r'899db592fbfaf1fa5e6fdf11fbfab05bb8865d23';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Get permission for a specific doctype
///
/// Copied from [doctypePermission].
@ProviderFor(doctypePermission)
const doctypePermissionProvider = DoctypePermissionFamily();

/// Get permission for a specific doctype
///
/// Copied from [doctypePermission].
class DoctypePermissionFamily extends Family<AsyncValue<UserPermissions>> {
  /// Get permission for a specific doctype
  ///
  /// Copied from [doctypePermission].
  const DoctypePermissionFamily();

  /// Get permission for a specific doctype
  ///
  /// Copied from [doctypePermission].
  DoctypePermissionProvider call(String doctype) {
    return DoctypePermissionProvider(doctype);
  }

  @override
  DoctypePermissionProvider getProviderOverride(
    covariant DoctypePermissionProvider provider,
  ) {
    return call(provider.doctype);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'doctypePermissionProvider';
}

/// Get permission for a specific doctype
///
/// Copied from [doctypePermission].
class DoctypePermissionProvider
    extends AutoDisposeFutureProvider<UserPermissions> {
  /// Get permission for a specific doctype
  ///
  /// Copied from [doctypePermission].
  DoctypePermissionProvider(String doctype)
    : this._internal(
        (ref) => doctypePermission(ref as DoctypePermissionRef, doctype),
        from: doctypePermissionProvider,
        name: r'doctypePermissionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$doctypePermissionHash,
        dependencies: DoctypePermissionFamily._dependencies,
        allTransitiveDependencies:
            DoctypePermissionFamily._allTransitiveDependencies,
        doctype: doctype,
      );

  DoctypePermissionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.doctype,
  }) : super.internal();

  final String doctype;

  @override
  Override overrideWith(
    FutureOr<UserPermissions> Function(DoctypePermissionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DoctypePermissionProvider._internal(
        (ref) => create(ref as DoctypePermissionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        doctype: doctype,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserPermissions> createElement() {
    return _DoctypePermissionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DoctypePermissionProvider && other.doctype == doctype;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, doctype.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DoctypePermissionRef on AutoDisposeFutureProviderRef<UserPermissions> {
  /// The parameter `doctype` of this provider.
  String get doctype;
}

class _DoctypePermissionProviderElement
    extends AutoDisposeFutureProviderElement<UserPermissions>
    with DoctypePermissionRef {
  _DoctypePermissionProviderElement(super.provider);

  @override
  String get doctype => (origin as DoctypePermissionProvider).doctype;
}

String _$userRecordPermissionsHash() =>
    r'4e00055713c79b400ffa5a490aa50850fecd6621';

/// Get user's record-level permissions (User Permissions DocType)
/// Frappe v15 Endpoint E
/// Returns: Map<String, List<String>> where key = field name, value = allowed values
///
/// Copied from [userRecordPermissions].
@ProviderFor(userRecordPermissions)
final userRecordPermissionsProvider =
    AutoDisposeFutureProvider<Map<String, List<String>>>.internal(
      userRecordPermissions,
      name: r'userRecordPermissionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userRecordPermissionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRecordPermissionsRef =
    AutoDisposeFutureProviderRef<Map<String, List<String>>>;
String _$autoFiltersForListHash() =>
    r'6359a98d6a19b2241e03b465563a31a20d93977c';

/// Build auto-filters for list views based on user permissions
/// Maps record permission doctypes to filter field names
///
/// Copied from [autoFiltersForList].
@ProviderFor(autoFiltersForList)
const autoFiltersForListProvider = AutoFiltersForListFamily();

/// Build auto-filters for list views based on user permissions
/// Maps record permission doctypes to filter field names
///
/// Copied from [autoFiltersForList].
class AutoFiltersForListFamily extends Family<List<List<dynamic>>> {
  /// Build auto-filters for list views based on user permissions
  /// Maps record permission doctypes to filter field names
  ///
  /// Copied from [autoFiltersForList].
  const AutoFiltersForListFamily();

  /// Build auto-filters for list views based on user permissions
  /// Maps record permission doctypes to filter field names
  ///
  /// Copied from [autoFiltersForList].
  AutoFiltersForListProvider call(String doctype) {
    return AutoFiltersForListProvider(doctype);
  }

  @override
  AutoFiltersForListProvider getProviderOverride(
    covariant AutoFiltersForListProvider provider,
  ) {
    return call(provider.doctype);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'autoFiltersForListProvider';
}

/// Build auto-filters for list views based on user permissions
/// Maps record permission doctypes to filter field names
///
/// Copied from [autoFiltersForList].
class AutoFiltersForListProvider
    extends AutoDisposeProvider<List<List<dynamic>>> {
  /// Build auto-filters for list views based on user permissions
  /// Maps record permission doctypes to filter field names
  ///
  /// Copied from [autoFiltersForList].
  AutoFiltersForListProvider(String doctype)
    : this._internal(
        (ref) => autoFiltersForList(ref as AutoFiltersForListRef, doctype),
        from: autoFiltersForListProvider,
        name: r'autoFiltersForListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$autoFiltersForListHash,
        dependencies: AutoFiltersForListFamily._dependencies,
        allTransitiveDependencies:
            AutoFiltersForListFamily._allTransitiveDependencies,
        doctype: doctype,
      );

  AutoFiltersForListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.doctype,
  }) : super.internal();

  final String doctype;

  @override
  Override overrideWith(
    List<List<dynamic>> Function(AutoFiltersForListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AutoFiltersForListProvider._internal(
        (ref) => create(ref as AutoFiltersForListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        doctype: doctype,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<List<dynamic>>> createElement() {
    return _AutoFiltersForListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AutoFiltersForListProvider && other.doctype == doctype;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, doctype.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AutoFiltersForListRef on AutoDisposeProviderRef<List<List<dynamic>>> {
  /// The parameter `doctype` of this provider.
  String get doctype;
}

class _AutoFiltersForListProviderElement
    extends AutoDisposeProviderElement<List<List<dynamic>>>
    with AutoFiltersForListRef {
  _AutoFiltersForListProviderElement(super.provider);

  @override
  String get doctype => (origin as AutoFiltersForListProvider).doctype;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
