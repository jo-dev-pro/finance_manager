// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_pension_account_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthlyPensionAccountBalance {

 String? get id;@JsonKey(name: 'year_month') String get yearMonth;@JsonKey(name: 'account_id') String get accountId;@JsonKey(name: 'account_name') String? get accountName;// 콘솔 확인용 계좌명
@JsonKey(name: 'cash_balance') double get cashBalance;// 연금 계좌 현금성 잔액 (예수금)
// 💡 1. 원금 관련 필드 추가 (당월 납입액 및 누적 원금)
@JsonKey(name: 'principal') double get principal;// 계좌 누적 원금
@JsonKey(name: 'monthly_principal') double get monthlyPrincipal;// 계좌 당월 납입액 (추가 납입액)
@JsonKey(name: 'monthly_withdrawal') double get monthlyWithdrawal;// 당월 중도 인출금
@JsonKey(name: 'total_withdrawal') double get totalWithdrawal;
/// Create a copy of MonthlyPensionAccountBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyPensionAccountBalanceCopyWith<MonthlyPensionAccountBalance> get copyWith => _$MonthlyPensionAccountBalanceCopyWithImpl<MonthlyPensionAccountBalance>(this as MonthlyPensionAccountBalance, _$identity);

  /// Serializes this MonthlyPensionAccountBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyPensionAccountBalance&&(identical(other.id, id) || other.id == id)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.cashBalance, cashBalance) || other.cashBalance == cashBalance)&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.monthlyPrincipal, monthlyPrincipal) || other.monthlyPrincipal == monthlyPrincipal)&&(identical(other.monthlyWithdrawal, monthlyWithdrawal) || other.monthlyWithdrawal == monthlyWithdrawal)&&(identical(other.totalWithdrawal, totalWithdrawal) || other.totalWithdrawal == totalWithdrawal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,yearMonth,accountId,accountName,cashBalance,principal,monthlyPrincipal,monthlyWithdrawal,totalWithdrawal);

@override
String toString() {
  return 'MonthlyPensionAccountBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, accountName: $accountName, cashBalance: $cashBalance, principal: $principal, monthlyPrincipal: $monthlyPrincipal, monthlyWithdrawal: $monthlyWithdrawal, totalWithdrawal: $totalWithdrawal)';
}


}

/// @nodoc
abstract mixin class $MonthlyPensionAccountBalanceCopyWith<$Res>  {
  factory $MonthlyPensionAccountBalanceCopyWith(MonthlyPensionAccountBalance value, $Res Function(MonthlyPensionAccountBalance) _then) = _$MonthlyPensionAccountBalanceCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'year_month') String yearMonth,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'cash_balance') double cashBalance,@JsonKey(name: 'principal') double principal,@JsonKey(name: 'monthly_principal') double monthlyPrincipal,@JsonKey(name: 'monthly_withdrawal') double monthlyWithdrawal,@JsonKey(name: 'total_withdrawal') double totalWithdrawal
});




}
/// @nodoc
class _$MonthlyPensionAccountBalanceCopyWithImpl<$Res>
    implements $MonthlyPensionAccountBalanceCopyWith<$Res> {
  _$MonthlyPensionAccountBalanceCopyWithImpl(this._self, this._then);

  final MonthlyPensionAccountBalance _self;
  final $Res Function(MonthlyPensionAccountBalance) _then;

/// Create a copy of MonthlyPensionAccountBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? yearMonth = null,Object? accountId = null,Object? accountName = freezed,Object? cashBalance = null,Object? principal = null,Object? monthlyPrincipal = null,Object? monthlyWithdrawal = null,Object? totalWithdrawal = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,cashBalance: null == cashBalance ? _self.cashBalance : cashBalance // ignore: cast_nullable_to_non_nullable
as double,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as double,monthlyPrincipal: null == monthlyPrincipal ? _self.monthlyPrincipal : monthlyPrincipal // ignore: cast_nullable_to_non_nullable
as double,monthlyWithdrawal: null == monthlyWithdrawal ? _self.monthlyWithdrawal : monthlyWithdrawal // ignore: cast_nullable_to_non_nullable
as double,totalWithdrawal: null == totalWithdrawal ? _self.totalWithdrawal : totalWithdrawal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyPensionAccountBalance].
extension MonthlyPensionAccountBalancePatterns on MonthlyPensionAccountBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyPensionAccountBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyPensionAccountBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyPensionAccountBalance value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyPensionAccountBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyPensionAccountBalance value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyPensionAccountBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'cash_balance')  double cashBalance, @JsonKey(name: 'principal')  double principal, @JsonKey(name: 'monthly_principal')  double monthlyPrincipal, @JsonKey(name: 'monthly_withdrawal')  double monthlyWithdrawal, @JsonKey(name: 'total_withdrawal')  double totalWithdrawal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyPensionAccountBalance() when $default != null:
return $default(_that.id,_that.yearMonth,_that.accountId,_that.accountName,_that.cashBalance,_that.principal,_that.monthlyPrincipal,_that.monthlyWithdrawal,_that.totalWithdrawal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'cash_balance')  double cashBalance, @JsonKey(name: 'principal')  double principal, @JsonKey(name: 'monthly_principal')  double monthlyPrincipal, @JsonKey(name: 'monthly_withdrawal')  double monthlyWithdrawal, @JsonKey(name: 'total_withdrawal')  double totalWithdrawal)  $default,) {final _that = this;
switch (_that) {
case _MonthlyPensionAccountBalance():
return $default(_that.id,_that.yearMonth,_that.accountId,_that.accountName,_that.cashBalance,_that.principal,_that.monthlyPrincipal,_that.monthlyWithdrawal,_that.totalWithdrawal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'cash_balance')  double cashBalance, @JsonKey(name: 'principal')  double principal, @JsonKey(name: 'monthly_principal')  double monthlyPrincipal, @JsonKey(name: 'monthly_withdrawal')  double monthlyWithdrawal, @JsonKey(name: 'total_withdrawal')  double totalWithdrawal)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyPensionAccountBalance() when $default != null:
return $default(_that.id,_that.yearMonth,_that.accountId,_that.accountName,_that.cashBalance,_that.principal,_that.monthlyPrincipal,_that.monthlyWithdrawal,_that.totalWithdrawal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyPensionAccountBalance extends MonthlyPensionAccountBalance {
  const _MonthlyPensionAccountBalance({this.id, @JsonKey(name: 'year_month') required this.yearMonth, @JsonKey(name: 'account_id') required this.accountId, @JsonKey(name: 'account_name') this.accountName, @JsonKey(name: 'cash_balance') this.cashBalance = 0.0, @JsonKey(name: 'principal') this.principal = 0.0, @JsonKey(name: 'monthly_principal') this.monthlyPrincipal = 0.0, @JsonKey(name: 'monthly_withdrawal') this.monthlyWithdrawal = 0.0, @JsonKey(name: 'total_withdrawal') this.totalWithdrawal = 0.0}): super._();
  factory _MonthlyPensionAccountBalance.fromJson(Map<String, dynamic> json) => _$MonthlyPensionAccountBalanceFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'year_month') final  String yearMonth;
@override@JsonKey(name: 'account_id') final  String accountId;
@override@JsonKey(name: 'account_name') final  String? accountName;
// 콘솔 확인용 계좌명
@override@JsonKey(name: 'cash_balance') final  double cashBalance;
// 연금 계좌 현금성 잔액 (예수금)
// 💡 1. 원금 관련 필드 추가 (당월 납입액 및 누적 원금)
@override@JsonKey(name: 'principal') final  double principal;
// 계좌 누적 원금
@override@JsonKey(name: 'monthly_principal') final  double monthlyPrincipal;
// 계좌 당월 납입액 (추가 납입액)
@override@JsonKey(name: 'monthly_withdrawal') final  double monthlyWithdrawal;
// 당월 중도 인출금
@override@JsonKey(name: 'total_withdrawal') final  double totalWithdrawal;

/// Create a copy of MonthlyPensionAccountBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyPensionAccountBalanceCopyWith<_MonthlyPensionAccountBalance> get copyWith => __$MonthlyPensionAccountBalanceCopyWithImpl<_MonthlyPensionAccountBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyPensionAccountBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyPensionAccountBalance&&(identical(other.id, id) || other.id == id)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.cashBalance, cashBalance) || other.cashBalance == cashBalance)&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.monthlyPrincipal, monthlyPrincipal) || other.monthlyPrincipal == monthlyPrincipal)&&(identical(other.monthlyWithdrawal, monthlyWithdrawal) || other.monthlyWithdrawal == monthlyWithdrawal)&&(identical(other.totalWithdrawal, totalWithdrawal) || other.totalWithdrawal == totalWithdrawal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,yearMonth,accountId,accountName,cashBalance,principal,monthlyPrincipal,monthlyWithdrawal,totalWithdrawal);

@override
String toString() {
  return 'MonthlyPensionAccountBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, accountName: $accountName, cashBalance: $cashBalance, principal: $principal, monthlyPrincipal: $monthlyPrincipal, monthlyWithdrawal: $monthlyWithdrawal, totalWithdrawal: $totalWithdrawal)';
}


}

/// @nodoc
abstract mixin class _$MonthlyPensionAccountBalanceCopyWith<$Res> implements $MonthlyPensionAccountBalanceCopyWith<$Res> {
  factory _$MonthlyPensionAccountBalanceCopyWith(_MonthlyPensionAccountBalance value, $Res Function(_MonthlyPensionAccountBalance) _then) = __$MonthlyPensionAccountBalanceCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'year_month') String yearMonth,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'cash_balance') double cashBalance,@JsonKey(name: 'principal') double principal,@JsonKey(name: 'monthly_principal') double monthlyPrincipal,@JsonKey(name: 'monthly_withdrawal') double monthlyWithdrawal,@JsonKey(name: 'total_withdrawal') double totalWithdrawal
});




}
/// @nodoc
class __$MonthlyPensionAccountBalanceCopyWithImpl<$Res>
    implements _$MonthlyPensionAccountBalanceCopyWith<$Res> {
  __$MonthlyPensionAccountBalanceCopyWithImpl(this._self, this._then);

  final _MonthlyPensionAccountBalance _self;
  final $Res Function(_MonthlyPensionAccountBalance) _then;

/// Create a copy of MonthlyPensionAccountBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? yearMonth = null,Object? accountId = null,Object? accountName = freezed,Object? cashBalance = null,Object? principal = null,Object? monthlyPrincipal = null,Object? monthlyWithdrawal = null,Object? totalWithdrawal = null,}) {
  return _then(_MonthlyPensionAccountBalance(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,cashBalance: null == cashBalance ? _self.cashBalance : cashBalance // ignore: cast_nullable_to_non_nullable
as double,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as double,monthlyPrincipal: null == monthlyPrincipal ? _self.monthlyPrincipal : monthlyPrincipal // ignore: cast_nullable_to_non_nullable
as double,monthlyWithdrawal: null == monthlyWithdrawal ? _self.monthlyWithdrawal : monthlyWithdrawal // ignore: cast_nullable_to_non_nullable
as double,totalWithdrawal: null == totalWithdrawal ? _self.totalWithdrawal : totalWithdrawal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
