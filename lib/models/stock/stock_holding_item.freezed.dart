// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_holding_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StockHoldingItem {

 String? get id;@JsonKey(name: 'account_id') String get accountId;// 계좌 ID
@JsonKey(name: 'stock_item_id') String get stockItemId;// 종목 ID
@JsonKey(name: 'account_name') String? get accountName;// 콘솔 확인용 계좌명
@JsonKey(name: 'stock_item_name') String? get stockItemName;// 콘솔 확인용 종목명
@JsonKey(name: 'is_active') bool get isActive;// 활동 / 비활동 여부
@JsonKey(name: 'initial_purchase_date') String? get initialPurchaseDate;
/// Create a copy of StockHoldingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockHoldingItemCopyWith<StockHoldingItem> get copyWith => _$StockHoldingItemCopyWithImpl<StockHoldingItem>(this as StockHoldingItem, _$identity);

  /// Serializes this StockHoldingItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockHoldingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.stockItemId, stockItemId) || other.stockItemId == stockItemId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.stockItemName, stockItemName) || other.stockItemName == stockItemName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.initialPurchaseDate, initialPurchaseDate) || other.initialPurchaseDate == initialPurchaseDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,stockItemId,accountName,stockItemName,isActive,initialPurchaseDate);

@override
String toString() {
  return 'StockHoldingItem(id: $id, accountId: $accountId, stockItemId: $stockItemId, accountName: $accountName, stockItemName: $stockItemName, isActive: $isActive, initialPurchaseDate: $initialPurchaseDate)';
}


}

/// @nodoc
abstract mixin class $StockHoldingItemCopyWith<$Res>  {
  factory $StockHoldingItemCopyWith(StockHoldingItem value, $Res Function(StockHoldingItem) _then) = _$StockHoldingItemCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'stock_item_id') String stockItemId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'stock_item_name') String? stockItemName,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'initial_purchase_date') String? initialPurchaseDate
});




}
/// @nodoc
class _$StockHoldingItemCopyWithImpl<$Res>
    implements $StockHoldingItemCopyWith<$Res> {
  _$StockHoldingItemCopyWithImpl(this._self, this._then);

  final StockHoldingItem _self;
  final $Res Function(StockHoldingItem) _then;

/// Create a copy of StockHoldingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? accountId = null,Object? stockItemId = null,Object? accountName = freezed,Object? stockItemName = freezed,Object? isActive = null,Object? initialPurchaseDate = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,stockItemId: null == stockItemId ? _self.stockItemId : stockItemId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,stockItemName: freezed == stockItemName ? _self.stockItemName : stockItemName // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,initialPurchaseDate: freezed == initialPurchaseDate ? _self.initialPurchaseDate : initialPurchaseDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StockHoldingItem].
extension StockHoldingItemPatterns on StockHoldingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockHoldingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockHoldingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockHoldingItem value)  $default,){
final _that = this;
switch (_that) {
case _StockHoldingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockHoldingItem value)?  $default,){
final _that = this;
switch (_that) {
case _StockHoldingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'stock_item_id')  String stockItemId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'stock_item_name')  String? stockItemName, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'initial_purchase_date')  String? initialPurchaseDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockHoldingItem() when $default != null:
return $default(_that.id,_that.accountId,_that.stockItemId,_that.accountName,_that.stockItemName,_that.isActive,_that.initialPurchaseDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'stock_item_id')  String stockItemId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'stock_item_name')  String? stockItemName, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'initial_purchase_date')  String? initialPurchaseDate)  $default,) {final _that = this;
switch (_that) {
case _StockHoldingItem():
return $default(_that.id,_that.accountId,_that.stockItemId,_that.accountName,_that.stockItemName,_that.isActive,_that.initialPurchaseDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'stock_item_id')  String stockItemId, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'stock_item_name')  String? stockItemName, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'initial_purchase_date')  String? initialPurchaseDate)?  $default,) {final _that = this;
switch (_that) {
case _StockHoldingItem() when $default != null:
return $default(_that.id,_that.accountId,_that.stockItemId,_that.accountName,_that.stockItemName,_that.isActive,_that.initialPurchaseDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockHoldingItem extends StockHoldingItem {
  const _StockHoldingItem({this.id, @JsonKey(name: 'account_id') required this.accountId, @JsonKey(name: 'stock_item_id') required this.stockItemId, @JsonKey(name: 'account_name') this.accountName, @JsonKey(name: 'stock_item_name') this.stockItemName, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'initial_purchase_date') this.initialPurchaseDate}): super._();
  factory _StockHoldingItem.fromJson(Map<String, dynamic> json) => _$StockHoldingItemFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'account_id') final  String accountId;
// 계좌 ID
@override@JsonKey(name: 'stock_item_id') final  String stockItemId;
// 종목 ID
@override@JsonKey(name: 'account_name') final  String? accountName;
// 콘솔 확인용 계좌명
@override@JsonKey(name: 'stock_item_name') final  String? stockItemName;
// 콘솔 확인용 종목명
@override@JsonKey(name: 'is_active') final  bool isActive;
// 활동 / 비활동 여부
@override@JsonKey(name: 'initial_purchase_date') final  String? initialPurchaseDate;

/// Create a copy of StockHoldingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockHoldingItemCopyWith<_StockHoldingItem> get copyWith => __$StockHoldingItemCopyWithImpl<_StockHoldingItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockHoldingItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockHoldingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.stockItemId, stockItemId) || other.stockItemId == stockItemId)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.stockItemName, stockItemName) || other.stockItemName == stockItemName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.initialPurchaseDate, initialPurchaseDate) || other.initialPurchaseDate == initialPurchaseDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,stockItemId,accountName,stockItemName,isActive,initialPurchaseDate);

@override
String toString() {
  return 'StockHoldingItem(id: $id, accountId: $accountId, stockItemId: $stockItemId, accountName: $accountName, stockItemName: $stockItemName, isActive: $isActive, initialPurchaseDate: $initialPurchaseDate)';
}


}

/// @nodoc
abstract mixin class _$StockHoldingItemCopyWith<$Res> implements $StockHoldingItemCopyWith<$Res> {
  factory _$StockHoldingItemCopyWith(_StockHoldingItem value, $Res Function(_StockHoldingItem) _then) = __$StockHoldingItemCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'stock_item_id') String stockItemId,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'stock_item_name') String? stockItemName,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'initial_purchase_date') String? initialPurchaseDate
});




}
/// @nodoc
class __$StockHoldingItemCopyWithImpl<$Res>
    implements _$StockHoldingItemCopyWith<$Res> {
  __$StockHoldingItemCopyWithImpl(this._self, this._then);

  final _StockHoldingItem _self;
  final $Res Function(_StockHoldingItem) _then;

/// Create a copy of StockHoldingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? accountId = null,Object? stockItemId = null,Object? accountName = freezed,Object? stockItemName = freezed,Object? isActive = null,Object? initialPurchaseDate = freezed,}) {
  return _then(_StockHoldingItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,stockItemId: null == stockItemId ? _self.stockItemId : stockItemId // ignore: cast_nullable_to_non_nullable
as String,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,stockItemName: freezed == stockItemName ? _self.stockItemName : stockItemName // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,initialPurchaseDate: freezed == initialPurchaseDate ? _self.initialPurchaseDate : initialPurchaseDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
