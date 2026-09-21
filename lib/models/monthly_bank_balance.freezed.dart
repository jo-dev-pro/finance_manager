// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_bank_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MonthlyBankBalance _$MonthlyBankBalanceFromJson(Map<String, dynamic> json) {
  return _MonthlyBankBalance.fromJson(json);
}

/// @nodoc
mixin _$MonthlyBankBalance {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'year_month')
  String get yearMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'financial_institution')
  String get financialInstitution => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_name')
  String get accountName => throw _privateConstructorUsedError;
  double get balance => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MonthlyBankBalance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyBankBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyBankBalanceCopyWith<MonthlyBankBalance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyBankBalanceCopyWith<$Res> {
  factory $MonthlyBankBalanceCopyWith(
    MonthlyBankBalance value,
    $Res Function(MonthlyBankBalance) then,
  ) = _$MonthlyBankBalanceCopyWithImpl<$Res, MonthlyBankBalance>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'year_month') String yearMonth,
    @JsonKey(name: 'financial_institution') String financialInstitution,
    @JsonKey(name: 'account_name') String accountName,
    double balance,
    @JsonKey(name: 'created_at') @TimestampConverter() DateTime? createdAt,
  });
}

/// @nodoc
class _$MonthlyBankBalanceCopyWithImpl<$Res, $Val extends MonthlyBankBalance>
    implements $MonthlyBankBalanceCopyWith<$Res> {
  _$MonthlyBankBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyBankBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? yearMonth = null,
    Object? financialInstitution = null,
    Object? accountName = null,
    Object? balance = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            yearMonth:
                null == yearMonth
                    ? _value.yearMonth
                    : yearMonth // ignore: cast_nullable_to_non_nullable
                        as String,
            financialInstitution:
                null == financialInstitution
                    ? _value.financialInstitution
                    : financialInstitution // ignore: cast_nullable_to_non_nullable
                        as String,
            accountName:
                null == accountName
                    ? _value.accountName
                    : accountName // ignore: cast_nullable_to_non_nullable
                        as String,
            balance:
                null == balance
                    ? _value.balance
                    : balance // ignore: cast_nullable_to_non_nullable
                        as double,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthlyBankBalanceImplCopyWith<$Res>
    implements $MonthlyBankBalanceCopyWith<$Res> {
  factory _$$MonthlyBankBalanceImplCopyWith(
    _$MonthlyBankBalanceImpl value,
    $Res Function(_$MonthlyBankBalanceImpl) then,
  ) = __$$MonthlyBankBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'year_month') String yearMonth,
    @JsonKey(name: 'financial_institution') String financialInstitution,
    @JsonKey(name: 'account_name') String accountName,
    double balance,
    @JsonKey(name: 'created_at') @TimestampConverter() DateTime? createdAt,
  });
}

/// @nodoc
class __$$MonthlyBankBalanceImplCopyWithImpl<$Res>
    extends _$MonthlyBankBalanceCopyWithImpl<$Res, _$MonthlyBankBalanceImpl>
    implements _$$MonthlyBankBalanceImplCopyWith<$Res> {
  __$$MonthlyBankBalanceImplCopyWithImpl(
    _$MonthlyBankBalanceImpl _value,
    $Res Function(_$MonthlyBankBalanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyBankBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? yearMonth = null,
    Object? financialInstitution = null,
    Object? accountName = null,
    Object? balance = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$MonthlyBankBalanceImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        yearMonth:
            null == yearMonth
                ? _value.yearMonth
                : yearMonth // ignore: cast_nullable_to_non_nullable
                    as String,
        financialInstitution:
            null == financialInstitution
                ? _value.financialInstitution
                : financialInstitution // ignore: cast_nullable_to_non_nullable
                    as String,
        accountName:
            null == accountName
                ? _value.accountName
                : accountName // ignore: cast_nullable_to_non_nullable
                    as String,
        balance:
            null == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                    as double,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyBankBalanceImpl implements _MonthlyBankBalance {
  const _$MonthlyBankBalanceImpl({
    this.id,
    @JsonKey(name: 'year_month') required this.yearMonth,
    @JsonKey(name: 'financial_institution') required this.financialInstitution,
    @JsonKey(name: 'account_name') required this.accountName,
    this.balance = 0.0,
    @JsonKey(name: 'created_at') @TimestampConverter() this.createdAt,
  });

  factory _$MonthlyBankBalanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyBankBalanceImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'year_month')
  final String yearMonth;
  @override
  @JsonKey(name: 'financial_institution')
  final String financialInstitution;
  @override
  @JsonKey(name: 'account_name')
  final String accountName;
  @override
  @JsonKey()
  final double balance;
  @override
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'MonthlyBankBalance(id: $id, yearMonth: $yearMonth, financialInstitution: $financialInstitution, accountName: $accountName, balance: $balance, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyBankBalanceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.yearMonth, yearMonth) ||
                other.yearMonth == yearMonth) &&
            (identical(other.financialInstitution, financialInstitution) ||
                other.financialInstitution == financialInstitution) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    yearMonth,
    financialInstitution,
    accountName,
    balance,
    createdAt,
  );

  /// Create a copy of MonthlyBankBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyBankBalanceImplCopyWith<_$MonthlyBankBalanceImpl> get copyWith =>
      __$$MonthlyBankBalanceImplCopyWithImpl<_$MonthlyBankBalanceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyBankBalanceImplToJson(this);
  }
}

abstract class _MonthlyBankBalance implements MonthlyBankBalance {
  const factory _MonthlyBankBalance({
    final String? id,
    @JsonKey(name: 'year_month') required final String yearMonth,
    @JsonKey(name: 'financial_institution')
    required final String financialInstitution,
    @JsonKey(name: 'account_name') required final String accountName,
    final double balance,
    @JsonKey(name: 'created_at')
    @TimestampConverter()
    final DateTime? createdAt,
  }) = _$MonthlyBankBalanceImpl;

  factory _MonthlyBankBalance.fromJson(Map<String, dynamic> json) =
      _$MonthlyBankBalanceImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'year_month')
  String get yearMonth;
  @override
  @JsonKey(name: 'financial_institution')
  String get financialInstitution;
  @override
  @JsonKey(name: 'account_name')
  String get accountName;
  @override
  double get balance;
  @override
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of MonthlyBankBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyBankBalanceImplCopyWith<_$MonthlyBankBalanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
