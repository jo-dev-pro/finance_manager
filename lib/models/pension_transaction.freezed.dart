// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pension_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PensionTransaction _$PensionTransactionFromJson(Map<String, dynamic> json) {
  return _PensionTransaction.fromJson(json);
}

/// @nodoc
mixin _$PensionTransaction {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_date')
  String get transactionDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'financial_institution')
  String? get financialInstitution => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_name')
  String get accountName => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_name')
  String? get productName => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_type')
  String get transactionType => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PensionTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PensionTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PensionTransactionCopyWith<PensionTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PensionTransactionCopyWith<$Res> {
  factory $PensionTransactionCopyWith(
    PensionTransaction value,
    $Res Function(PensionTransaction) then,
  ) = _$PensionTransactionCopyWithImpl<$Res, PensionTransaction>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'transaction_date') String transactionDate,
    @JsonKey(name: 'financial_institution') String? financialInstitution,
    @JsonKey(name: 'account_name') String accountName,
    @JsonKey(name: 'product_name') String? productName,
    @JsonKey(name: 'transaction_type') String transactionType,
    double amount,
    String? memo,
    @JsonKey(name: 'created_at') @TimestampConverter() DateTime? createdAt,
  });
}

/// @nodoc
class _$PensionTransactionCopyWithImpl<$Res, $Val extends PensionTransaction>
    implements $PensionTransactionCopyWith<$Res> {
  _$PensionTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PensionTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? transactionDate = null,
    Object? financialInstitution = freezed,
    Object? accountName = null,
    Object? productName = freezed,
    Object? transactionType = null,
    Object? amount = null,
    Object? memo = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            transactionDate:
                null == transactionDate
                    ? _value.transactionDate
                    : transactionDate // ignore: cast_nullable_to_non_nullable
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
            transactionType:
                null == transactionType
                    ? _value.transactionType
                    : transactionType // ignore: cast_nullable_to_non_nullable
                        as String,
            amount:
                null == amount
                    ? _value.amount
                    : amount // ignore: cast_nullable_to_non_nullable
                        as double,
            memo:
                freezed == memo
                    ? _value.memo
                    : memo // ignore: cast_nullable_to_non_nullable
                        as String?,
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
abstract class _$$PensionTransactionImplCopyWith<$Res>
    implements $PensionTransactionCopyWith<$Res> {
  factory _$$PensionTransactionImplCopyWith(
    _$PensionTransactionImpl value,
    $Res Function(_$PensionTransactionImpl) then,
  ) = __$$PensionTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'transaction_date') String transactionDate,
    @JsonKey(name: 'financial_institution') String? financialInstitution,
    @JsonKey(name: 'account_name') String accountName,
    @JsonKey(name: 'product_name') String? productName,
    @JsonKey(name: 'transaction_type') String transactionType,
    double amount,
    String? memo,
    @JsonKey(name: 'created_at') @TimestampConverter() DateTime? createdAt,
  });
}

/// @nodoc
class __$$PensionTransactionImplCopyWithImpl<$Res>
    extends _$PensionTransactionCopyWithImpl<$Res, _$PensionTransactionImpl>
    implements _$$PensionTransactionImplCopyWith<$Res> {
  __$$PensionTransactionImplCopyWithImpl(
    _$PensionTransactionImpl _value,
    $Res Function(_$PensionTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PensionTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? transactionDate = null,
    Object? financialInstitution = freezed,
    Object? accountName = null,
    Object? productName = freezed,
    Object? transactionType = null,
    Object? amount = null,
    Object? memo = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$PensionTransactionImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        transactionDate:
            null == transactionDate
                ? _value.transactionDate
                : transactionDate // ignore: cast_nullable_to_non_nullable
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
        transactionType:
            null == transactionType
                ? _value.transactionType
                : transactionType // ignore: cast_nullable_to_non_nullable
                    as String,
        amount:
            null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                    as double,
        memo:
            freezed == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                    as String?,
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
class _$PensionTransactionImpl implements _PensionTransaction {
  const _$PensionTransactionImpl({
    this.id,
    @JsonKey(name: 'transaction_date') required this.transactionDate,
    @JsonKey(name: 'financial_institution') this.financialInstitution,
    @JsonKey(name: 'account_name') required this.accountName,
    @JsonKey(name: 'product_name') this.productName,
    @JsonKey(name: 'transaction_type') required this.transactionType,
    this.amount = 0,
    this.memo,
    @JsonKey(name: 'created_at') @TimestampConverter() this.createdAt,
  });

  factory _$PensionTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PensionTransactionImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'transaction_date')
  final String transactionDate;
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
  @JsonKey(name: 'transaction_type')
  final String transactionType;
  @override
  @JsonKey()
  final double amount;
  @override
  final String? memo;
  @override
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PensionTransaction(id: $id, transactionDate: $transactionDate, financialInstitution: $financialInstitution, accountName: $accountName, productName: $productName, transactionType: $transactionType, amount: $amount, memo: $memo, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PensionTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transactionDate, transactionDate) ||
                other.transactionDate == transactionDate) &&
            (identical(other.financialInstitution, financialInstitution) ||
                other.financialInstitution == financialInstitution) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    transactionDate,
    financialInstitution,
    accountName,
    productName,
    transactionType,
    amount,
    memo,
    createdAt,
  );

  /// Create a copy of PensionTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PensionTransactionImplCopyWith<_$PensionTransactionImpl> get copyWith =>
      __$$PensionTransactionImplCopyWithImpl<_$PensionTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PensionTransactionImplToJson(this);
  }
}

abstract class _PensionTransaction implements PensionTransaction {
  const factory _PensionTransaction({
    final String? id,
    @JsonKey(name: 'transaction_date') required final String transactionDate,
    @JsonKey(name: 'financial_institution') final String? financialInstitution,
    @JsonKey(name: 'account_name') required final String accountName,
    @JsonKey(name: 'product_name') final String? productName,
    @JsonKey(name: 'transaction_type') required final String transactionType,
    final double amount,
    final String? memo,
    @JsonKey(name: 'created_at')
    @TimestampConverter()
    final DateTime? createdAt,
  }) = _$PensionTransactionImpl;

  factory _PensionTransaction.fromJson(Map<String, dynamic> json) =
      _$PensionTransactionImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'transaction_date')
  String get transactionDate;
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
  @JsonKey(name: 'transaction_type')
  String get transactionType;
  @override
  double get amount;
  @override
  String? get memo;
  @override
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of PensionTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PensionTransactionImplCopyWith<_$PensionTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
