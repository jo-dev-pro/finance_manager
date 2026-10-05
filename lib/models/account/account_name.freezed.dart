// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_name.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AccountName _$AccountNameFromJson(Map<String, dynamic> json) {
  return _AccountName.fromJson(json);
}

/// @nodoc
mixin _$AccountName {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_name')
  String get accountName => throw _privateConstructorUsedError;

  /// Serializes this AccountName to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AccountName
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AccountNameCopyWith<AccountName> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountNameCopyWith<$Res> {
  factory $AccountNameCopyWith(
    AccountName value,
    $Res Function(AccountName) then,
  ) = _$AccountNameCopyWithImpl<$Res, AccountName>;
  @useResult
  $Res call({String? id, @JsonKey(name: 'account_name') String accountName});
}

/// @nodoc
class _$AccountNameCopyWithImpl<$Res, $Val extends AccountName>
    implements $AccountNameCopyWith<$Res> {
  _$AccountNameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AccountName
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? accountName = null}) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            accountName:
                null == accountName
                    ? _value.accountName
                    : accountName // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AccountNameImplCopyWith<$Res>
    implements $AccountNameCopyWith<$Res> {
  factory _$$AccountNameImplCopyWith(
    _$AccountNameImpl value,
    $Res Function(_$AccountNameImpl) then,
  ) = __$$AccountNameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, @JsonKey(name: 'account_name') String accountName});
}

/// @nodoc
class __$$AccountNameImplCopyWithImpl<$Res>
    extends _$AccountNameCopyWithImpl<$Res, _$AccountNameImpl>
    implements _$$AccountNameImplCopyWith<$Res> {
  __$$AccountNameImplCopyWithImpl(
    _$AccountNameImpl _value,
    $Res Function(_$AccountNameImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AccountName
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? accountName = null}) {
    return _then(
      _$AccountNameImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        accountName:
            null == accountName
                ? _value.accountName
                : accountName // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountNameImpl implements _AccountName {
  const _$AccountNameImpl({
    this.id,
    @JsonKey(name: 'account_name') required this.accountName,
  });

  factory _$AccountNameImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountNameImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'account_name')
  final String accountName;

  @override
  String toString() {
    return 'AccountName(id: $id, accountName: $accountName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountNameImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, accountName);

  /// Create a copy of AccountName
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountNameImplCopyWith<_$AccountNameImpl> get copyWith =>
      __$$AccountNameImplCopyWithImpl<_$AccountNameImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountNameImplToJson(this);
  }
}

abstract class _AccountName implements AccountName {
  const factory _AccountName({
    final String? id,
    @JsonKey(name: 'account_name') required final String accountName,
  }) = _$AccountNameImpl;

  factory _AccountName.fromJson(Map<String, dynamic> json) =
      _$AccountNameImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'account_name')
  String get accountName;

  /// Create a copy of AccountName
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccountNameImplCopyWith<_$AccountNameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
