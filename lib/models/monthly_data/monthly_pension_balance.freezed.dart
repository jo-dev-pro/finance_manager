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
  @JsonKey(name: 'account_id')
  String get accountId => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String get productId => throw _privateConstructorUsedError;
  double get balance => throw _privateConstructorUsedError; // 당월 말 평가액
  double get principal => throw _privateConstructorUsedError; // 누적 투자 원금
  @JsonKey(name: 'total_payout')
  double get totalPayout => throw _privateConstructorUsedError; // 누적 연금 수령액
  @JsonKey(name: 'total_withdrawal')
  double get totalWithdrawal => throw _privateConstructorUsedError; // 누적 중도 인출금
  @JsonKey(name: 'purchase_date')
  String? get purchaseDate => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'product_id') String productId,
    double balance,
    double principal,
    @JsonKey(name: 'total_payout') double totalPayout,
    @JsonKey(name: 'total_withdrawal') double totalWithdrawal,
    @JsonKey(name: 'purchase_date') String? purchaseDate,
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
    Object? accountId = null,
    Object? productId = null,
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
            productId:
                null == productId
                    ? _value.productId
                    : productId // ignore: cast_nullable_to_non_nullable
                        as String,
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
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'product_id') String productId,
    double balance,
    double principal,
    @JsonKey(name: 'total_payout') double totalPayout,
    @JsonKey(name: 'total_withdrawal') double totalWithdrawal,
    @JsonKey(name: 'purchase_date') String? purchaseDate,
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
    Object? accountId = null,
    Object? productId = null,
    Object? balance = null,
    Object? principal = null,
    Object? totalPayout = null,
    Object? totalWithdrawal = null,
    Object? purchaseDate = freezed,
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
        accountId:
            null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                    as String,
        productId:
            null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                    as String,
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
class _$MonthlyPensionBalanceImpl extends _MonthlyPensionBalance {
  const _$MonthlyPensionBalanceImpl({
    this.id,
    @JsonKey(name: 'year_month') required this.yearMonth,
    @JsonKey(name: 'account_id') required this.accountId,
    @JsonKey(name: 'product_id') required this.productId,
    this.balance = 0.0,
    this.principal = 0.0,
    @JsonKey(name: 'total_payout') this.totalPayout = 0.0,
    @JsonKey(name: 'total_withdrawal') this.totalWithdrawal = 0.0,
    @JsonKey(name: 'purchase_date') this.purchaseDate,
  }) : super._();

  factory _$MonthlyPensionBalanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyPensionBalanceImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'year_month')
  final String yearMonth;
  @override
  @JsonKey(name: 'account_id')
  final String accountId;
  @override
  @JsonKey(name: 'product_id')
  final String productId;
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
  // 누적 연금 수령액
  @override
  @JsonKey(name: 'total_withdrawal')
  final double totalWithdrawal;
  // 누적 중도 인출금
  @override
  @JsonKey(name: 'purchase_date')
  final String? purchaseDate;

  @override
  String toString() {
    return 'MonthlyPensionBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, productId: $productId, balance: $balance, principal: $principal, totalPayout: $totalPayout, totalWithdrawal: $totalWithdrawal, purchaseDate: $purchaseDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyPensionBalanceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.yearMonth, yearMonth) ||
                other.yearMonth == yearMonth) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
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
    productId,
    balance,
    principal,
    totalPayout,
    totalWithdrawal,
    purchaseDate,
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

abstract class _MonthlyPensionBalance extends MonthlyPensionBalance {
  const factory _MonthlyPensionBalance({
    final String? id,
    @JsonKey(name: 'year_month') required final String yearMonth,
    @JsonKey(name: 'account_id') required final String accountId,
    @JsonKey(name: 'product_id') required final String productId,
    final double balance,
    final double principal,
    @JsonKey(name: 'total_payout') final double totalPayout,
    @JsonKey(name: 'total_withdrawal') final double totalWithdrawal,
    @JsonKey(name: 'purchase_date') final String? purchaseDate,
  }) = _$MonthlyPensionBalanceImpl;
  const _MonthlyPensionBalance._() : super._();

  factory _MonthlyPensionBalance.fromJson(Map<String, dynamic> json) =
      _$MonthlyPensionBalanceImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'year_month')
  String get yearMonth;
  @override
  @JsonKey(name: 'account_id')
  String get accountId;
  @override
  @JsonKey(name: 'product_id')
  String get productId;
  @override
  double get balance; // 당월 말 평가액
  @override
  double get principal; // 누적 투자 원금
  @override
  @JsonKey(name: 'total_payout')
  double get totalPayout; // 누적 연금 수령액
  @override
  @JsonKey(name: 'total_withdrawal')
  double get totalWithdrawal; // 누적 중도 인출금
  @override
  @JsonKey(name: 'purchase_date')
  String? get purchaseDate;

  /// Create a copy of MonthlyPensionBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyPensionBalanceImplCopyWith<_$MonthlyPensionBalanceImpl>
  get copyWith => throw _privateConstructorUsedError;
}
