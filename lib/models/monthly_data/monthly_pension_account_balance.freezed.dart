// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_pension_account_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MonthlyPensionAccountBalance _$MonthlyPensionAccountBalanceFromJson(
  Map<String, dynamic> json,
) {
  return _MonthlyPensionAccountBalance.fromJson(json);
}

/// @nodoc
mixin _$MonthlyPensionAccountBalance {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'year_month')
  String get yearMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_id')
  String get accountId => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_name')
  String? get accountName => throw _privateConstructorUsedError; // 콘솔 확인용 계좌명
  @JsonKey(name: 'cash_balance')
  double get cashBalance => throw _privateConstructorUsedError; // 연금 계좌 현금성 잔액 (예수금)
  // 💡 1. 원금 관련 필드 추가 (당월 납입액 및 누적 원금)
  @JsonKey(name: 'principal')
  double get principal => throw _privateConstructorUsedError; // 계좌 누적 원금
  @JsonKey(name: 'monthly_principal')
  double get monthlyPrincipal => throw _privateConstructorUsedError; // 계좌 당월 납입액 (추가 납입액)
  @JsonKey(name: 'monthly_withdrawal')
  double get monthlyWithdrawal => throw _privateConstructorUsedError; // 당월 중도 인출금
  @JsonKey(name: 'total_withdrawal')
  double get totalWithdrawal => throw _privateConstructorUsedError;

  /// Serializes this MonthlyPensionAccountBalance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyPensionAccountBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyPensionAccountBalanceCopyWith<MonthlyPensionAccountBalance>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyPensionAccountBalanceCopyWith<$Res> {
  factory $MonthlyPensionAccountBalanceCopyWith(
    MonthlyPensionAccountBalance value,
    $Res Function(MonthlyPensionAccountBalance) then,
  ) =
      _$MonthlyPensionAccountBalanceCopyWithImpl<
        $Res,
        MonthlyPensionAccountBalance
      >;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'year_month') String yearMonth,
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'account_name') String? accountName,
    @JsonKey(name: 'cash_balance') double cashBalance,
    @JsonKey(name: 'principal') double principal,
    @JsonKey(name: 'monthly_principal') double monthlyPrincipal,
    @JsonKey(name: 'monthly_withdrawal') double monthlyWithdrawal,
    @JsonKey(name: 'total_withdrawal') double totalWithdrawal,
  });
}

/// @nodoc
class _$MonthlyPensionAccountBalanceCopyWithImpl<
  $Res,
  $Val extends MonthlyPensionAccountBalance
>
    implements $MonthlyPensionAccountBalanceCopyWith<$Res> {
  _$MonthlyPensionAccountBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyPensionAccountBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? yearMonth = null,
    Object? accountId = null,
    Object? accountName = freezed,
    Object? cashBalance = null,
    Object? principal = null,
    Object? monthlyPrincipal = null,
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
            principal:
                null == principal
                    ? _value.principal
                    : principal // ignore: cast_nullable_to_non_nullable
                        as double,
            monthlyPrincipal:
                null == monthlyPrincipal
                    ? _value.monthlyPrincipal
                    : monthlyPrincipal // ignore: cast_nullable_to_non_nullable
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
abstract class _$$MonthlyPensionAccountBalanceImplCopyWith<$Res>
    implements $MonthlyPensionAccountBalanceCopyWith<$Res> {
  factory _$$MonthlyPensionAccountBalanceImplCopyWith(
    _$MonthlyPensionAccountBalanceImpl value,
    $Res Function(_$MonthlyPensionAccountBalanceImpl) then,
  ) = __$$MonthlyPensionAccountBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'year_month') String yearMonth,
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'account_name') String? accountName,
    @JsonKey(name: 'cash_balance') double cashBalance,
    @JsonKey(name: 'principal') double principal,
    @JsonKey(name: 'monthly_principal') double monthlyPrincipal,
    @JsonKey(name: 'monthly_withdrawal') double monthlyWithdrawal,
    @JsonKey(name: 'total_withdrawal') double totalWithdrawal,
  });
}

/// @nodoc
class __$$MonthlyPensionAccountBalanceImplCopyWithImpl<$Res>
    extends
        _$MonthlyPensionAccountBalanceCopyWithImpl<
          $Res,
          _$MonthlyPensionAccountBalanceImpl
        >
    implements _$$MonthlyPensionAccountBalanceImplCopyWith<$Res> {
  __$$MonthlyPensionAccountBalanceImplCopyWithImpl(
    _$MonthlyPensionAccountBalanceImpl _value,
    $Res Function(_$MonthlyPensionAccountBalanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyPensionAccountBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? yearMonth = null,
    Object? accountId = null,
    Object? accountName = freezed,
    Object? cashBalance = null,
    Object? principal = null,
    Object? monthlyPrincipal = null,
    Object? monthlyWithdrawal = null,
    Object? totalWithdrawal = null,
  }) {
    return _then(
      _$MonthlyPensionAccountBalanceImpl(
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
        principal:
            null == principal
                ? _value.principal
                : principal // ignore: cast_nullable_to_non_nullable
                    as double,
        monthlyPrincipal:
            null == monthlyPrincipal
                ? _value.monthlyPrincipal
                : monthlyPrincipal // ignore: cast_nullable_to_non_nullable
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
class _$MonthlyPensionAccountBalanceImpl extends _MonthlyPensionAccountBalance {
  const _$MonthlyPensionAccountBalanceImpl({
    this.id,
    @JsonKey(name: 'year_month') required this.yearMonth,
    @JsonKey(name: 'account_id') required this.accountId,
    @JsonKey(name: 'account_name') this.accountName,
    @JsonKey(name: 'cash_balance') this.cashBalance = 0.0,
    @JsonKey(name: 'principal') this.principal = 0.0,
    @JsonKey(name: 'monthly_principal') this.monthlyPrincipal = 0.0,
    @JsonKey(name: 'monthly_withdrawal') this.monthlyWithdrawal = 0.0,
    @JsonKey(name: 'total_withdrawal') this.totalWithdrawal = 0.0,
  }) : super._();

  factory _$MonthlyPensionAccountBalanceImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$MonthlyPensionAccountBalanceImplFromJson(json);

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
  // 콘솔 확인용 계좌명
  @override
  @JsonKey(name: 'cash_balance')
  final double cashBalance;
  // 연금 계좌 현금성 잔액 (예수금)
  // 💡 1. 원금 관련 필드 추가 (당월 납입액 및 누적 원금)
  @override
  @JsonKey(name: 'principal')
  final double principal;
  // 계좌 누적 원금
  @override
  @JsonKey(name: 'monthly_principal')
  final double monthlyPrincipal;
  // 계좌 당월 납입액 (추가 납입액)
  @override
  @JsonKey(name: 'monthly_withdrawal')
  final double monthlyWithdrawal;
  // 당월 중도 인출금
  @override
  @JsonKey(name: 'total_withdrawal')
  final double totalWithdrawal;

  @override
  String toString() {
    return 'MonthlyPensionAccountBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, accountName: $accountName, cashBalance: $cashBalance, principal: $principal, monthlyPrincipal: $monthlyPrincipal, monthlyWithdrawal: $monthlyWithdrawal, totalWithdrawal: $totalWithdrawal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyPensionAccountBalanceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.yearMonth, yearMonth) ||
                other.yearMonth == yearMonth) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName) &&
            (identical(other.cashBalance, cashBalance) ||
                other.cashBalance == cashBalance) &&
            (identical(other.principal, principal) ||
                other.principal == principal) &&
            (identical(other.monthlyPrincipal, monthlyPrincipal) ||
                other.monthlyPrincipal == monthlyPrincipal) &&
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
    principal,
    monthlyPrincipal,
    monthlyWithdrawal,
    totalWithdrawal,
  );

  /// Create a copy of MonthlyPensionAccountBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyPensionAccountBalanceImplCopyWith<
    _$MonthlyPensionAccountBalanceImpl
  >
  get copyWith => __$$MonthlyPensionAccountBalanceImplCopyWithImpl<
    _$MonthlyPensionAccountBalanceImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyPensionAccountBalanceImplToJson(this);
  }
}

abstract class _MonthlyPensionAccountBalance
    extends MonthlyPensionAccountBalance {
  const factory _MonthlyPensionAccountBalance({
    final String? id,
    @JsonKey(name: 'year_month') required final String yearMonth,
    @JsonKey(name: 'account_id') required final String accountId,
    @JsonKey(name: 'account_name') final String? accountName,
    @JsonKey(name: 'cash_balance') final double cashBalance,
    @JsonKey(name: 'principal') final double principal,
    @JsonKey(name: 'monthly_principal') final double monthlyPrincipal,
    @JsonKey(name: 'monthly_withdrawal') final double monthlyWithdrawal,
    @JsonKey(name: 'total_withdrawal') final double totalWithdrawal,
  }) = _$MonthlyPensionAccountBalanceImpl;
  const _MonthlyPensionAccountBalance._() : super._();

  factory _MonthlyPensionAccountBalance.fromJson(Map<String, dynamic> json) =
      _$MonthlyPensionAccountBalanceImpl.fromJson;

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
  String? get accountName; // 콘솔 확인용 계좌명
  @override
  @JsonKey(name: 'cash_balance')
  double get cashBalance; // 연금 계좌 현금성 잔액 (예수금)
  // 💡 1. 원금 관련 필드 추가 (당월 납입액 및 누적 원금)
  @override
  @JsonKey(name: 'principal')
  double get principal; // 계좌 누적 원금
  @override
  @JsonKey(name: 'monthly_principal')
  double get monthlyPrincipal; // 계좌 당월 납입액 (추가 납입액)
  @override
  @JsonKey(name: 'monthly_withdrawal')
  double get monthlyWithdrawal; // 당월 중도 인출금
  @override
  @JsonKey(name: 'total_withdrawal')
  double get totalWithdrawal;

  /// Create a copy of MonthlyPensionAccountBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyPensionAccountBalanceImplCopyWith<
    _$MonthlyPensionAccountBalanceImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
