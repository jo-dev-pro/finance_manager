// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Account _$AccountFromJson(Map<String, dynamic> json) {
  return _Account.fromJson(json);
}

/// @nodoc
mixin _$Account {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'financial_institution')
  String get financialInstitution => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_name_id')
  String? get accountNameId => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_type')
  String get accountType => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_number')
  String? get accountNumber => throw _privateConstructorUsedError; // 💡 계좌번호 필드 추가
  @JsonKey(name: 'logo_url')
  String? get logoUrl => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this Account to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AccountCopyWith<Account> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountCopyWith<$Res> {
  factory $AccountCopyWith(Account value, $Res Function(Account) then) =
      _$AccountCopyWithImpl<$Res, Account>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'financial_institution') String financialInstitution,
    @JsonKey(name: 'account_name_id') String? accountNameId,
    @JsonKey(name: 'account_type') String accountType,
    @JsonKey(name: 'account_number') String? accountNumber,
    @JsonKey(name: 'logo_url') String? logoUrl,
    String status,
  });
}

/// @nodoc
class _$AccountCopyWithImpl<$Res, $Val extends Account>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? financialInstitution = null,
    Object? accountNameId = freezed,
    Object? accountType = null,
    Object? accountNumber = freezed,
    Object? logoUrl = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            financialInstitution:
                null == financialInstitution
                    ? _value.financialInstitution
                    : financialInstitution // ignore: cast_nullable_to_non_nullable
                        as String,
            accountNameId:
                freezed == accountNameId
                    ? _value.accountNameId
                    : accountNameId // ignore: cast_nullable_to_non_nullable
                        as String?,
            accountType:
                null == accountType
                    ? _value.accountType
                    : accountType // ignore: cast_nullable_to_non_nullable
                        as String,
            accountNumber:
                freezed == accountNumber
                    ? _value.accountNumber
                    : accountNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            logoUrl:
                freezed == logoUrl
                    ? _value.logoUrl
                    : logoUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AccountImplCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$$AccountImplCopyWith(
    _$AccountImpl value,
    $Res Function(_$AccountImpl) then,
  ) = __$$AccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'financial_institution') String financialInstitution,
    @JsonKey(name: 'account_name_id') String? accountNameId,
    @JsonKey(name: 'account_type') String accountType,
    @JsonKey(name: 'account_number') String? accountNumber,
    @JsonKey(name: 'logo_url') String? logoUrl,
    String status,
  });
}

/// @nodoc
class __$$AccountImplCopyWithImpl<$Res>
    extends _$AccountCopyWithImpl<$Res, _$AccountImpl>
    implements _$$AccountImplCopyWith<$Res> {
  __$$AccountImplCopyWithImpl(
    _$AccountImpl _value,
    $Res Function(_$AccountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? financialInstitution = null,
    Object? accountNameId = freezed,
    Object? accountType = null,
    Object? accountNumber = freezed,
    Object? logoUrl = freezed,
    Object? status = null,
  }) {
    return _then(
      _$AccountImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        financialInstitution:
            null == financialInstitution
                ? _value.financialInstitution
                : financialInstitution // ignore: cast_nullable_to_non_nullable
                    as String,
        accountNameId:
            freezed == accountNameId
                ? _value.accountNameId
                : accountNameId // ignore: cast_nullable_to_non_nullable
                    as String?,
        accountType:
            null == accountType
                ? _value.accountType
                : accountType // ignore: cast_nullable_to_non_nullable
                    as String,
        accountNumber:
            freezed == accountNumber
                ? _value.accountNumber
                : accountNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        logoUrl:
            freezed == logoUrl
                ? _value.logoUrl
                : logoUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountImpl implements _Account {
  const _$AccountImpl({
    this.id,
    @JsonKey(name: 'financial_institution') required this.financialInstitution,
    @JsonKey(name: 'account_name_id') this.accountNameId,
    @JsonKey(name: 'account_type') required this.accountType,
    @JsonKey(name: 'account_number') this.accountNumber,
    @JsonKey(name: 'logo_url') this.logoUrl,
    this.status = '활동',
  });

  factory _$AccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'financial_institution')
  final String financialInstitution;
  @override
  @JsonKey(name: 'account_name_id')
  final String? accountNameId;
  @override
  @JsonKey(name: 'account_type')
  final String accountType;
  @override
  @JsonKey(name: 'account_number')
  final String? accountNumber;
  // 💡 계좌번호 필드 추가
  @override
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  @override
  @JsonKey()
  final String status;

  @override
  String toString() {
    return 'Account(id: $id, financialInstitution: $financialInstitution, accountNameId: $accountNameId, accountType: $accountType, accountNumber: $accountNumber, logoUrl: $logoUrl, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.financialInstitution, financialInstitution) ||
                other.financialInstitution == financialInstitution) &&
            (identical(other.accountNameId, accountNameId) ||
                other.accountNameId == accountNameId) &&
            (identical(other.accountType, accountType) ||
                other.accountType == accountType) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    financialInstitution,
    accountNameId,
    accountType,
    accountNumber,
    logoUrl,
    status,
  );

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountImplCopyWith<_$AccountImpl> get copyWith =>
      __$$AccountImplCopyWithImpl<_$AccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountImplToJson(this);
  }
}

abstract class _Account implements Account {
  const factory _Account({
    final String? id,
    @JsonKey(name: 'financial_institution')
    required final String financialInstitution,
    @JsonKey(name: 'account_name_id') final String? accountNameId,
    @JsonKey(name: 'account_type') required final String accountType,
    @JsonKey(name: 'account_number') final String? accountNumber,
    @JsonKey(name: 'logo_url') final String? logoUrl,
    final String status,
  }) = _$AccountImpl;

  factory _Account.fromJson(Map<String, dynamic> json) = _$AccountImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'financial_institution')
  String get financialInstitution;
  @override
  @JsonKey(name: 'account_name_id')
  String? get accountNameId;
  @override
  @JsonKey(name: 'account_type')
  String get accountType;
  @override
  @JsonKey(name: 'account_number')
  String? get accountNumber; // 💡 계좌번호 필드 추가
  @override
  @JsonKey(name: 'logo_url')
  String? get logoUrl;
  @override
  String get status;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccountImplCopyWith<_$AccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
