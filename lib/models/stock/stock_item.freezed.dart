// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StockItem {

 String? get id;// 문서 ID (docId) 매핑용
@JsonKey(name: 'itemName') String get itemName;// 종목명 (예: 노바텍)
@JsonKey(name: 'otherName') String get otherName;// 기타 이름
@JsonKey(name: 'stockCode') String get stockCode;// 종목 코드 (예: 285490)
@JsonKey(name: 'yahooName') String? get yahooName;
/// Create a copy of StockItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockItemCopyWith<StockItem> get copyWith => _$StockItemCopyWithImpl<StockItem>(this as StockItem, _$identity);

  /// Serializes this StockItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockItem&&(identical(other.id, id) || other.id == id)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.otherName, otherName) || other.otherName == otherName)&&(identical(other.stockCode, stockCode) || other.stockCode == stockCode)&&(identical(other.yahooName, yahooName) || other.yahooName == yahooName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemName,otherName,stockCode,yahooName);

@override
String toString() {
  return 'StockItem(id: $id, itemName: $itemName, otherName: $otherName, stockCode: $stockCode, yahooName: $yahooName)';
}


}

/// @nodoc
abstract mixin class $StockItemCopyWith<$Res>  {
  factory $StockItemCopyWith(StockItem value, $Res Function(StockItem) _then) = _$StockItemCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'itemName') String itemName,@JsonKey(name: 'otherName') String otherName,@JsonKey(name: 'stockCode') String stockCode,@JsonKey(name: 'yahooName') String? yahooName
});




}
/// @nodoc
class _$StockItemCopyWithImpl<$Res>
    implements $StockItemCopyWith<$Res> {
  _$StockItemCopyWithImpl(this._self, this._then);

  final StockItem _self;
  final $Res Function(StockItem) _then;

/// Create a copy of StockItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? itemName = null,Object? otherName = null,Object? stockCode = null,Object? yahooName = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,otherName: null == otherName ? _self.otherName : otherName // ignore: cast_nullable_to_non_nullable
as String,stockCode: null == stockCode ? _self.stockCode : stockCode // ignore: cast_nullable_to_non_nullable
as String,yahooName: freezed == yahooName ? _self.yahooName : yahooName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StockItem].
extension StockItemPatterns on StockItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockItem value)  $default,){
final _that = this;
switch (_that) {
case _StockItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockItem value)?  $default,){
final _that = this;
switch (_that) {
case _StockItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'itemName')  String itemName, @JsonKey(name: 'otherName')  String otherName, @JsonKey(name: 'stockCode')  String stockCode, @JsonKey(name: 'yahooName')  String? yahooName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockItem() when $default != null:
return $default(_that.id,_that.itemName,_that.otherName,_that.stockCode,_that.yahooName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'itemName')  String itemName, @JsonKey(name: 'otherName')  String otherName, @JsonKey(name: 'stockCode')  String stockCode, @JsonKey(name: 'yahooName')  String? yahooName)  $default,) {final _that = this;
switch (_that) {
case _StockItem():
return $default(_that.id,_that.itemName,_that.otherName,_that.stockCode,_that.yahooName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'itemName')  String itemName, @JsonKey(name: 'otherName')  String otherName, @JsonKey(name: 'stockCode')  String stockCode, @JsonKey(name: 'yahooName')  String? yahooName)?  $default,) {final _that = this;
switch (_that) {
case _StockItem() when $default != null:
return $default(_that.id,_that.itemName,_that.otherName,_that.stockCode,_that.yahooName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockItem implements StockItem {
  const _StockItem({this.id, @JsonKey(name: 'itemName') required this.itemName, @JsonKey(name: 'otherName') this.otherName = '', @JsonKey(name: 'stockCode') required this.stockCode, @JsonKey(name: 'yahooName') this.yahooName});
  factory _StockItem.fromJson(Map<String, dynamic> json) => _$StockItemFromJson(json);

@override final  String? id;
// 문서 ID (docId) 매핑용
@override@JsonKey(name: 'itemName') final  String itemName;
// 종목명 (예: 노바텍)
@override@JsonKey(name: 'otherName') final  String otherName;
// 기타 이름
@override@JsonKey(name: 'stockCode') final  String stockCode;
// 종목 코드 (예: 285490)
@override@JsonKey(name: 'yahooName') final  String? yahooName;

/// Create a copy of StockItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockItemCopyWith<_StockItem> get copyWith => __$StockItemCopyWithImpl<_StockItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockItem&&(identical(other.id, id) || other.id == id)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.otherName, otherName) || other.otherName == otherName)&&(identical(other.stockCode, stockCode) || other.stockCode == stockCode)&&(identical(other.yahooName, yahooName) || other.yahooName == yahooName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemName,otherName,stockCode,yahooName);

@override
String toString() {
  return 'StockItem(id: $id, itemName: $itemName, otherName: $otherName, stockCode: $stockCode, yahooName: $yahooName)';
}


}

/// @nodoc
abstract mixin class _$StockItemCopyWith<$Res> implements $StockItemCopyWith<$Res> {
  factory _$StockItemCopyWith(_StockItem value, $Res Function(_StockItem) _then) = __$StockItemCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'itemName') String itemName,@JsonKey(name: 'otherName') String otherName,@JsonKey(name: 'stockCode') String stockCode,@JsonKey(name: 'yahooName') String? yahooName
});




}
/// @nodoc
class __$StockItemCopyWithImpl<$Res>
    implements _$StockItemCopyWith<$Res> {
  __$StockItemCopyWithImpl(this._self, this._then);

  final _StockItem _self;
  final $Res Function(_StockItem) _then;

/// Create a copy of StockItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? itemName = null,Object? otherName = null,Object? stockCode = null,Object? yahooName = freezed,}) {
  return _then(_StockItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,otherName: null == otherName ? _self.otherName : otherName // ignore: cast_nullable_to_non_nullable
as String,stockCode: null == stockCode ? _self.stockCode : stockCode // ignore: cast_nullable_to_non_nullable
as String,yahooName: freezed == yahooName ? _self.yahooName : yahooName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
