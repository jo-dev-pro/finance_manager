// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_pension_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthlyPensionBalance {

 String? get id;@JsonKey(name: 'year_month') String get yearMonth;@JsonKey(name: 'account_id') String get accountId;@JsonKey(name: 'product_id') String get productId;@JsonKey(name: 'account_name') String? get accountName;// 콘솔 확인용 계좌명
@JsonKey(name: 'product_name') String? get productName;// 콘솔 확인용 상품명
 double get balance;// 당월 말 평가액
// 1. 투자 원금 (누적 및 당월분)
 double get principal;// 누적 투자 원금
@JsonKey(name: 'monthly_principal') double get monthlyPrincipal;// 당월 투자 원금 (납입액)
// 2. 상품별 매도(환매)액 (누적 및 당월분)
@JsonKey(name: 'total_sale') double get totalSale;// 누적 매도액
@JsonKey(name: 'monthly_sale') double get monthlySale;// 당월 매도액
@JsonKey(name: 'purchase_date') String? get purchaseDate;
/// Create a copy of MonthlyPensionBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyPensionBalanceCopyWith<MonthlyPensionBalance> get copyWith => _$MonthlyPensionBalanceCopyWithImpl<MonthlyPensionBalance>(this as MonthlyPensionBalance, _$identity);

  /// Serializes this MonthlyPensionBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyPensionBalance&&(identical(other.id, id) || other.id == id)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.monthlyPrincipal, monthlyPrincipal) || other.monthlyPrincipal == monthlyPrincipal)&&(identical(other.totalSale, totalSale) || other.totalSale == totalSale)&&(identical(other.monthlySale, monthlySale) || other.monthlySale == monthlySale)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,yearMonth,accountId,productId,accountName,productName,balance,principal,monthlyPrincipal,totalSale,monthlySale,purchaseDate);

@override
String toString() {
  return 'MonthlyPensionBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, productId: $productId, accountName: $accountName, productName: $productName, balance: $balance, principal: $principal, monthlyPrincipal: $monthlyPrincipal, totalSale: $totalSale, monthlySale: $monthlySale, purchaseDate: $purchaseDate)';
}


}

/// @nodoc
abstract mixin class $MonthlyPensionBalanceCopyWith<$Res>  {
  factory $MonthlyPensionBalanceCopyWith(MonthlyPensionBalance value, $Res Function(MonthlyPensionBalance) _then) = _$MonthlyPensionBalanceCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'year_month') String yearMonth,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'product_name') String? productName, double balance, double principal,@JsonKey(name: 'monthly_principal') double monthlyPrincipal,@JsonKey(name: 'total_sale') double totalSale,@JsonKey(name: 'monthly_sale') double monthlySale,@JsonKey(name: 'purchase_date') String? purchaseDate
});




}
/// @nodoc
class _$MonthlyPensionBalanceCopyWithImpl<$Res>
    implements $MonthlyPensionBalanceCopyWith<$Res> {
  _$MonthlyPensionBalanceCopyWithImpl(this._self, this._then);

  final MonthlyPensionBalance _self;
  final $Res Function(MonthlyPensionBalance) _then;

/// Create a copy of MonthlyPensionBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? yearMonth = null,Object? accountId = null,Object? productId = null,Object? accountName = freezed,Object? productName = freezed,Object? balance = null,Object? principal = null,Object? monthlyPrincipal = null,Object? totalSale = null,Object? monthlySale = null,Object? purchaseDate = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as double,monthlyPrincipal: null == monthlyPrincipal ? _self.monthlyPrincipal : monthlyPrincipal // ignore: cast_nullable_to_non_nullable
as double,totalSale: null == totalSale ? _self.totalSale : totalSale // ignore: cast_nullable_to_non_nullable
as double,monthlySale: null == monthlySale ? _self.monthlySale : monthlySale // ignore: cast_nullable_to_non_nullable
as double,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyPensionBalance].
extension MonthlyPensionBalancePatterns on MonthlyPensionBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyPensionBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyPensionBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyPensionBalance value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyPensionBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyPensionBalance value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyPensionBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'product_name')  String? productName,  double balance,  double principal, @JsonKey(name: 'monthly_principal')  double monthlyPrincipal, @JsonKey(name: 'total_sale')  double totalSale, @JsonKey(name: 'monthly_sale')  double monthlySale, @JsonKey(name: 'purchase_date')  String? purchaseDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyPensionBalance() when $default != null:
return $default(_that.id,_that.yearMonth,_that.accountId,_that.productId,_that.accountName,_that.productName,_that.balance,_that.principal,_that.monthlyPrincipal,_that.totalSale,_that.monthlySale,_that.purchaseDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'product_name')  String? productName,  double balance,  double principal, @JsonKey(name: 'monthly_principal')  double monthlyPrincipal, @JsonKey(name: 'total_sale')  double totalSale, @JsonKey(name: 'monthly_sale')  double monthlySale, @JsonKey(name: 'purchase_date')  String? purchaseDate)  $default,) {final _that = this;
switch (_that) {
case _MonthlyPensionBalance():
return $default(_that.id,_that.yearMonth,_that.accountId,_that.productId,_that.accountName,_that.productName,_that.balance,_that.principal,_that.monthlyPrincipal,_that.totalSale,_that.monthlySale,_that.purchaseDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'product_name')  String? productName,  double balance,  double principal, @JsonKey(name: 'monthly_principal')  double monthlyPrincipal, @JsonKey(name: 'total_sale')  double totalSale, @JsonKey(name: 'monthly_sale')  double monthlySale, @JsonKey(name: 'purchase_date')  String? purchaseDate)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyPensionBalance() when $default != null:
return $default(_that.id,_that.yearMonth,_that.accountId,_that.productId,_that.accountName,_that.productName,_that.balance,_that.principal,_that.monthlyPrincipal,_that.totalSale,_that.monthlySale,_that.purchaseDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyPensionBalance extends MonthlyPensionBalance {
  const _MonthlyPensionBalance({this.id, @JsonKey(name: 'year_month') required this.yearMonth, @JsonKey(name: 'account_id') required this.accountId, @JsonKey(name: 'product_id') required this.productId, @JsonKey(name: 'account_name') this.accountName, @JsonKey(name: 'product_name') this.productName, this.balance = 0.0, this.principal = 0.0, @JsonKey(name: 'monthly_principal') this.monthlyPrincipal = 0.0, @JsonKey(name: 'total_sale') this.totalSale = 0.0, @JsonKey(name: 'monthly_sale') this.monthlySale = 0.0, @JsonKey(name: 'purchase_date') this.purchaseDate}): super._();
  factory _MonthlyPensionBalance.fromJson(Map<String, dynamic> json) => _$MonthlyPensionBalanceFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'year_month') final  String yearMonth;
@override@JsonKey(name: 'account_id') final  String accountId;
@override@JsonKey(name: 'product_id') final  String productId;
@override@JsonKey(name: 'account_name') final  String? accountName;
// 콘솔 확인용 계좌명
@override@JsonKey(name: 'product_name') final  String? productName;
// 콘솔 확인용 상품명
@override@JsonKey() final  double balance;
// 당월 말 평가액
// 1. 투자 원금 (누적 및 당월분)
@override@JsonKey() final  double principal;
// 누적 투자 원금
@override@JsonKey(name: 'monthly_principal') final  double monthlyPrincipal;
// 당월 투자 원금 (납입액)
// 2. 상품별 매도(환매)액 (누적 및 당월분)
@override@JsonKey(name: 'total_sale') final  double totalSale;
// 누적 매도액
@override@JsonKey(name: 'monthly_sale') final  double monthlySale;
// 당월 매도액
@override@JsonKey(name: 'purchase_date') final  String? purchaseDate;

/// Create a copy of MonthlyPensionBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyPensionBalanceCopyWith<_MonthlyPensionBalance> get copyWith => __$MonthlyPensionBalanceCopyWithImpl<_MonthlyPensionBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyPensionBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyPensionBalance&&(identical(other.id, id) || other.id == id)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.monthlyPrincipal, monthlyPrincipal) || other.monthlyPrincipal == monthlyPrincipal)&&(identical(other.totalSale, totalSale) || other.totalSale == totalSale)&&(identical(other.monthlySale, monthlySale) || other.monthlySale == monthlySale)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,yearMonth,accountId,productId,accountName,productName,balance,principal,monthlyPrincipal,totalSale,monthlySale,purchaseDate);

@override
String toString() {
  return 'MonthlyPensionBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, productId: $productId, accountName: $accountName, productName: $productName, balance: $balance, principal: $principal, monthlyPrincipal: $monthlyPrincipal, totalSale: $totalSale, monthlySale: $monthlySale, purchaseDate: $purchaseDate)';
}


}

/// @nodoc
abstract mixin class _$MonthlyPensionBalanceCopyWith<$Res> implements $MonthlyPensionBalanceCopyWith<$Res> {
  factory _$MonthlyPensionBalanceCopyWith(_MonthlyPensionBalance value, $Res Function(_MonthlyPensionBalance) _then) = __$MonthlyPensionBalanceCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'year_month') String yearMonth,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'product_name') String? productName, double balance, double principal,@JsonKey(name: 'monthly_principal') double monthlyPrincipal,@JsonKey(name: 'total_sale') double totalSale,@JsonKey(name: 'monthly_sale') double monthlySale,@JsonKey(name: 'purchase_date') String? purchaseDate
});




}
/// @nodoc
class __$MonthlyPensionBalanceCopyWithImpl<$Res>
    implements _$MonthlyPensionBalanceCopyWith<$Res> {
  __$MonthlyPensionBalanceCopyWithImpl(this._self, this._then);

  final _MonthlyPensionBalance _self;
  final $Res Function(_MonthlyPensionBalance) _then;

/// Create a copy of MonthlyPensionBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? yearMonth = null,Object? accountId = null,Object? productId = null,Object? accountName = freezed,Object? productName = freezed,Object? balance = null,Object? principal = null,Object? monthlyPrincipal = null,Object? totalSale = null,Object? monthlySale = null,Object? purchaseDate = freezed,}) {
  return _then(_MonthlyPensionBalance(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as double,monthlyPrincipal: null == monthlyPrincipal ? _self.monthlyPrincipal : monthlyPrincipal // ignore: cast_nullable_to_non_nullable
as double,totalSale: null == totalSale ? _self.totalSale : totalSale // ignore: cast_nullable_to_non_nullable
as double,monthlySale: null == monthlySale ? _self.monthlySale : monthlySale // ignore: cast_nullable_to_non_nullable
as double,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
