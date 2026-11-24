// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_name.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountName {

 String? get id;@JsonKey(name: 'account_name') String get accountName;
/// Create a copy of AccountName
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountNameCopyWith<AccountName> get copyWith => _$AccountNameCopyWithImpl<AccountName>(this as AccountName, _$identity);

  /// Serializes this AccountName to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountName&&(identical(other.id, id) || other.id == id)&&(identical(other.accountName, accountName) || other.accountName == accountName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountName);

@override
String toString() {
  return 'AccountName(id: $id, accountName: $accountName)';
}


}

/// @nodoc
abstract mixin class $AccountNameCopyWith<$Res>  {
  factory $AccountNameCopyWith(AccountName value, $Res Function(AccountName) _then) = _$AccountNameCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'account_name') String accountName
});




}
/// @nodoc
class _$AccountNameCopyWithImpl<$Res>
    implements $AccountNameCopyWith<$Res> {
  _$AccountNameCopyWithImpl(this._self, this._then);

  final AccountName _self;
  final $Res Function(AccountName) _then;

/// Create a copy of AccountName
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? accountName = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountName].
extension AccountNamePatterns on AccountName {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountName value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountName() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountName value)  $default,){
final _that = this;
switch (_that) {
case _AccountName():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountName value)?  $default,){
final _that = this;
switch (_that) {
case _AccountName() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'account_name')  String accountName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountName() when $default != null:
return $default(_that.id,_that.accountName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'account_name')  String accountName)  $default,) {final _that = this;
switch (_that) {
case _AccountName():
return $default(_that.id,_that.accountName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'account_name')  String accountName)?  $default,) {final _that = this;
switch (_that) {
case _AccountName() when $default != null:
return $default(_that.id,_that.accountName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountName implements AccountName {
  const _AccountName({this.id, @JsonKey(name: 'account_name') required this.accountName});
  factory _AccountName.fromJson(Map<String, dynamic> json) => _$AccountNameFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'account_name') final  String accountName;

/// Create a copy of AccountName
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountNameCopyWith<_AccountName> get copyWith => __$AccountNameCopyWithImpl<_AccountName>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountNameToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountName&&(identical(other.id, id) || other.id == id)&&(identical(other.accountName, accountName) || other.accountName == accountName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountName);

@override
String toString() {
  return 'AccountName(id: $id, accountName: $accountName)';
}


}

/// @nodoc
abstract mixin class _$AccountNameCopyWith<$Res> implements $AccountNameCopyWith<$Res> {
  factory _$AccountNameCopyWith(_AccountName value, $Res Function(_AccountName) _then) = __$AccountNameCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'account_name') String accountName
});




}
/// @nodoc
class __$AccountNameCopyWithImpl<$Res>
    implements _$AccountNameCopyWith<$Res> {
  __$AccountNameCopyWithImpl(this._self, this._then);

  final _AccountName _self;
  final $Res Function(_AccountName) _then;

/// Create a copy of AccountName
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? accountName = null,}) {
  return _then(_AccountName(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
