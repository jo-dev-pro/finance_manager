// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_stock_account_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthlyStockAccountBalance {

 String? get id;@JsonKey(name: 'year_month') String get yearMonth;@JsonKey(name: 'account_id') String get accountId;@JsonKey(name: 'account_name') String? get accountName;@JsonKey(name: 'cash_balance') double get cashBalance;// 계좌 현금성 잔액(예수금)
// 💡 신규 추가: 당월 말일 적용 환율 (예: 1350.50, 원화계좌는 기본값 1.0)
@JsonKey(name: 'exchange_rate') double get exchangeRate;// 1. 계좌 입금액 / 추가원금 (누적 및 당월분)
 double get principal;// 누적 계좌 입금액 (원금)
@JsonKey(name: 'monthly_principal') double get monthlyPrincipal;// 당월 계좌 입금액
// 2. 계좌 인출액 (누적 및 당월분)
@JsonKey(name: 'total_withdrawal') double get totalWithdrawal;// 누적 계좌 인출액
@JsonKey(name: 'monthly_withdrawal') double get monthlyWithdrawal;
/// Create a copy of MonthlyStockAccountBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyStockAccountBalanceCopyWith<MonthlyStockAccountBalance> get copyWith => _$MonthlyStockAccountBalanceCopyWithImpl<MonthlyStockAccountBalance>(this as MonthlyStockAccountBalance, _$identity);

  /// Serializes this MonthlyStockAccountBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyStockAccountBalance&&(identical(other.id, id) || other.id == id)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.cashBalance, cashBalance) || other.cashBalance == cashBalance)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.monthlyPrincipal, monthlyPrincipal) || other.monthlyPrincipal == monthlyPrincipal)&&(identical(other.totalWithdrawal, totalWithdrawal) || other.totalWithdrawal == totalWithdrawal)&&(identical(other.monthlyWithdrawal, monthlyWithdrawal) || other.monthlyWithdrawal == monthlyWithdrawal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,yearMonth,accountId,accountName,cashBalance,exchangeRate,principal,monthlyPrincipal,totalWithdrawal,monthlyWithdrawal);

@override
String toString() {
  return 'MonthlyStockAccountBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, accountName: $accountName, cashBalance: $cashBalance, exchangeRate: $exchangeRate, principal: $principal, monthlyPrincipal: $monthlyPrincipal, totalWithdrawal: $totalWithdrawal, monthlyWithdrawal: $monthlyWithdrawal)';
}


}

/// @nodoc
abstract mixin class $MonthlyStockAccountBalanceCopyWith<$Res>  {
  factory $MonthlyStockAccountBalanceCopyWith(MonthlyStockAccountBalance value, $Res Function(MonthlyStockAccountBalance) _then) = _$MonthlyStockAccountBalanceCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'year_month') String yearMonth,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'cash_balance') double cashBalance,@JsonKey(name: 'exchange_rate') double exchangeRate, double principal,@JsonKey(name: 'monthly_principal') double monthlyPrincipal,@JsonKey(name: 'total_withdrawal') double totalWithdrawal,@JsonKey(name: 'monthly_withdrawal') double monthlyWithdrawal
});




}
/// @nodoc
class _$MonthlyStockAccountBalanceCopyWithImpl<$Res>
    implements $MonthlyStockAccountBalanceCopyWith<$Res> {
  _$MonthlyStockAccountBalanceCopyWithImpl(this._self, this._then);

  final MonthlyStockAccountBalance _self;
  final $Res Function(MonthlyStockAccountBalance) _then;

/// Create a copy of MonthlyStockAccountBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? yearMonth = null,Object? accountId = null,Object? accountName = freezed,Object? cashBalance = null,Object? exchangeRate = null,Object? principal = null,Object? monthlyPrincipal = null,Object? totalWithdrawal = null,Object? monthlyWithdrawal = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,cashBalance: null == cashBalance ? _self.cashBalance : cashBalance // ignore: cast_nullable_to_non_nullable
as double,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as double,monthlyPrincipal: null == monthlyPrincipal ? _self.monthlyPrincipal : monthlyPrincipal // ignore: cast_nullable_to_non_nullable
as double,totalWithdrawal: null == totalWithdrawal ? _self.totalWithdrawal : totalWithdrawal // ignore: cast_nullable_to_non_nullable
as double,monthlyWithdrawal: null == monthlyWithdrawal ? _self.monthlyWithdrawal : monthlyWithdrawal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyStockAccountBalance].
extension MonthlyStockAccountBalancePatterns on MonthlyStockAccountBalance {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyStockAccountBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyStockAccountBalance() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyStockAccountBalance value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyStockAccountBalance():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyStockAccountBalance value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyStockAccountBalance() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'cash_balance')  double cashBalance, @JsonKey(name: 'exchange_rate')  double exchangeRate,  double principal, @JsonKey(name: 'monthly_principal')  double monthlyPrincipal, @JsonKey(name: 'total_withdrawal')  double totalWithdrawal, @JsonKey(name: 'monthly_withdrawal')  double monthlyWithdrawal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyStockAccountBalance() when $default != null:
return $default(_that.id,_that.yearMonth,_that.accountId,_that.accountName,_that.cashBalance,_that.exchangeRate,_that.principal,_that.monthlyPrincipal,_that.totalWithdrawal,_that.monthlyWithdrawal);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'cash_balance')  double cashBalance, @JsonKey(name: 'exchange_rate')  double exchangeRate,  double principal, @JsonKey(name: 'monthly_principal')  double monthlyPrincipal, @JsonKey(name: 'total_withdrawal')  double totalWithdrawal, @JsonKey(name: 'monthly_withdrawal')  double monthlyWithdrawal)  $default,) {final _that = this;
switch (_that) {
case _MonthlyStockAccountBalance():
return $default(_that.id,_that.yearMonth,_that.accountId,_that.accountName,_that.cashBalance,_that.exchangeRate,_that.principal,_that.monthlyPrincipal,_that.totalWithdrawal,_that.monthlyWithdrawal);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'cash_balance')  double cashBalance, @JsonKey(name: 'exchange_rate')  double exchangeRate,  double principal, @JsonKey(name: 'monthly_principal')  double monthlyPrincipal, @JsonKey(name: 'total_withdrawal')  double totalWithdrawal, @JsonKey(name: 'monthly_withdrawal')  double monthlyWithdrawal)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyStockAccountBalance() when $default != null:
return $default(_that.id,_that.yearMonth,_that.accountId,_that.accountName,_that.cashBalance,_that.exchangeRate,_that.principal,_that.monthlyPrincipal,_that.totalWithdrawal,_that.monthlyWithdrawal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyStockAccountBalance extends MonthlyStockAccountBalance {
  const _MonthlyStockAccountBalance({this.id, @JsonKey(name: 'year_month') required this.yearMonth, @JsonKey(name: 'account_id') required this.accountId, @JsonKey(name: 'account_name') this.accountName, @JsonKey(name: 'cash_balance') this.cashBalance = 0.0, @JsonKey(name: 'exchange_rate') this.exchangeRate = 1.0, this.principal = 0.0, @JsonKey(name: 'monthly_principal') this.monthlyPrincipal = 0.0, @JsonKey(name: 'total_withdrawal') this.totalWithdrawal = 0.0, @JsonKey(name: 'monthly_withdrawal') this.monthlyWithdrawal = 0.0}): super._();
  factory _MonthlyStockAccountBalance.fromJson(Map<String, dynamic> json) => _$MonthlyStockAccountBalanceFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'year_month') final  String yearMonth;
@override@JsonKey(name: 'account_id') final  String accountId;
@override@JsonKey(name: 'account_name') final  String? accountName;
@override@JsonKey(name: 'cash_balance') final  double cashBalance;
// 계좌 현금성 잔액(예수금)
// 💡 신규 추가: 당월 말일 적용 환율 (예: 1350.50, 원화계좌는 기본값 1.0)
@override@JsonKey(name: 'exchange_rate') final  double exchangeRate;
// 1. 계좌 입금액 / 추가원금 (누적 및 당월분)
@override@JsonKey() final  double principal;
// 누적 계좌 입금액 (원금)
@override@JsonKey(name: 'monthly_principal') final  double monthlyPrincipal;
// 당월 계좌 입금액
// 2. 계좌 인출액 (누적 및 당월분)
@override@JsonKey(name: 'total_withdrawal') final  double totalWithdrawal;
// 누적 계좌 인출액
@override@JsonKey(name: 'monthly_withdrawal') final  double monthlyWithdrawal;

/// Create a copy of MonthlyStockAccountBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyStockAccountBalanceCopyWith<_MonthlyStockAccountBalance> get copyWith => __$MonthlyStockAccountBalanceCopyWithImpl<_MonthlyStockAccountBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyStockAccountBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyStockAccountBalance&&(identical(other.id, id) || other.id == id)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.cashBalance, cashBalance) || other.cashBalance == cashBalance)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.monthlyPrincipal, monthlyPrincipal) || other.monthlyPrincipal == monthlyPrincipal)&&(identical(other.totalWithdrawal, totalWithdrawal) || other.totalWithdrawal == totalWithdrawal)&&(identical(other.monthlyWithdrawal, monthlyWithdrawal) || other.monthlyWithdrawal == monthlyWithdrawal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,yearMonth,accountId,accountName,cashBalance,exchangeRate,principal,monthlyPrincipal,totalWithdrawal,monthlyWithdrawal);

@override
String toString() {
  return 'MonthlyStockAccountBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, accountName: $accountName, cashBalance: $cashBalance, exchangeRate: $exchangeRate, principal: $principal, monthlyPrincipal: $monthlyPrincipal, totalWithdrawal: $totalWithdrawal, monthlyWithdrawal: $monthlyWithdrawal)';
}


}

/// @nodoc
abstract mixin class _$MonthlyStockAccountBalanceCopyWith<$Res> implements $MonthlyStockAccountBalanceCopyWith<$Res> {
  factory _$MonthlyStockAccountBalanceCopyWith(_MonthlyStockAccountBalance value, $Res Function(_MonthlyStockAccountBalance) _then) = __$MonthlyStockAccountBalanceCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'year_month') String yearMonth,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'cash_balance') double cashBalance,@JsonKey(name: 'exchange_rate') double exchangeRate, double principal,@JsonKey(name: 'monthly_principal') double monthlyPrincipal,@JsonKey(name: 'total_withdrawal') double totalWithdrawal,@JsonKey(name: 'monthly_withdrawal') double monthlyWithdrawal
});




}
/// @nodoc
class __$MonthlyStockAccountBalanceCopyWithImpl<$Res>
    implements _$MonthlyStockAccountBalanceCopyWith<$Res> {
  __$MonthlyStockAccountBalanceCopyWithImpl(this._self, this._then);

  final _MonthlyStockAccountBalance _self;
  final $Res Function(_MonthlyStockAccountBalance) _then;

/// Create a copy of MonthlyStockAccountBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? yearMonth = null,Object? accountId = null,Object? accountName = freezed,Object? cashBalance = null,Object? exchangeRate = null,Object? principal = null,Object? monthlyPrincipal = null,Object? totalWithdrawal = null,Object? monthlyWithdrawal = null,}) {
  return _then(_MonthlyStockAccountBalance(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,cashBalance: null == cashBalance ? _self.cashBalance : cashBalance // ignore: cast_nullable_to_non_nullable
as double,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as double,monthlyPrincipal: null == monthlyPrincipal ? _self.monthlyPrincipal : monthlyPrincipal // ignore: cast_nullable_to_non_nullable
as double,totalWithdrawal: null == totalWithdrawal ? _self.totalWithdrawal : totalWithdrawal // ignore: cast_nullable_to_non_nullable
as double,monthlyWithdrawal: null == monthlyWithdrawal ? _self.monthlyWithdrawal : monthlyWithdrawal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
