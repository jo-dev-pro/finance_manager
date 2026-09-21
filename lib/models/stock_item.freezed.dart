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
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'symbol_code')
  String get symbolCode => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get market => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'symbol_code') String symbolCode,
    String name,
    String market,
    String? memo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
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
    Object? symbolCode = null,
    Object? name = null,
    Object? market = null,
    Object? memo = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            symbolCode:
                null == symbolCode
                    ? _value.symbolCode
                    : symbolCode // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            market:
                null == market
                    ? _value.market
                    : market // ignore: cast_nullable_to_non_nullable
                        as String,
            memo:
                freezed == memo
                    ? _value.memo
                    : memo // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
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
    @JsonKey(name: 'symbol_code') String symbolCode,
    String name,
    String market,
    String? memo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
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
    Object? symbolCode = null,
    Object? name = null,
    Object? market = null,
    Object? memo = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$StockItemImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        symbolCode:
            null == symbolCode
                ? _value.symbolCode
                : symbolCode // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        market:
            null == market
                ? _value.market
                : market // ignore: cast_nullable_to_non_nullable
                    as String,
        memo:
            freezed == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StockItemImpl implements _StockItem {
  const _$StockItemImpl({
    this.id,
    @JsonKey(name: 'symbol_code') required this.symbolCode,
    required this.name,
    this.market = 'KOSPI',
    this.memo,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$StockItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockItemImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'symbol_code')
  final String symbolCode;
  @override
  final String name;
  @override
  @JsonKey()
  final String market;
  @override
  final String? memo;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'StockItem(id: $id, symbolCode: $symbolCode, name: $name, market: $market, memo: $memo, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.symbolCode, symbolCode) ||
                other.symbolCode == symbolCode) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.market, market) || other.market == market) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, symbolCode, name, market, memo, createdAt);

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
    @JsonKey(name: 'symbol_code') required final String symbolCode,
    required final String name,
    final String market,
    final String? memo,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$StockItemImpl;

  factory _StockItem.fromJson(Map<String, dynamic> json) =
      _$StockItemImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'symbol_code')
  String get symbolCode;
  @override
  String get name;
  @override
  String get market;
  @override
  String? get memo;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of StockItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockItemImplCopyWith<_$StockItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
