// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Account {

 String? get id;@JsonKey(name: 'financial_institution') String get financialInstitution;@JsonKey(name: 'account_name_id') String? get accountNameId;@JsonKey(name: 'account_name') String? get accountName;@JsonKey(name: 'account_type') String get accountType;@JsonKey(name: 'account_number') String? get accountNumber;@JsonKey(name: 'logo_url') String? get logoUrl; String get status;@JsonKey(name: 'sort_order') int get sortOrder;// 💡 1. 통화 구분 필드 추가 (기본값 'KRW', 해외 달러 계좌의 경우 'USD')
@JsonKey(name: 'currency') String get currency;
/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountCopyWith<Account> get copyWith => _$AccountCopyWithImpl<Account>(this as Account, _$identity);

  /// Serializes this Account to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Account&&(identical(other.id, id) || other.id == id)&&(identical(other.financialInstitution, financialInstitution) || other.financialInstitution == financialInstitution)&&(identical(other.accountNameId, accountNameId) || other.accountNameId == accountNameId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,financialInstitution,accountNameId,accountName,accountType,accountNumber,logoUrl,status,sortOrder,currency);

@override
String toString() {
  return 'Account(id: $id, financialInstitution: $financialInstitution, accountNameId: $accountNameId, accountName: $accountName, accountType: $accountType, accountNumber: $accountNumber, logoUrl: $logoUrl, status: $status, sortOrder: $sortOrder, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $AccountCopyWith<$Res>  {
  factory $AccountCopyWith(Account value, $Res Function(Account) _then) = _$AccountCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'financial_institution') String financialInstitution,@JsonKey(name: 'account_name_id') String? accountNameId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'account_type') String accountType,@JsonKey(name: 'account_number') String? accountNumber,@JsonKey(name: 'logo_url') String? logoUrl, String status,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'currency') String currency
});




}
/// @nodoc
class _$AccountCopyWithImpl<$Res>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._self, this._then);

  final Account _self;
  final $Res Function(Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? financialInstitution = null,Object? accountNameId = freezed,Object? accountName = freezed,Object? accountType = null,Object? accountNumber = freezed,Object? logoUrl = freezed,Object? status = null,Object? sortOrder = null,Object? currency = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,financialInstitution: null == financialInstitution ? _self.financialInstitution : financialInstitution // ignore: cast_nullable_to_non_nullable
as String,accountNameId: freezed == accountNameId ? _self.accountNameId : accountNameId // ignore: cast_nullable_to_non_nullable
as String?,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,accountType: null == accountType ? _self.accountType : accountType // ignore: cast_nullable_to_non_nullable
as String,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Account].
extension AccountPatterns on Account {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Account value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Account value)  $default,){
final _that = this;
switch (_that) {
case _Account():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Account value)?  $default,){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'financial_institution')  String financialInstitution, @JsonKey(name: 'account_name_id')  String? accountNameId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'account_type')  String accountType, @JsonKey(name: 'account_number')  String? accountNumber, @JsonKey(name: 'logo_url')  String? logoUrl,  String status, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'currency')  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.financialInstitution,_that.accountNameId,_that.accountName,_that.accountType,_that.accountNumber,_that.logoUrl,_that.status,_that.sortOrder,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'financial_institution')  String financialInstitution, @JsonKey(name: 'account_name_id')  String? accountNameId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'account_type')  String accountType, @JsonKey(name: 'account_number')  String? accountNumber, @JsonKey(name: 'logo_url')  String? logoUrl,  String status, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'currency')  String currency)  $default,) {final _that = this;
switch (_that) {
case _Account():
return $default(_that.id,_that.financialInstitution,_that.accountNameId,_that.accountName,_that.accountType,_that.accountNumber,_that.logoUrl,_that.status,_that.sortOrder,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'financial_institution')  String financialInstitution, @JsonKey(name: 'account_name_id')  String? accountNameId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'account_type')  String accountType, @JsonKey(name: 'account_number')  String? accountNumber, @JsonKey(name: 'logo_url')  String? logoUrl,  String status, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'currency')  String currency)?  $default,) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.financialInstitution,_that.accountNameId,_that.accountName,_that.accountType,_that.accountNumber,_that.logoUrl,_that.status,_that.sortOrder,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Account extends Account {
  const _Account({this.id, @JsonKey(name: 'financial_institution') required this.financialInstitution, @JsonKey(name: 'account_name_id') this.accountNameId, @JsonKey(name: 'account_name') this.accountName, @JsonKey(name: 'account_type') required this.accountType, @JsonKey(name: 'account_number') this.accountNumber, @JsonKey(name: 'logo_url') this.logoUrl, this.status = '활동', @JsonKey(name: 'sort_order') this.sortOrder = 0, @JsonKey(name: 'currency') this.currency = 'KRW'}): super._();
  factory _Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'financial_institution') final  String financialInstitution;
@override@JsonKey(name: 'account_name_id') final  String? accountNameId;
@override@JsonKey(name: 'account_name') final  String? accountName;
@override@JsonKey(name: 'account_type') final  String accountType;
@override@JsonKey(name: 'account_number') final  String? accountNumber;
@override@JsonKey(name: 'logo_url') final  String? logoUrl;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
// 💡 1. 통화 구분 필드 추가 (기본값 'KRW', 해외 달러 계좌의 경우 'USD')
@override@JsonKey(name: 'currency') final  String currency;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountCopyWith<_Account> get copyWith => __$AccountCopyWithImpl<_Account>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Account&&(identical(other.id, id) || other.id == id)&&(identical(other.financialInstitution, financialInstitution) || other.financialInstitution == financialInstitution)&&(identical(other.accountNameId, accountNameId) || other.accountNameId == accountNameId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,financialInstitution,accountNameId,accountName,accountType,accountNumber,logoUrl,status,sortOrder,currency);

@override
String toString() {
  return 'Account(id: $id, financialInstitution: $financialInstitution, accountNameId: $accountNameId, accountName: $accountName, accountType: $accountType, accountNumber: $accountNumber, logoUrl: $logoUrl, status: $status, sortOrder: $sortOrder, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$AccountCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$AccountCopyWith(_Account value, $Res Function(_Account) _then) = __$AccountCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'financial_institution') String financialInstitution,@JsonKey(name: 'account_name_id') String? accountNameId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'account_type') String accountType,@JsonKey(name: 'account_number') String? accountNumber,@JsonKey(name: 'logo_url') String? logoUrl, String status,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'currency') String currency
});




}
/// @nodoc
class __$AccountCopyWithImpl<$Res>
    implements _$AccountCopyWith<$Res> {
  __$AccountCopyWithImpl(this._self, this._then);

  final _Account _self;
  final $Res Function(_Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? financialInstitution = null,Object? accountNameId = freezed,Object? accountName = freezed,Object? accountType = null,Object? accountNumber = freezed,Object? logoUrl = freezed,Object? status = null,Object? sortOrder = null,Object? currency = null,}) {
  return _then(_Account(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,financialInstitution: null == financialInstitution ? _self.financialInstitution : financialInstitution // ignore: cast_nullable_to_non_nullable
as String,accountNameId: freezed == accountNameId ? _self.accountNameId : accountNameId // ignore: cast_nullable_to_non_nullable
as String?,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,accountType: null == accountType ? _self.accountType : accountType // ignore: cast_nullable_to_non_nullable
as String,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
