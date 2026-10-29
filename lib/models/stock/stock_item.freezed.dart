// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StockItem _$StockItemFromJson(Map<String, dynamic> json) {
  return _StockItem.fromJson(json);
}

/// @nodoc
mixin _$StockItem {
  String? get id => throw _privateConstructorUsedError; // 문서 ID (docId) 매핑용
  @JsonKey(name: 'itemName')
  String get itemName => throw _privateConstructorUsedError; // 종목명 (예: 노바텍)
  @JsonKey(name: 'otherName')
  String? get otherName => throw _privateConstructorUsedError; // 기타 이름
  @JsonKey(name: 'stockCode')
  String get stockCode => throw _privateConstructorUsedError; // 종목 코드 (예: 285490)
  @JsonKey(name: 'yahooName')
  String? get yahooName => throw _privateConstructorUsedError;

  /// Serializes this StockItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StockItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockItemCopyWith<StockItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockItemCopyWith<$Res> {
  factory $StockItemCopyWith(StockItem value, $Res Function(StockItem) then) =
      _$StockItemCopyWithImpl<$Res, StockItem>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'itemName') String itemName,
    @JsonKey(name: 'otherName') String? otherName,
    @JsonKey(name: 'stockCode') String stockCode,
    @JsonKey(name: 'yahooName') String? yahooName,
  });
}

/// @nodoc
class _$StockItemCopyWithImpl<$Res, $Val extends StockItem>
    implements $StockItemCopyWith<$Res> {
  _$StockItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? itemName = null,
    Object? otherName = freezed,
    Object? stockCode = null,
    Object? yahooName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            itemName:
                null == itemName
                    ? _value.itemName
                    : itemName // ignore: cast_nullable_to_non_nullable
                        as String,
            otherName:
                freezed == otherName
                    ? _value.otherName
                    : otherName // ignore: cast_nullable_to_non_nullable
                        as String?,
            stockCode:
                null == stockCode
                    ? _value.stockCode
                    : stockCode // ignore: cast_nullable_to_non_nullable
                        as String,
            yahooName:
                freezed == yahooName
                    ? _value.yahooName
                    : yahooName // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StockItemImplCopyWith<$Res>
    implements $StockItemCopyWith<$Res> {
  factory _$$StockItemImplCopyWith(
    _$StockItemImpl value,
    $Res Function(_$StockItemImpl) then,
  ) = __$$StockItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'itemName') String itemName,
    @JsonKey(name: 'otherName') String? otherName,
    @JsonKey(name: 'stockCode') String stockCode,
    @JsonKey(name: 'yahooName') String? yahooName,
  });
}

/// @nodoc
class __$$StockItemImplCopyWithImpl<$Res>
    extends _$StockItemCopyWithImpl<$Res, _$StockItemImpl>
    implements _$$StockItemImplCopyWith<$Res> {
  __$$StockItemImplCopyWithImpl(
    _$StockItemImpl _value,
    $Res Function(_$StockItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? itemName = null,
    Object? otherName = freezed,
    Object? stockCode = null,
    Object? yahooName = freezed,
  }) {
    return _then(
      _$StockItemImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        itemName:
            null == itemName
                ? _value.itemName
                : itemName // ignore: cast_nullable_to_non_nullable
                    as String,
        otherName:
            freezed == otherName
                ? _value.otherName
                : otherName // ignore: cast_nullable_to_non_nullable
                    as String?,
        stockCode:
            null == stockCode
                ? _value.stockCode
                : stockCode // ignore: cast_nullable_to_non_nullable
                    as String,
        yahooName:
            freezed == yahooName
                ? _value.yahooName
                : yahooName // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StockItemImpl implements _StockItem {
  const _$StockItemImpl({
    this.id,
    @JsonKey(name: 'itemName') required this.itemName,
    @JsonKey(name: 'otherName') this.otherName,
    @JsonKey(name: 'stockCode') required this.stockCode,
    @JsonKey(name: 'yahooName') this.yahooName,
  });

  factory _$StockItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockItemImplFromJson(json);

  @override
  final String? id;
  // 문서 ID (docId) 매핑용
  @override
  @JsonKey(name: 'itemName')
  final String itemName;
  // 종목명 (예: 노바텍)
  @override
  @JsonKey(name: 'otherName')
  final String? otherName;
  // 기타 이름
  @override
  @JsonKey(name: 'stockCode')
  final String stockCode;
  // 종목 코드 (예: 285490)
  @override
  @JsonKey(name: 'yahooName')
  final String? yahooName;

  @override
  String toString() {
    return 'StockItem(id: $id, itemName: $itemName, otherName: $otherName, stockCode: $stockCode, yahooName: $yahooName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.otherName, otherName) ||
                other.otherName == otherName) &&
            (identical(other.stockCode, stockCode) ||
                other.stockCode == stockCode) &&
            (identical(other.yahooName, yahooName) ||
                other.yahooName == yahooName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, itemName, otherName, stockCode, yahooName);

  /// Create a copy of StockItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockItemImplCopyWith<_$StockItemImpl> get copyWith =>
      __$$StockItemImplCopyWithImpl<_$StockItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StockItemImplToJson(this);
  }
}

abstract class _StockItem implements StockItem {
  const factory _StockItem({
    final String? id,
    @JsonKey(name: 'itemName') required final String itemName,
    @JsonKey(name: 'otherName') final String? otherName,
    @JsonKey(name: 'stockCode') required final String stockCode,
    @JsonKey(name: 'yahooName') final String? yahooName,
  }) = _$StockItemImpl;

  factory _StockItem.fromJson(Map<String, dynamic> json) =
      _$StockItemImpl.fromJson;

  @override
  String? get id; // 문서 ID (docId) 매핑용
  @override
  @JsonKey(name: 'itemName')
  String get itemName; // 종목명 (예: 노바텍)
  @override
  @JsonKey(name: 'otherName')
  String? get otherName; // 기타 이름
  @override
  @JsonKey(name: 'stockCode')
  String get stockCode; // 종목 코드 (예: 285490)
  @override
  @JsonKey(name: 'yahooName')
  String? get yahooName;

  /// Create a copy of StockItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockItemImplCopyWith<_$StockItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
