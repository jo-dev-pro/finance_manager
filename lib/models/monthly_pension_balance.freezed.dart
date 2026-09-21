// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_pension_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MonthlyPensionBalance _$MonthlyPensionBalanceFromJson(
  Map<String, dynamic> json,
) {
  return _MonthlyPensionBalance.fromJson(json);
}

/// @nodoc
mixin _$MonthlyPensionBalance {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'year_month')
  String get yearMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'financial_institution')
  String? get financialInstitution => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_name')
  String get accountName => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_name')
  String? get productName => throw _privateConstructorUsedError;
  @JsonKey(name: 'evaluation_amount')
  double get evaluationAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MonthlyPensionBalance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyPensionBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyPensionBalanceCopyWith<MonthlyPensionBalance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyPensionBalanceCopyWith<$Res> {
  factory $MonthlyPensionBalanceCopyWith(
    MonthlyPensionBalance value,
    $Res Function(MonthlyPensionBalance) then,
  ) = _$MonthlyPensionBalanceCopyWithImpl<$Res, MonthlyPensionBalance>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'year_month') String yearMonth,
    @JsonKey(name: 'financial_institution') String? financialInstitution,
    @JsonKey(name: 'account_name') String accountName,
    @JsonKey(name: 'product_name') String? productName,
    @JsonKey(name: 'evaluation_amount') double evaluationAmount,
    @JsonKey(name: 'created_at') @TimestampConverter() DateTime? createdAt,
  });
}

/// @nodoc
class _$MonthlyPensionBalanceCopyWithImpl<
  $Res,
  $Val extends MonthlyPensionBalance
>
    implements $MonthlyPensionBalanceCopyWith<$Res> {
  _$MonthlyPensionBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyPensionBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? yearMonth = null,
    Object? financialInstitution = freezed,
    Object? accountName = null,
    Object? productName = freezed,
    Object? evaluationAmount = null,
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
                freezed == financialInstitution
                    ? _value.financialInstitution
                    : financialInstitution // ignore: cast_nullable_to_non_nullable
                        as String?,
            accountName:
                null == accountName
                    ? _value.accountName
                    : accountName // ignore: cast_nullable_to_non_nullable
                        as String,
            productName:
                freezed == productName
                    ? _value.productName
                    : productName // ignore: cast_nullable_to_non_nullable
                        as String?,
            evaluationAmount:
                null == evaluationAmount
                    ? _value.evaluationAmount
                    : evaluationAmount // ignore: cast_nullable_to_non_nullable
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
abstract class _$$MonthlyPensionBalanceImplCopyWith<$Res>
    implements $MonthlyPensionBalanceCopyWith<$Res> {
  factory _$$MonthlyPensionBalanceImplCopyWith(
    _$MonthlyPensionBalanceImpl value,
    $Res Function(_$MonthlyPensionBalanceImpl) then,
  ) = __$$MonthlyPensionBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'year_month') String yearMonth,
    @JsonKey(name: 'financial_institution') String? financialInstitution,
    @JsonKey(name: 'account_name') String accountName,
    @JsonKey(name: 'product_name') String? productName,
    @JsonKey(name: 'evaluation_amount') double evaluationAmount,
    @JsonKey(name: 'created_at') @TimestampConverter() DateTime? createdAt,
  });
}

/// @nodoc
class __$$MonthlyPensionBalanceImplCopyWithImpl<$Res>
    extends
        _$MonthlyPensionBalanceCopyWithImpl<$Res, _$MonthlyPensionBalanceImpl>
    implements _$$MonthlyPensionBalanceImplCopyWith<$Res> {
  __$$MonthlyPensionBalanceImplCopyWithImpl(
    _$MonthlyPensionBalanceImpl _value,
    $Res Function(_$MonthlyPensionBalanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyPensionBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? yearMonth = null,
    Object? financialInstitution = freezed,
    Object? accountName = null,
    Object? productName = freezed,
    Object? evaluationAmount = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$MonthlyPensionBalanceImpl(
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
            freezed == financialInstitution
                ? _value.financialInstitution
                : financialInstitution // ignore: cast_nullable_to_non_nullable
                    as String?,
        accountName:
            null == accountName
                ? _value.accountName
                : accountName // ignore: cast_nullable_to_non_nullable
                    as String,
        productName:
            freezed == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                    as String?,
        evaluationAmount:
            null == evaluationAmount
                ? _value.evaluationAmount
                : evaluationAmount // ignore: cast_nullable_to_non_nullable
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
class _$MonthlyPensionBalanceImpl implements _MonthlyPensionBalance {
  const _$MonthlyPensionBalanceImpl({
    this.id,
    @JsonKey(name: 'year_month') required this.yearMonth,
    @JsonKey(name: 'financial_institution') this.financialInstitution,
    @JsonKey(name: 'account_name') required this.accountName,
    @JsonKey(name: 'product_name') this.productName,
    @JsonKey(name: 'evaluation_amount') this.evaluationAmount = 0.0,
    @JsonKey(name: 'created_at') @TimestampConverter() this.createdAt,
  });

  factory _$MonthlyPensionBalanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyPensionBalanceImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'year_month')
  final String yearMonth;
  @override
  @JsonKey(name: 'financial_institution')
  final String? financialInstitution;
  @override
  @JsonKey(name: 'account_name')
  final String accountName;
  @override
  @JsonKey(name: 'product_name')
  final String? productName;
  @override
  @JsonKey(name: 'evaluation_amount')
  final double evaluationAmount;
  @override
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'MonthlyPensionBalance(id: $id, yearMonth: $yearMonth, financialInstitution: $financialInstitution, accountName: $accountName, productName: $productName, evaluationAmount: $evaluationAmount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyPensionBalanceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.yearMonth, yearMonth) ||
                other.yearMonth == yearMonth) &&
            (identical(other.financialInstitution, financialInstitution) ||
                other.financialInstitution == financialInstitution) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.evaluationAmount, evaluationAmount) ||
                other.evaluationAmount == evaluationAmount) &&
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
    productName,
    evaluationAmount,
    createdAt,
  );

  /// Create a copy of MonthlyPensionBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyPensionBalanceImplCopyWith<_$MonthlyPensionBalanceImpl>
  get copyWith =>
      __$$MonthlyPensionBalanceImplCopyWithImpl<_$MonthlyPensionBalanceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyPensionBalanceImplToJson(this);
  }
}

abstract class _MonthlyPensionBalance implements MonthlyPensionBalance {
  const factory _MonthlyPensionBalance({
    final String? id,
    @JsonKey(name: 'year_month') required final String yearMonth,
    @JsonKey(name: 'financial_institution') final String? financialInstitution,
    @JsonKey(name: 'account_name') required final String accountName,
    @JsonKey(name: 'product_name') final String? productName,
    @JsonKey(name: 'evaluation_amount') final double evaluationAmount,
    @JsonKey(name: 'created_at')
    @TimestampConverter()
    final DateTime? createdAt,
  }) = _$MonthlyPensionBalanceImpl;

  factory _MonthlyPensionBalance.fromJson(Map<String, dynamic> json) =
      _$MonthlyPensionBalanceImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'year_month')
  String get yearMonth;
  @override
  @JsonKey(name: 'financial_institution')
  String? get financialInstitution;
  @override
  @JsonKey(name: 'account_name')
  String get accountName;
  @override
  @JsonKey(name: 'product_name')
  String? get productName;
  @override
  @JsonKey(name: 'evaluation_amount')
  double get evaluationAmount;
  @override
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of MonthlyPensionBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyPensionBalanceImplCopyWith<_$MonthlyPensionBalanceImpl>
  get copyWith => throw _privateConstructorUsedError;
}
