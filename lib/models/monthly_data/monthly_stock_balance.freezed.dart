// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_stock_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MonthlyStockBalance _$MonthlyStockBalanceFromJson(Map<String, dynamic> json) {
  return _MonthlyStockBalance.fromJson(json);
}

/// @nodoc
mixin _$MonthlyStockBalance {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'year_month')
  String get yearMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_id')
  String get accountId => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_item_id')
  String get stockItemId => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError; // 당월 말 보유 수량
  @JsonKey(name: 'current_price')
  double get currentPrice => throw _privateConstructorUsedError; // 당월 말 현재가
  double get balance => throw _privateConstructorUsedError; // 당월 말 평가액
  double get principal => throw _privateConstructorUsedError; // 누적 투자 원금
  @JsonKey(name: 'total_payout')
  double get totalPayout => throw _privateConstructorUsedError; // 누적 배당금 등 수령액
  @JsonKey(name: 'total_withdrawal')
  double get totalWithdrawal => throw _privateConstructorUsedError; // 💡 누적 인출액
  @JsonKey(name: 'purchase_date')
  String? get purchaseDate => throw _privateConstructorUsedError;

  /// Serializes this MonthlyStockBalance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyStockBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyStockBalanceCopyWith<MonthlyStockBalance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyStockBalanceCopyWith<$Res> {
  factory $MonthlyStockBalanceCopyWith(
    MonthlyStockBalance value,
    $Res Function(MonthlyStockBalance) then,
  ) = _$MonthlyStockBalanceCopyWithImpl<$Res, MonthlyStockBalance>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'year_month') String yearMonth,
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'stock_item_id') String stockItemId,
    double quantity,
    @JsonKey(name: 'current_price') double currentPrice,
    double balance,
    double principal,
    @JsonKey(name: 'total_payout') double totalPayout,
    @JsonKey(name: 'total_withdrawal') double totalWithdrawal,
    @JsonKey(name: 'purchase_date') String? purchaseDate,
  });
}

/// @nodoc
class _$MonthlyStockBalanceCopyWithImpl<$Res, $Val extends MonthlyStockBalance>
    implements $MonthlyStockBalanceCopyWith<$Res> {
  _$MonthlyStockBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyStockBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? yearMonth = null,
    Object? accountId = null,
    Object? stockItemId = null,
    Object? quantity = null,
    Object? currentPrice = null,
    Object? balance = null,
    Object? principal = null,
    Object? totalPayout = null,
    Object? totalWithdrawal = null,
    Object? purchaseDate = freezed,
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
            accountId:
                null == accountId
                    ? _value.accountId
                    : accountId // ignore: cast_nullable_to_non_nullable
                        as String,
            stockItemId:
                null == stockItemId
                    ? _value.stockItemId
                    : stockItemId // ignore: cast_nullable_to_non_nullable
                        as String,
            quantity:
                null == quantity
                    ? _value.quantity
                    : quantity // ignore: cast_nullable_to_non_nullable
                        as double,
            currentPrice:
                null == currentPrice
                    ? _value.currentPrice
                    : currentPrice // ignore: cast_nullable_to_non_nullable
                        as double,
            balance:
                null == balance
                    ? _value.balance
                    : balance // ignore: cast_nullable_to_non_nullable
                        as double,
            principal:
                null == principal
                    ? _value.principal
                    : principal // ignore: cast_nullable_to_non_nullable
                        as double,
            totalPayout:
                null == totalPayout
                    ? _value.totalPayout
                    : totalPayout // ignore: cast_nullable_to_non_nullable
                        as double,
            totalWithdrawal:
                null == totalWithdrawal
                    ? _value.totalWithdrawal
                    : totalWithdrawal // ignore: cast_nullable_to_non_nullable
                        as double,
            purchaseDate:
                freezed == purchaseDate
                    ? _value.purchaseDate
                    : purchaseDate // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthlyStockBalanceImplCopyWith<$Res>
    implements $MonthlyStockBalanceCopyWith<$Res> {
  factory _$$MonthlyStockBalanceImplCopyWith(
    _$MonthlyStockBalanceImpl value,
    $Res Function(_$MonthlyStockBalanceImpl) then,
  ) = __$$MonthlyStockBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'year_month') String yearMonth,
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'stock_item_id') String stockItemId,
    double quantity,
    @JsonKey(name: 'current_price') double currentPrice,
    double balance,
    double principal,
    @JsonKey(name: 'total_payout') double totalPayout,
    @JsonKey(name: 'total_withdrawal') double totalWithdrawal,
    @JsonKey(name: 'purchase_date') String? purchaseDate,
  });
}

/// @nodoc
class __$$MonthlyStockBalanceImplCopyWithImpl<$Res>
    extends _$MonthlyStockBalanceCopyWithImpl<$Res, _$MonthlyStockBalanceImpl>
    implements _$$MonthlyStockBalanceImplCopyWith<$Res> {
  __$$MonthlyStockBalanceImplCopyWithImpl(
    _$MonthlyStockBalanceImpl _value,
    $Res Function(_$MonthlyStockBalanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyStockBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? yearMonth = null,
    Object? accountId = null,
    Object? stockItemId = null,
    Object? quantity = null,
    Object? currentPrice = null,
    Object? balance = null,
    Object? principal = null,
    Object? totalPayout = null,
    Object? totalWithdrawal = null,
    Object? purchaseDate = freezed,
  }) {
    return _then(
      _$MonthlyStockBalanceImpl(
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
        accountId:
            null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                    as String,
        stockItemId:
            null == stockItemId
                ? _value.stockItemId
                : stockItemId // ignore: cast_nullable_to_non_nullable
                    as String,
        quantity:
            null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                    as double,
        currentPrice:
            null == currentPrice
                ? _value.currentPrice
                : currentPrice // ignore: cast_nullable_to_non_nullable
                    as double,
        balance:
            null == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                    as double,
        principal:
            null == principal
                ? _value.principal
                : principal // ignore: cast_nullable_to_non_nullable
                    as double,
        totalPayout:
            null == totalPayout
                ? _value.totalPayout
                : totalPayout // ignore: cast_nullable_to_non_nullable
                    as double,
        totalWithdrawal:
            null == totalWithdrawal
                ? _value.totalWithdrawal
                : totalWithdrawal // ignore: cast_nullable_to_non_nullable
                    as double,
        purchaseDate:
            freezed == purchaseDate
                ? _value.purchaseDate
                : purchaseDate // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyStockBalanceImpl extends _MonthlyStockBalance {
  const _$MonthlyStockBalanceImpl({
    this.id,
    @JsonKey(name: 'year_month') required this.yearMonth,
    @JsonKey(name: 'account_id') required this.accountId,
    @JsonKey(name: 'stock_item_id') required this.stockItemId,
    this.quantity = 0.0,
    @JsonKey(name: 'current_price') this.currentPrice = 0.0,
    this.balance = 0.0,
    this.principal = 0.0,
    @JsonKey(name: 'total_payout') this.totalPayout = 0.0,
    @JsonKey(name: 'total_withdrawal') this.totalWithdrawal = 0.0,
    @JsonKey(name: 'purchase_date') this.purchaseDate,
  }) : super._();

  factory _$MonthlyStockBalanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyStockBalanceImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'year_month')
  final String yearMonth;
  @override
  @JsonKey(name: 'account_id')
  final String accountId;
  @override
  @JsonKey(name: 'stock_item_id')
  final String stockItemId;
  @override
  @JsonKey()
  final double quantity;
  // 당월 말 보유 수량
  @override
  @JsonKey(name: 'current_price')
  final double currentPrice;
  // 당월 말 현재가
  @override
  @JsonKey()
  final double balance;
  // 당월 말 평가액
  @override
  @JsonKey()
  final double principal;
  // 누적 투자 원금
  @override
  @JsonKey(name: 'total_payout')
  final double totalPayout;
  // 누적 배당금 등 수령액
  @override
  @JsonKey(name: 'total_withdrawal')
  final double totalWithdrawal;
  // 💡 누적 인출액
  @override
  @JsonKey(name: 'purchase_date')
  final String? purchaseDate;

  @override
  String toString() {
    return 'MonthlyStockBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, stockItemId: $stockItemId, quantity: $quantity, currentPrice: $currentPrice, balance: $balance, principal: $principal, totalPayout: $totalPayout, totalWithdrawal: $totalWithdrawal, purchaseDate: $purchaseDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyStockBalanceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.yearMonth, yearMonth) ||
                other.yearMonth == yearMonth) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.stockItemId, stockItemId) ||
                other.stockItemId == stockItemId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.currentPrice, currentPrice) ||
                other.currentPrice == currentPrice) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.principal, principal) ||
                other.principal == principal) &&
            (identical(other.totalPayout, totalPayout) ||
                other.totalPayout == totalPayout) &&
            (identical(other.totalWithdrawal, totalWithdrawal) ||
                other.totalWithdrawal == totalWithdrawal) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    yearMonth,
    accountId,
    stockItemId,
    quantity,
    currentPrice,
    balance,
    principal,
    totalPayout,
    totalWithdrawal,
    purchaseDate,
  );

  /// Create a copy of MonthlyStockBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyStockBalanceImplCopyWith<_$MonthlyStockBalanceImpl> get copyWith =>
      __$$MonthlyStockBalanceImplCopyWithImpl<_$MonthlyStockBalanceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyStockBalanceImplToJson(this);
  }
}

abstract class _MonthlyStockBalance extends MonthlyStockBalance {
  const factory _MonthlyStockBalance({
    final String? id,
    @JsonKey(name: 'year_month') required final String yearMonth,
    @JsonKey(name: 'account_id') required final String accountId,
    @JsonKey(name: 'stock_item_id') required final String stockItemId,
    final double quantity,
    @JsonKey(name: 'current_price') final double currentPrice,
    final double balance,
    final double principal,
    @JsonKey(name: 'total_payout') final double totalPayout,
    @JsonKey(name: 'total_withdrawal') final double totalWithdrawal,
    @JsonKey(name: 'purchase_date') final String? purchaseDate,
  }) = _$MonthlyStockBalanceImpl;
  const _MonthlyStockBalance._() : super._();

  factory _MonthlyStockBalance.fromJson(Map<String, dynamic> json) =
      _$MonthlyStockBalanceImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'year_month')
  String get yearMonth;
  @override
  @JsonKey(name: 'account_id')
  String get accountId;
  @override
  @JsonKey(name: 'stock_item_id')
  String get stockItemId;
  @override
  double get quantity; // 당월 말 보유 수량
  @override
  @JsonKey(name: 'current_price')
  double get currentPrice; // 당월 말 현재가
  @override
  double get balance; // 당월 말 평가액
  @override
  double get principal; // 누적 투자 원금
  @override
  @JsonKey(name: 'total_payout')
  double get totalPayout; // 누적 배당금 등 수령액
  @override
  @JsonKey(name: 'total_withdrawal')
  double get totalWithdrawal; // 💡 누적 인출액
  @override
  @JsonKey(name: 'purchase_date')
  String? get purchaseDate;

  /// Create a copy of MonthlyStockBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyStockBalanceImplCopyWith<_$MonthlyStockBalanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
