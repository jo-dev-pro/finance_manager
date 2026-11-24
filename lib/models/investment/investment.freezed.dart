// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'investment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Investment {

 String? get id; String get description; double get amount;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of Investment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvestmentCopyWith<Investment> get copyWith => _$InvestmentCopyWithImpl<Investment>(this as Investment, _$identity);

  /// Serializes this Investment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Investment&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,amount,createdAt);

@override
String toString() {
  return 'Investment(id: $id, description: $description, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InvestmentCopyWith<$Res>  {
  factory $InvestmentCopyWith(Investment value, $Res Function(Investment) _then) = _$InvestmentCopyWithImpl;
@useResult
$Res call({
 String? id, String description, double amount,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$InvestmentCopyWithImpl<$Res>
    implements $InvestmentCopyWith<$Res> {
  _$InvestmentCopyWithImpl(this._self, this._then);

  final Investment _self;
  final $Res Function(Investment) _then;

/// Create a copy of Investment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? description = null,Object? amount = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Investment].
extension InvestmentPatterns on Investment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Investment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Investment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Investment value)  $default,){
final _that = this;
switch (_that) {
case _Investment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Investment value)?  $default,){
final _that = this;
switch (_that) {
case _Investment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String description,  double amount, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Investment() when $default != null:
return $default(_that.id,_that.description,_that.amount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String description,  double amount, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Investment():
return $default(_that.id,_that.description,_that.amount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String description,  double amount, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Investment() when $default != null:
return $default(_that.id,_that.description,_that.amount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Investment implements Investment {
  const _Investment({this.id, required this.description, this.amount = 0, @JsonKey(name: 'created_at') this.createdAt});
  factory _Investment.fromJson(Map<String, dynamic> json) => _$InvestmentFromJson(json);

@override final  String? id;
@override final  String description;
@override@JsonKey() final  double amount;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of Investment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvestmentCopyWith<_Investment> get copyWith => __$InvestmentCopyWithImpl<_Investment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvestmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Investment&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,amount,createdAt);

@override
String toString() {
  return 'Investment(id: $id, description: $description, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InvestmentCopyWith<$Res> implements $InvestmentCopyWith<$Res> {
  factory _$InvestmentCopyWith(_Investment value, $Res Function(_Investment) _then) = __$InvestmentCopyWithImpl;
@override @useResult
$Res call({
 String? id, String description, double amount,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$InvestmentCopyWithImpl<$Res>
    implements _$InvestmentCopyWith<$Res> {
  __$InvestmentCopyWithImpl(this._self, this._then);

  final _Investment _self;
  final $Res Function(_Investment) _then;

/// Create a copy of Investment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? description = null,Object? amount = null,Object? createdAt = freezed,}) {
  return _then(_Investment(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
