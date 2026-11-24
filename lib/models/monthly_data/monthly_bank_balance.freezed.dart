// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_bank_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthlyBankBalance {

 String? get id;@JsonKey(name: 'year_month') String get yearMonth;@JsonKey(name: 'account_id') String get accountId;@JsonKey(name: 'account_name') String? get accountName; double get balance;
/// Create a copy of MonthlyBankBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyBankBalanceCopyWith<MonthlyBankBalance> get copyWith => _$MonthlyBankBalanceCopyWithImpl<MonthlyBankBalance>(this as MonthlyBankBalance, _$identity);

  /// Serializes this MonthlyBankBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyBankBalance&&(identical(other.id, id) || other.id == id)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,yearMonth,accountId,accountName,balance);

@override
String toString() {
  return 'MonthlyBankBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, accountName: $accountName, balance: $balance)';
}


}

/// @nodoc
abstract mixin class $MonthlyBankBalanceCopyWith<$Res>  {
  factory $MonthlyBankBalanceCopyWith(MonthlyBankBalance value, $Res Function(MonthlyBankBalance) _then) = _$MonthlyBankBalanceCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'year_month') String yearMonth,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'account_name') String? accountName, double balance
});




}
/// @nodoc
class _$MonthlyBankBalanceCopyWithImpl<$Res>
    implements $MonthlyBankBalanceCopyWith<$Res> {
  _$MonthlyBankBalanceCopyWithImpl(this._self, this._then);

  final MonthlyBankBalance _self;
  final $Res Function(MonthlyBankBalance) _then;

/// Create a copy of MonthlyBankBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? yearMonth = null,Object? accountId = null,Object? accountName = freezed,Object? balance = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyBankBalance].
extension MonthlyBankBalancePatterns on MonthlyBankBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyBankBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyBankBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyBankBalance value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyBankBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyBankBalance value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyBankBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'account_name')  String? accountName,  double balance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyBankBalance() when $default != null:
return $default(_that.id,_that.yearMonth,_that.accountId,_that.accountName,_that.balance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'account_name')  String? accountName,  double balance)  $default,) {final _that = this;
switch (_that) {
case _MonthlyBankBalance():
return $default(_that.id,_that.yearMonth,_that.accountId,_that.accountName,_that.balance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'year_month')  String yearMonth, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'account_name')  String? accountName,  double balance)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyBankBalance() when $default != null:
return $default(_that.id,_that.yearMonth,_that.accountId,_that.accountName,_that.balance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyBankBalance implements MonthlyBankBalance {
  const _MonthlyBankBalance({this.id, @JsonKey(name: 'year_month') required this.yearMonth, @JsonKey(name: 'account_id') required this.accountId, @JsonKey(name: 'account_name') this.accountName, this.balance = 0.0});
  factory _MonthlyBankBalance.fromJson(Map<String, dynamic> json) => _$MonthlyBankBalanceFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'year_month') final  String yearMonth;
@override@JsonKey(name: 'account_id') final  String accountId;
@override@JsonKey(name: 'account_name') final  String? accountName;
@override@JsonKey() final  double balance;

/// Create a copy of MonthlyBankBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyBankBalanceCopyWith<_MonthlyBankBalance> get copyWith => __$MonthlyBankBalanceCopyWithImpl<_MonthlyBankBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyBankBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyBankBalance&&(identical(other.id, id) || other.id == id)&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,yearMonth,accountId,accountName,balance);

@override
String toString() {
  return 'MonthlyBankBalance(id: $id, yearMonth: $yearMonth, accountId: $accountId, accountName: $accountName, balance: $balance)';
}


}

/// @nodoc
abstract mixin class _$MonthlyBankBalanceCopyWith<$Res> implements $MonthlyBankBalanceCopyWith<$Res> {
  factory _$MonthlyBankBalanceCopyWith(_MonthlyBankBalance value, $Res Function(_MonthlyBankBalance) _then) = __$MonthlyBankBalanceCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'year_month') String yearMonth,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'account_name') String? accountName, double balance
});




}
/// @nodoc
class __$MonthlyBankBalanceCopyWithImpl<$Res>
    implements _$MonthlyBankBalanceCopyWith<$Res> {
  __$MonthlyBankBalanceCopyWithImpl(this._self, this._then);

  final _MonthlyBankBalance _self;
  final $Res Function(_MonthlyBankBalance) _then;

/// Create a copy of MonthlyBankBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? yearMonth = null,Object? accountId = null,Object? accountName = freezed,Object? balance = null,}) {
  return _then(_MonthlyBankBalance(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
