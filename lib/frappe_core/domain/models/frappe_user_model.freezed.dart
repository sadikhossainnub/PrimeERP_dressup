// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'frappe_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FrappeUserModel {
  String get name => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get userType => throw _privateConstructorUsedError;
  String? get userImage => throw _privateConstructorUsedError;
  List<String> get roles => throw _privateConstructorUsedError;

  /// Create a copy of FrappeUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FrappeUserModelCopyWith<FrappeUserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FrappeUserModelCopyWith<$Res> {
  factory $FrappeUserModelCopyWith(
    FrappeUserModel value,
    $Res Function(FrappeUserModel) then,
  ) = _$FrappeUserModelCopyWithImpl<$Res, FrappeUserModel>;
  @useResult
  $Res call({
    String name,
    String fullName,
    String userType,
    String? userImage,
    List<String> roles,
  });
}

/// @nodoc
class _$FrappeUserModelCopyWithImpl<$Res, $Val extends FrappeUserModel>
    implements $FrappeUserModelCopyWith<$Res> {
  _$FrappeUserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FrappeUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? fullName = null,
    Object? userType = null,
    Object? userImage = freezed,
    Object? roles = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            userType: null == userType
                ? _value.userType
                : userType // ignore: cast_nullable_to_non_nullable
                      as String,
            userImage: freezed == userImage
                ? _value.userImage
                : userImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            roles: null == roles
                ? _value.roles
                : roles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FrappeUserModelImplCopyWith<$Res>
    implements $FrappeUserModelCopyWith<$Res> {
  factory _$$FrappeUserModelImplCopyWith(
    _$FrappeUserModelImpl value,
    $Res Function(_$FrappeUserModelImpl) then,
  ) = __$$FrappeUserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String fullName,
    String userType,
    String? userImage,
    List<String> roles,
  });
}

/// @nodoc
class __$$FrappeUserModelImplCopyWithImpl<$Res>
    extends _$FrappeUserModelCopyWithImpl<$Res, _$FrappeUserModelImpl>
    implements _$$FrappeUserModelImplCopyWith<$Res> {
  __$$FrappeUserModelImplCopyWithImpl(
    _$FrappeUserModelImpl _value,
    $Res Function(_$FrappeUserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FrappeUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? fullName = null,
    Object? userType = null,
    Object? userImage = freezed,
    Object? roles = null,
  }) {
    return _then(
      _$FrappeUserModelImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        userType: null == userType
            ? _value.userType
            : userType // ignore: cast_nullable_to_non_nullable
                  as String,
        userImage: freezed == userImage
            ? _value.userImage
            : userImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        roles: null == roles
            ? _value._roles
            : roles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc

class _$FrappeUserModelImpl extends _FrappeUserModel {
  const _$FrappeUserModelImpl({
    required this.name,
    required this.fullName,
    required this.userType,
    this.userImage,
    final List<String> roles = const [],
  }) : _roles = roles,
       super._();

  @override
  final String name;
  @override
  final String fullName;
  @override
  final String userType;
  @override
  final String? userImage;
  final List<String> _roles;
  @override
  @JsonKey()
  List<String> get roles {
    if (_roles is EqualUnmodifiableListView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roles);
  }

  @override
  String toString() {
    return 'FrappeUserModel(name: $name, fullName: $fullName, userType: $userType, userImage: $userImage, roles: $roles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrappeUserModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.userType, userType) ||
                other.userType == userType) &&
            (identical(other.userImage, userImage) ||
                other.userImage == userImage) &&
            const DeepCollectionEquality().equals(other._roles, _roles));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    fullName,
    userType,
    userImage,
    const DeepCollectionEquality().hash(_roles),
  );

  /// Create a copy of FrappeUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrappeUserModelImplCopyWith<_$FrappeUserModelImpl> get copyWith =>
      __$$FrappeUserModelImplCopyWithImpl<_$FrappeUserModelImpl>(
        this,
        _$identity,
      );
}

abstract class _FrappeUserModel extends FrappeUserModel {
  const factory _FrappeUserModel({
    required final String name,
    required final String fullName,
    required final String userType,
    final String? userImage,
    final List<String> roles,
  }) = _$FrappeUserModelImpl;
  const _FrappeUserModel._() : super._();

  @override
  String get name;
  @override
  String get fullName;
  @override
  String get userType;
  @override
  String? get userImage;
  @override
  List<String> get roles;

  /// Create a copy of FrappeUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrappeUserModelImplCopyWith<_$FrappeUserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
