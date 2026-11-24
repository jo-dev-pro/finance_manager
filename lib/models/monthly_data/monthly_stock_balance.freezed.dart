// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_stock_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthlyStockBalance {

 String? get id;@JsonKey(name: 'year_month') String get yearMonth;@JsonKey(name: 'account_id') String get accountId;@JsonKey(name: 'stock_item_id') String get stockItemId;@JsonKey(name: 'account_name') String? get accountName;// 💡 콘솔 확인용 계좌명 추가
@JsonKey(name: 'stock_item_name') String? get stockItemName;// 💡 콘솔 확인용 주식 종목명 추가
 double get quantity;// 당월 말 보유 수량
@JsonKey(name: 'current_price') double get currentPrice;// 당월 말 현재가
 double get balance;// 당월 말 평가액 (quantity * currentPrice)
// 1. 투자 원금 (누적 및 당월분)
 double get principal;// 누적 투자 원금
@JsonKey(name: 'monthly_principal') double get monthlyPrincipal;// 당월 추가 매수/입금 원금
// 2. 배당금 및 기타 수령액 (누적 및 당월분)
@JsonKey(name: 'total_payout') double get totalPayout;// 누적 배당금/수령액
@JsonKey(name: 'monthly_payout') double get monthlyPayout;// 당월 배당금/수령액
// 3. 매도 및 인출액 (누적 및 당월분)
@JsonKey(name: 'total_withdrawal') double get totalWithdrawal;// 누적 매도/인출액
@JsonKey(name: 'monthly_withdrawal') double get monthlyWithdrawal;// 당월 매도/인출액
@JsonKey(name: 'purchase_date') String? get purchaseDate;
/// Create a copy of MonthlyStockBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyStockBalanceCopyWith<MonthlyStockBalance> get copyWith => _$MonthlyStockBalanceCopyWithImpl<MonthlyStockBalance>(this as MonthlyStockBalance, _$identity);

  /// Serializes this MonthlyStockBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyStockBalance&&(identical(other.id, id) || other.id == id)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.stockItemId, stockItemId) || other.stockItemId == stockItemId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.stockItemName, stockItemName) || other.stockItemName == stockItemName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.monthlyPrincipal, monthlyPrincipal) || other.monthlyPrincipal == monthlyPrincipal)&&(identical(other.totalPayout, totalPayout) || other.totalPayout == totalPayout)&&(identical(other.monthlyPayout, monthlyPayout) || other.monthlyPayout == monthlyPayout)&&(identical(other.totalWithdrawal, totalWithdrawal) || other.totalWithdrawal == totalWithdrawal)&&(identical(other.monthlyWithdrawal, monthlyWithdrawal) || other.monthlyWithdrawal == monthlyWithdrawal)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,yearMonth,accountId,stockItemId,accountName,stockItemName,quantity,currentPrice,balance,principal,monthlyPrincipal,totalPayout,monthlyPayout,totalWithdrawal,monthlyWithdrawal,purchaseDate);

@override
String toString() {
  return 'MonthlyStockBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, stockItemId: $stockItemId, accountName: $accountName, stockItemName: $stockItemName, quantity: $quantity, currentPrice: $currentPrice, balance: $balance, principal: $principal, monthlyPrincipal: $monthlyPrincipal, totalPayout: $totalPayout, monthlyPayout: $monthlyPayout, totalWithdrawal: $totalWithdrawal, monthlyWithdrawal: $monthlyWithdrawal, purchaseDate: $purchaseDate)';
}


}

/// @nodoc
abstract mixin class $MonthlyStockBalanceCopyWith<$Res>  {
  factory $MonthlyStockBalanceCopyWith(MonthlyStockBalance value, $Res Function(MonthlyStockBalance) _then) = _$MonthlyStockBalanceCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'year_month') String yearMonth,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'stock_item_id') String stockItemId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'stock_item_name') String? stockItemName, double quantity,@JsonKey(name: 'current_price') double currentPrice, double balance, double principal,@JsonKey(name: 'monthly_principal') double monthlyPrincipal,@JsonKey(name: 'total_payout') double totalPayout,@JsonKey(name: 'monthly_payout') double monthlyPayout,@JsonKey(name: 'total_withdrawal') double totalWithdrawal,@JsonKey(name: 'monthly_withdrawal') double monthlyWithdrawal,@JsonKey(name: 'purchase_date') String? purchaseDate
});




}
/// @nodoc
class _$MonthlyStockBalanceCopyWithImpl<$Res>
    implements $MonthlyStockBalanceCopyWith<$Res> {
  _$MonthlyStockBalanceCopyWithImpl(this._self, this._then);

  final MonthlyStockBalance _self;
  final $Res Function(MonthlyStockBalance) _then;

/// Create a copy of MonthlyStockBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? yearMonth = null,Object? accountId = null,Object? stockItemId = null,Object? accountName = freezed,Object? stockItemName = freezed,Object? quantity = null,Object? currentPrice = null,Object? balance = null,Object? principal = null,Object? monthlyPrincipal = null,Object? totalPayout = null,Object? monthlyPayout = null,Object? totalWithdrawal = null,Object? monthlyWithdrawal = null,Object? purchaseDate = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,stockItemId: null == stockItemId ? _self.stockItemId : stockItemId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,stockItemName: freezed == stockItemName ? _self.stockItemName : stockItemName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as double,monthlyPrincipal: null == monthlyPrincipal ? _self.monthlyPrincipal : monthlyPrincipal // ignore: cast_nullable_to_non_nullable
as double,totalPayout: null == totalPayout ? _self.totalPayout : totalPayout // ignore: cast_nullable_to_non_nullable
as double,monthlyPayout: null == monthlyPayout ? _self.monthlyPayout : monthlyPayout // ignore: cast_nullable_to_non_nullable
as double,totalWithdrawal: null == totalWithdrawal ? _self.totalWithdrawal : totalWithdrawal // ignore: cast_nullable_to_non_nullable
as double,monthlyWithdrawal: null == monthlyWithdrawal ? _self.monthlyWithdrawal : monthlyWithdrawal // ignore: cast_nullable_to_non_nullable
as double,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyStockBalance].
extension MonthlyStockBalancePatterns on MonthlyStockBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyStockBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyStockBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyStockBalance value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyStockBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyStockBalance value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyStockBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'stock_item_id')  String stockItemId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'stock_item_name')  String? stockItemName,  double quantity, @JsonKey(name: 'current_price')  double currentPrice,  double balance,  double principal, @JsonKey(name: 'monthly_principal')  double monthlyPrincipal, @JsonKey(name: 'total_payout')  double totalPayout, @JsonKey(name: 'monthly_payout')  double monthlyPayout, @JsonKey(name: 'total_withdrawal')  double totalWithdrawal, @JsonKey(name: 'monthly_withdrawal')  double monthlyWithdrawal, @JsonKey(name: 'purchase_date')  String? purchaseDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyStockBalance() when $default != null:
return $default(_that.id,_that.yearMonth,_that.accountId,_that.stockItemId,_that.accountName,_that.stockItemName,_that.quantity,_that.currentPrice,_that.balance,_that.principal,_that.monthlyPrincipal,_that.totalPayout,_that.monthlyPayout,_that.totalWithdrawal,_that.monthlyWithdrawal,_that.purchaseDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'stock_item_id')  String stockItemId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'stock_item_name')  String? stockItemName,  double quantity, @JsonKey(name: 'current_price')  double currentPrice,  double balance,  double principal, @JsonKey(name: 'monthly_principal')  double monthlyPrincipal, @JsonKey(name: 'total_payout')  double totalPayout, @JsonKey(name: 'monthly_payout')  double monthlyPayout, @JsonKey(name: 'total_withdrawal')  double totalWithdrawal, @JsonKey(name: 'monthly_withdrawal')  double monthlyWithdrawal, @JsonKey(name: 'purchase_date')  String? purchaseDate)  $default,) {final _that = this;
switch (_that) {
case _MonthlyStockBalance():
return $default(_that.id,_that.yearMonth,_that.accountId,_that.stockItemId,_that.accountName,_that.stockItemName,_that.quantity,_that.currentPrice,_that.balance,_that.principal,_that.monthlyPrincipal,_that.totalPayout,_that.monthlyPayout,_that.totalWithdrawal,_that.monthlyWithdrawal,_that.purchaseDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'stock_item_id')  String stockItemId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'stock_item_name')  String? stockItemName,  double quantity, @JsonKey(name: 'current_price')  double currentPrice,  double balance,  double principal, @JsonKey(name: 'monthly_principal')  double monthlyPrincipal, @JsonKey(name: 'total_payout')  double totalPayout, @JsonKey(name: 'monthly_payout')  double monthlyPayout, @JsonKey(name: 'total_withdrawal')  double totalWithdrawal, @JsonKey(name: 'monthly_withdrawal')  double monthlyWithdrawal, @JsonKey(name: 'purchase_date')  String? purchaseDate)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyStockBalance() when $default != null:
return $default(_that.id,_that.yearMonth,_that.accountId,_that.stockItemId,_that.accountName,_that.stockItemName,_that.quantity,_that.currentPrice,_that.balance,_that.principal,_that.monthlyPrincipal,_that.totalPayout,_that.monthlyPayout,_that.totalWithdrawal,_that.monthlyWithdrawal,_that.purchaseDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyStockBalance extends MonthlyStockBalance {
  const _MonthlyStockBalance({this.id, @JsonKey(name: 'year_month') required this.yearMonth, @JsonKey(name: 'account_id') required this.accountId, @JsonKey(name: 'stock_item_id') required this.stockItemId, @JsonKey(name: 'account_name') this.accountName, @JsonKey(name: 'stock_item_name') this.stockItemName, this.quantity = 0.0, @JsonKey(name: 'current_price') this.currentPrice = 0.0, this.balance = 0.0, this.principal = 0.0, @JsonKey(name: 'monthly_principal') this.monthlyPrincipal = 0.0, @JsonKey(name: 'total_payout') this.totalPayout = 0.0, @JsonKey(name: 'monthly_payout') this.monthlyPayout = 0.0, @JsonKey(name: 'total_withdrawal') this.totalWithdrawal = 0.0, @JsonKey(name: 'monthly_withdrawal') this.monthlyWithdrawal = 0.0, @JsonKey(name: 'purchase_date') this.purchaseDate}): super._();
  factory _MonthlyStockBalance.fromJson(Map<String, dynamic> json) => _$MonthlyStockBalanceFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'year_month') final  String yearMonth;
@override@JsonKey(name: 'account_id') final  String accountId;
@override@JsonKey(name: 'stock_item_id') final  String stockItemId;
@override@JsonKey(name: 'account_name') final  String? accountName;
// 💡 콘솔 확인용 계좌명 추가
@override@JsonKey(name: 'stock_item_name') final  String? stockItemName;
// 💡 콘솔 확인용 주식 종목명 추가
@override@JsonKey() final  double quantity;
// 당월 말 보유 수량
@override@JsonKey(name: 'current_price') final  double currentPrice;
// 당월 말 현재가
@override@JsonKey() final  double balance;
// 당월 말 평가액 (quantity * currentPrice)
// 1. 투자 원금 (누적 및 당월분)
@override@JsonKey() final  double principal;
// 누적 투자 원금
@override@JsonKey(name: 'monthly_principal') final  double monthlyPrincipal;
// 당월 추가 매수/입금 원금
// 2. 배당금 및 기타 수령액 (누적 및 당월분)
@override@JsonKey(name: 'total_payout') final  double totalPayout;
// 누적 배당금/수령액
@override@JsonKey(name: 'monthly_payout') final  double monthlyPayout;
// 당월 배당금/수령액
// 3. 매도 및 인출액 (누적 및 당월분)
@override@JsonKey(name: 'total_withdrawal') final  double totalWithdrawal;
// 누적 매도/인출액
@override@JsonKey(name: 'monthly_withdrawal') final  double monthlyWithdrawal;
// 당월 매도/인출액
@override@JsonKey(name: 'purchase_date') final  String? purchaseDate;

/// Create a copy of MonthlyStockBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyStockBalanceCopyWith<_MonthlyStockBalance> get copyWith => __$MonthlyStockBalanceCopyWithImpl<_MonthlyStockBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyStockBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyStockBalance&&(identical(other.id, id) || other.id == id)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.stockItemId, stockItemId) || other.stockItemId == stockItemId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.stockItemName, stockItemName) || other.stockItemName == stockItemName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.monthlyPrincipal, monthlyPrincipal) || other.monthlyPrincipal == monthlyPrincipal)&&(identical(other.totalPayout, totalPayout) || other.totalPayout == totalPayout)&&(identical(other.monthlyPayout, monthlyPayout) || other.monthlyPayout == monthlyPayout)&&(identical(other.totalWithdrawal, totalWithdrawal) || other.totalWithdrawal == totalWithdrawal)&&(identical(other.monthlyWithdrawal, monthlyWithdrawal) || other.monthlyWithdrawal == monthlyWithdrawal)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,yearMonth,accountId,stockItemId,accountName,stockItemName,quantity,currentPrice,balance,principal,monthlyPrincipal,totalPayout,monthlyPayout,totalWithdrawal,monthlyWithdrawal,purchaseDate);

@override
String toString() {
  return 'MonthlyStockBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, stockItemId: $stockItemId, accountName: $accountName, stockItemName: $stockItemName, quantity: $quantity, currentPrice: $currentPrice, balance: $balance, principal: $principal, monthlyPrincipal: $monthlyPrincipal, totalPayout: $totalPayout, monthlyPayout: $monthlyPayout, totalWithdrawal: $totalWithdrawal, monthlyWithdrawal: $monthlyWithdrawal, purchaseDate: $purchaseDate)';
}


}

/// @nodoc
abstract mixin class _$MonthlyStockBalanceCopyWith<$Res> implements $MonthlyStockBalanceCopyWith<$Res> {
  factory _$MonthlyStockBalanceCopyWith(_MonthlyStockBalance value, $Res Function(_MonthlyStockBalance) _then) = __$MonthlyStockBalanceCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'year_month') String yearMonth,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'stock_item_id') String stockItemId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'stock_item_name') String? stockItemName, double quantity,@JsonKey(name: 'current_price') double currentPrice, double balance, double principal,@JsonKey(name: 'monthly_principal') double monthlyPrincipal,@JsonKey(name: 'total_payout') double totalPayout,@JsonKey(name: 'monthly_payout') double monthlyPayout,@JsonKey(name: 'total_withdrawal') double totalWithdrawal,@JsonKey(name: 'monthly_withdrawal') double monthlyWithdrawal,@JsonKey(name: 'purchase_date') String? purchaseDate
});




}
/// @nodoc
class __$MonthlyStockBalanceCopyWithImpl<$Res>
    implements _$MonthlyStockBalanceCopyWith<$Res> {
  __$MonthlyStockBalanceCopyWithImpl(this._self, this._then);

  final _MonthlyStockBalance _self;
  final $Res Function(_MonthlyStockBalance) _then;

/// Create a copy of MonthlyStockBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? yearMonth = null,Object? accountId = null,Object? stockItemId = null,Object? accountName = freezed,Object? stockItemName = freezed,Object? quantity = null,Object? currentPrice = null,Object? balance = null,Object? principal = null,Object? monthlyPrincipal = null,Object? totalPayout = null,Object? monthlyPayout = null,Object? totalWithdrawal = null,Object? monthlyWithdrawal = null,Object? purchaseDate = freezed,}) {
  return _then(_MonthlyStockBalance(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,stockItemId: null == stockItemId ? _self.stockItemId : stockItemId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,stockItemName: freezed == stockItemName ? _self.stockItemName : stockItemName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as double,monthlyPrincipal: null == monthlyPrincipal ? _self.monthlyPrincipal : monthlyPrincipal // ignore: cast_nullable_to_non_nullable
as double,totalPayout: null == totalPayout ? _self.totalPayout : totalPayout // ignore: cast_nullable_to_non_nullable
as double,monthlyPayout: null == monthlyPayout ? _self.monthlyPayout : monthlyPayout // ignore: cast_nullable_to_non_nullable
as double,totalWithdrawal: null == totalWithdrawal ? _self.totalWithdrawal : totalWithdrawal // ignore: cast_nullable_to_non_nullable
as double,monthlyWithdrawal: null == monthlyWithdrawal ? _self.monthlyWithdrawal : monthlyWithdrawal // ignore: cast_nullable_to_non_nullable
as double,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
