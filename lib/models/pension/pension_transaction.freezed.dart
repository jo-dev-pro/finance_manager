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
  @JsonKey(name: 'account_id')
  String get accountId => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_type_id')
  String get transactionTypeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String? get productId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  @JsonKey(name: 'purchase_date')
  String? get purchaseDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order')
  int get sortOrder => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'transaction_type_id') String transactionTypeId,
    @JsonKey(name: 'product_id') String? productId,
    double amount,
    String? memo,
    @JsonKey(name: 'purchase_date') String? purchaseDate,
    @JsonKey(name: 'sort_order') int sortOrder,
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
    Object? accountId = null,
    Object? transactionTypeId = null,
    Object? productId = freezed,
    Object? amount = null,
    Object? memo = freezed,
    Object? purchaseDate = freezed,
    Object? sortOrder = null,
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
            accountId:
                null == accountId
                    ? _value.accountId
                    : accountId // ignore: cast_nullable_to_non_nullable
                        as String,
            transactionTypeId:
                null == transactionTypeId
                    ? _value.transactionTypeId
                    : transactionTypeId // ignore: cast_nullable_to_non_nullable
                        as String,
            productId:
                freezed == productId
                    ? _value.productId
                    : productId // ignore: cast_nullable_to_non_nullable
                        as String?,
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
            purchaseDate:
                freezed == purchaseDate
                    ? _value.purchaseDate
                    : purchaseDate // ignore: cast_nullable_to_non_nullable
                        as String?,
            sortOrder:
                null == sortOrder
                    ? _value.sortOrder
                    : sortOrder // ignore: cast_nullable_to_non_nullable
                        as int,
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
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'transaction_type_id') String transactionTypeId,
    @JsonKey(name: 'product_id') String? productId,
    double amount,
    String? memo,
    @JsonKey(name: 'purchase_date') String? purchaseDate,
    @JsonKey(name: 'sort_order') int sortOrder,
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
    Object? accountId = null,
    Object? transactionTypeId = null,
    Object? productId = freezed,
    Object? amount = null,
    Object? memo = freezed,
    Object? purchaseDate = freezed,
    Object? sortOrder = null,
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
        accountId:
            null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                    as String,
        transactionTypeId:
            null == transactionTypeId
                ? _value.transactionTypeId
                : transactionTypeId // ignore: cast_nullable_to_non_nullable
                    as String,
        productId:
            freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                    as String?,
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
        purchaseDate:
            freezed == purchaseDate
                ? _value.purchaseDate
                : purchaseDate // ignore: cast_nullable_to_non_nullable
                    as String?,
        sortOrder:
            null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                    as int,
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
    @JsonKey(name: 'account_id') required this.accountId,
    @JsonKey(name: 'transaction_type_id') required this.transactionTypeId,
    @JsonKey(name: 'product_id') this.productId,
    this.amount = 0,
    this.memo,
    @JsonKey(name: 'purchase_date') this.purchaseDate,
    @JsonKey(name: 'sort_order') this.sortOrder = 0,
  });

  factory _$PensionTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PensionTransactionImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'transaction_date')
  final String transactionDate;
  @override
  @JsonKey(name: 'account_id')
  final String accountId;
  @override
  @JsonKey(name: 'transaction_type_id')
  final String transactionTypeId;
  @override
  @JsonKey(name: 'product_id')
  final String? productId;
  @override
  @JsonKey()
  final double amount;
  @override
  final String? memo;
  @override
  @JsonKey(name: 'purchase_date')
  final String? purchaseDate;
  @override
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  @override
  String toString() {
    return 'PensionTransaction(id: $id, transactionDate: $transactionDate, accountId: $accountId, transactionTypeId: $transactionTypeId, productId: $productId, amount: $amount, memo: $memo, purchaseDate: $purchaseDate, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PensionTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transactionDate, transactionDate) ||
                other.transactionDate == transactionDate) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.transactionTypeId, transactionTypeId) ||
                other.transactionTypeId == transactionTypeId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    transactionDate,
    accountId,
    transactionTypeId,
    productId,
    amount,
    memo,
    purchaseDate,
    sortOrder,
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
    @JsonKey(name: 'account_id') required final String accountId,
    @JsonKey(name: 'transaction_type_id')
    required final String transactionTypeId,
    @JsonKey(name: 'product_id') final String? productId,
    final double amount,
    final String? memo,
    @JsonKey(name: 'purchase_date') final String? purchaseDate,
    @JsonKey(name: 'sort_order') final int sortOrder,
  }) = _$PensionTransactionImpl;

  factory _PensionTransaction.fromJson(Map<String, dynamic> json) =
      _$PensionTransactionImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'transaction_date')
  String get transactionDate;
  @override
  @JsonKey(name: 'account_id')
  String get accountId;
  @override
  @JsonKey(name: 'transaction_type_id')
  String get transactionTypeId;
  @override
  @JsonKey(name: 'product_id')
  String? get productId;
  @override
  double get amount;
  @override
  String? get memo;
  @override
  @JsonKey(name: 'purchase_date')
  String? get purchaseDate;
  @override
  @JsonKey(name: 'sort_order')
  int get sortOrder;

  /// Create a copy of PensionTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PensionTransactionImplCopyWith<_$PensionTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
