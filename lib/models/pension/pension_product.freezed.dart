// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pension_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
PensionProduct _$PensionProductFromJson(
  Map<String, dynamic> json
) {
    return _Product.fromJson(
      json
    );
}

/// @nodoc
mixin _$PensionProduct {

 String? get id;@JsonKey(name: 'product_name') String get productName;
/// Create a copy of PensionProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PensionProductCopyWith<PensionProduct> get copyWith => _$PensionProductCopyWithImpl<PensionProduct>(this as PensionProduct, _$identity);

  /// Serializes this PensionProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PensionProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.productName, productName) || other.productName == productName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productName);

@override
String toString() {
  return 'PensionProduct(id: $id, productName: $productName)';
}


}

/// @nodoc
abstract mixin class $PensionProductCopyWith<$Res>  {
  factory $PensionProductCopyWith(PensionProduct value, $Res Function(PensionProduct) _then) = _$PensionProductCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'product_name') String productName
});




}
/// @nodoc
class _$PensionProductCopyWithImpl<$Res>
    implements $PensionProductCopyWith<$Res> {
  _$PensionProductCopyWithImpl(this._self, this._then);

  final PensionProduct _self;
  final $Res Function(PensionProduct) _then;

/// Create a copy of PensionProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? productName = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PensionProduct].
extension PensionProductPatterns on PensionProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'product_name')  String productName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.productName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'product_name')  String productName)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.productName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'product_name')  String productName)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.productName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product implements PensionProduct {
  const _Product({this.id, @JsonKey(name: 'product_name') required this.productName});
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'product_name') final  String productName;

/// Create a copy of PensionProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.productName, productName) || other.productName == productName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productName);

@override
String toString() {
  return 'PensionProduct(id: $id, productName: $productName)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $PensionProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'product_name') String productName
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of PensionProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? productName = null,}) {
  return _then(_Product(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
