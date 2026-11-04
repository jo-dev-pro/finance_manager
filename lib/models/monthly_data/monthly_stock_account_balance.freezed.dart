// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_stock_account_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MonthlyStockAccountBalance _$MonthlyStockAccountBalanceFromJson(
  Map<String, dynamic> json,
) {
  return _MonthlyStockAccountBalance.fromJson(json);
}

/// @nodoc
mixin _$MonthlyStockAccountBalance {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'year_month')
  String get yearMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_id')
  String get accountId => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_name')
  String? get accountName => throw _privateConstructorUsedError;
  @JsonKey(name: 'cash_balance')
  double get cashBalance => throw _privateConstructorUsedError; // 계좌 현금성 잔액(예수금)
  @JsonKey(name: 'monthly_withdrawal')
  double get monthlyWithdrawal => throw _privateConstructorUsedError; // 💡 당월 인출액
  @JsonKey(name: 'total_withdrawal')
  double get totalWithdrawal => throw _privateConstructorUsedError;

  /// Serializes this MonthlyStockAccountBalance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyStockAccountBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyStockAccountBalanceCopyWith<MonthlyStockAccountBalance>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyStockAccountBalanceCopyWith<$Res> {
  factory $MonthlyStockAccountBalanceCopyWith(
    MonthlyStockAccountBalance value,
    $Res Function(MonthlyStockAccountBalance) then,
  ) =
      _$MonthlyStockAccountBalanceCopyWithImpl<
        $Res,
        MonthlyStockAccountBalance
      >;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'year_month') String yearMonth,
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'account_name') String? accountName,
    @JsonKey(name: 'cash_balance') double cashBalance,
    @JsonKey(name: 'monthly_withdrawal') double monthlyWithdrawal,
    @JsonKey(name: 'total_withdrawal') double totalWithdrawal,
  });
}

/// @nodoc
class _$MonthlyStockAccountBalanceCopyWithImpl<
  $Res,
  $Val extends MonthlyStockAccountBalance
>
    implements $MonthlyStockAccountBalanceCopyWith<$Res> {
  _$MonthlyStockAccountBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyStockAccountBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? yearMonth = null,
    Object? accountId = null,
    Object? accountName = freezed,
    Object? cashBalance = null,
    Object? monthlyWithdrawal = null,
    Object? totalWithdrawal = null,
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
            accountName:
                freezed == accountName
                    ? _value.accountName
                    : accountName // ignore: cast_nullable_to_non_nullable
                        as String?,
            cashBalance:
                null == cashBalance
                    ? _value.cashBalance
                    : cashBalance // ignore: cast_nullable_to_non_nullable
                        as double,
            monthlyWithdrawal:
                null == monthlyWithdrawal
                    ? _value.monthlyWithdrawal
                    : monthlyWithdrawal // ignore: cast_nullable_to_non_nullable
                        as double,
            totalWithdrawal:
                null == totalWithdrawal
                    ? _value.totalWithdrawal
                    : totalWithdrawal // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthlyStockAccountBalanceImplCopyWith<$Res>
    implements $MonthlyStockAccountBalanceCopyWith<$Res> {
  factory _$$MonthlyStockAccountBalanceImplCopyWith(
    _$MonthlyStockAccountBalanceImpl value,
    $Res Function(_$MonthlyStockAccountBalanceImpl) then,
  ) = __$$MonthlyStockAccountBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'year_month') String yearMonth,
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'account_name') String? accountName,
    @JsonKey(name: 'cash_balance') double cashBalance,
    @JsonKey(name: 'monthly_withdrawal') double monthlyWithdrawal,
    @JsonKey(name: 'total_withdrawal') double totalWithdrawal,
  });
}

/// @nodoc
class __$$MonthlyStockAccountBalanceImplCopyWithImpl<$Res>
    extends
        _$MonthlyStockAccountBalanceCopyWithImpl<
          $Res,
          _$MonthlyStockAccountBalanceImpl
        >
    implements _$$MonthlyStockAccountBalanceImplCopyWith<$Res> {
  __$$MonthlyStockAccountBalanceImplCopyWithImpl(
    _$MonthlyStockAccountBalanceImpl _value,
    $Res Function(_$MonthlyStockAccountBalanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyStockAccountBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? yearMonth = null,
    Object? accountId = null,
    Object? accountName = freezed,
    Object? cashBalance = null,
    Object? monthlyWithdrawal = null,
    Object? totalWithdrawal = null,
  }) {
    return _then(
      _$MonthlyStockAccountBalanceImpl(
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
        accountName:
            freezed == accountName
                ? _value.accountName
                : accountName // ignore: cast_nullable_to_non_nullable
                    as String?,
        cashBalance:
            null == cashBalance
                ? _value.cashBalance
                : cashBalance // ignore: cast_nullable_to_non_nullable
                    as double,
        monthlyWithdrawal:
            null == monthlyWithdrawal
                ? _value.monthlyWithdrawal
                : monthlyWithdrawal // ignore: cast_nullable_to_non_nullable
                    as double,
        totalWithdrawal:
            null == totalWithdrawal
                ? _value.totalWithdrawal
                : totalWithdrawal // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyStockAccountBalanceImpl extends _MonthlyStockAccountBalance {
  const _$MonthlyStockAccountBalanceImpl({
    this.id,
    @JsonKey(name: 'year_month') required this.yearMonth,
    @JsonKey(name: 'account_id') required this.accountId,
    @JsonKey(name: 'account_name') this.accountName,
    @JsonKey(name: 'cash_balance') this.cashBalance = 0.0,
    @JsonKey(name: 'monthly_withdrawal') this.monthlyWithdrawal = 0.0,
    @JsonKey(name: 'total_withdrawal') this.totalWithdrawal = 0.0,
  }) : super._();

  factory _$MonthlyStockAccountBalanceImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$MonthlyStockAccountBalanceImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'year_month')
  final String yearMonth;
  @override
  @JsonKey(name: 'account_id')
  final String accountId;
  @override
  @JsonKey(name: 'account_name')
  final String? accountName;
  @override
  @JsonKey(name: 'cash_balance')
  final double cashBalance;
  // 계좌 현금성 잔액(예수금)
  @override
  @JsonKey(name: 'monthly_withdrawal')
  final double monthlyWithdrawal;
  // 💡 당월 인출액
  @override
  @JsonKey(name: 'total_withdrawal')
  final double totalWithdrawal;

  @override
  String toString() {
    return 'MonthlyStockAccountBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, accountName: $accountName, cashBalance: $cashBalance, monthlyWithdrawal: $monthlyWithdrawal, totalWithdrawal: $totalWithdrawal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyStockAccountBalanceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.yearMonth, yearMonth) ||
                other.yearMonth == yearMonth) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName) &&
            (identical(other.cashBalance, cashBalance) ||
                other.cashBalance == cashBalance) &&
            (identical(other.monthlyWithdrawal, monthlyWithdrawal) ||
                other.monthlyWithdrawal == monthlyWithdrawal) &&
            (identical(other.totalWithdrawal, totalWithdrawal) ||
                other.totalWithdrawal == totalWithdrawal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    yearMonth,
    accountId,
    accountName,
    cashBalance,
    monthlyWithdrawal,
    totalWithdrawal,
  );

  /// Create a copy of MonthlyStockAccountBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyStockAccountBalanceImplCopyWith<_$MonthlyStockAccountBalanceImpl>
  get copyWith => __$$MonthlyStockAccountBalanceImplCopyWithImpl<
    _$MonthlyStockAccountBalanceImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyStockAccountBalanceImplToJson(this);
  }
}

abstract class _MonthlyStockAccountBalance extends MonthlyStockAccountBalance {
  const factory _MonthlyStockAccountBalance({
    final String? id,
    @JsonKey(name: 'year_month') required final String yearMonth,
    @JsonKey(name: 'account_id') required final String accountId,
    @JsonKey(name: 'account_name') final String? accountName,
    @JsonKey(name: 'cash_balance') final double cashBalance,
    @JsonKey(name: 'monthly_withdrawal') final double monthlyWithdrawal,
    @JsonKey(name: 'total_withdrawal') final double totalWithdrawal,
  }) = _$MonthlyStockAccountBalanceImpl;
  const _MonthlyStockAccountBalance._() : super._();

  factory _MonthlyStockAccountBalance.fromJson(Map<String, dynamic> json) =
      _$MonthlyStockAccountBalanceImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'year_month')
  String get yearMonth;
  @override
  @JsonKey(name: 'account_id')
  String get accountId;
  @override
  @JsonKey(name: 'account_name')
  String? get accountName;
  @override
  @JsonKey(name: 'cash_balance')
  double get cashBalance; // 계좌 현금성 잔액(예수금)
  @override
  @JsonKey(name: 'monthly_withdrawal')
  double get monthlyWithdrawal; // 💡 당월 인출액
  @override
  @JsonKey(name: 'total_withdrawal')
  double get totalWithdrawal;

  /// Create a copy of MonthlyStockAccountBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyStockAccountBalanceImplCopyWith<_$MonthlyStockAccountBalanceImpl>
  get copyWith => throw _privateConstructorUsedError;
}
