// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pension_holding_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PensionHoldingProduct {

 String? get id;@JsonKey(name: 'account_id') String get accountId;// 연금 계좌 ID
@JsonKey(name: 'product_id') String get productId;// 공용 상품 ID
@JsonKey(name: 'account_name') String? get accountName;// 콘솔 확인용 계좌명
@JsonKey(name: 'product_name') String? get productName;// 콘솔 확인용 상품명
@JsonKey(name: 'is_active') bool get isActive;// 활동 / 비활동 여부
@JsonKey(name: 'initial_purchase_date') String? get initialPurchaseDate;
/// Create a copy of PensionHoldingProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PensionHoldingProductCopyWith<PensionHoldingProduct> get copyWith => _$PensionHoldingProductCopyWithImpl<PensionHoldingProduct>(this as PensionHoldingProduct, _$identity);

  /// Serializes this PensionHoldingProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PensionHoldingProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.initialPurchaseDate, initialPurchaseDate) || other.initialPurchaseDate == initialPurchaseDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,productId,accountName,productName,isActive,initialPurchaseDate);

@override
String toString() {
  return 'PensionHoldingProduct(id: $id, accountId: $accountId, productId: $productId, accountName: $accountName, productName: $productName, isActive: $isActive, initialPurchaseDate: $initialPurchaseDate)';
}


}

/// @nodoc
abstract mixin class $PensionHoldingProductCopyWith<$Res>  {
  factory $PensionHoldingProductCopyWith(PensionHoldingProduct value, $Res Function(PensionHoldingProduct) _then) = _$PensionHoldingProductCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'product_name') String? productName,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'initial_purchase_date') String? initialPurchaseDate
});




}
/// @nodoc
class _$PensionHoldingProductCopyWithImpl<$Res>
    implements $PensionHoldingProductCopyWith<$Res> {
  _$PensionHoldingProductCopyWithImpl(this._self, this._then);

  final PensionHoldingProduct _self;
  final $Res Function(PensionHoldingProduct) _then;

/// Create a copy of PensionHoldingProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? accountId = null,Object? productId = null,Object? accountName = freezed,Object? productName = freezed,Object? isActive = null,Object? initialPurchaseDate = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,initialPurchaseDate: freezed == initialPurchaseDate ? _self.initialPurchaseDate : initialPurchaseDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PensionHoldingProduct].
extension PensionHoldingProductPatterns on PensionHoldingProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PensionHoldingProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PensionHoldingProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PensionHoldingProduct value)  $default,){
final _that = this;
switch (_that) {
case _PensionHoldingProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PensionHoldingProduct value)?  $default,){
final _that = this;
switch (_that) {
case _PensionHoldingProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'initial_purchase_date')  String? initialPurchaseDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PensionHoldingProduct() when $default != null:
return $default(_that.id,_that.accountId,_that.productId,_that.accountName,_that.productName,_that.isActive,_that.initialPurchaseDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'initial_purchase_date')  String? initialPurchaseDate)  $default,) {final _that = this;
switch (_that) {
case _PensionHoldingProduct():
return $default(_that.id,_that.accountId,_that.productId,_that.accountName,_that.productName,_that.isActive,_that.initialPurchaseDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'initial_purchase_date')  String? initialPurchaseDate)?  $default,) {final _that = this;
switch (_that) {
case _PensionHoldingProduct() when $default != null:
return $default(_that.id,_that.accountId,_that.productId,_that.accountName,_that.productName,_that.isActive,_that.initialPurchaseDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PensionHoldingProduct extends PensionHoldingProduct {
  const _PensionHoldingProduct({this.id, @JsonKey(name: 'account_id') required this.accountId, @JsonKey(name: 'product_id') required this.productId, @JsonKey(name: 'account_name') this.accountName, @JsonKey(name: 'product_name') this.productName, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'initial_purchase_date') this.initialPurchaseDate}): super._();
  factory _PensionHoldingProduct.fromJson(Map<String, dynamic> json) => _$PensionHoldingProductFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'account_id') final  String accountId;
// 연금 계좌 ID
@override@JsonKey(name: 'product_id') final  String productId;
// 공용 상품 ID
@override@JsonKey(name: 'account_name') final  String? accountName;
// 콘솔 확인용 계좌명
@override@JsonKey(name: 'product_name') final  String? productName;
// 콘솔 확인용 상품명
@override@JsonKey(name: 'is_active') final  bool isActive;
// 활동 / 비활동 여부
@override@JsonKey(name: 'initial_purchase_date') final  String? initialPurchaseDate;

/// Create a copy of PensionHoldingProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PensionHoldingProductCopyWith<_PensionHoldingProduct> get copyWith => __$PensionHoldingProductCopyWithImpl<_PensionHoldingProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PensionHoldingProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PensionHoldingProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.initialPurchaseDate, initialPurchaseDate) || other.initialPurchaseDate == initialPurchaseDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,productId,accountName,productName,isActive,initialPurchaseDate);

@override
String toString() {
  return 'PensionHoldingProduct(id: $id, accountId: $accountId, productId: $productId, accountName: $accountName, productName: $productName, isActive: $isActive, initialPurchaseDate: $initialPurchaseDate)';
}


}

/// @nodoc
abstract mixin class _$PensionHoldingProductCopyWith<$Res> implements $PensionHoldingProductCopyWith<$Res> {
  factory _$PensionHoldingProductCopyWith(_PensionHoldingProduct value, $Res Function(_PensionHoldingProduct) _then) = __$PensionHoldingProductCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'product_name') String? productName,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'initial_purchase_date') String? initialPurchaseDate
});




}
/// @nodoc
class __$PensionHoldingProductCopyWithImpl<$Res>
    implements _$PensionHoldingProductCopyWith<$Res> {
  __$PensionHoldingProductCopyWithImpl(this._self, this._then);

  final _PensionHoldingProduct _self;
  final $Res Function(_PensionHoldingProduct) _then;

/// Create a copy of PensionHoldingProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? accountId = null,Object? productId = null,Object? accountName = freezed,Object? productName = freezed,Object? isActive = null,Object? initialPurchaseDate = freezed,}) {
  return _then(_PensionHoldingProduct(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,initialPurchaseDate: freezed == initialPurchaseDate ? _self.initialPurchaseDate : initialPurchaseDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
