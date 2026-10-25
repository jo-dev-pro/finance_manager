// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_holding_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StockHoldingItem _$StockHoldingItemFromJson(Map<String, dynamic> json) {
  return _StockHoldingItem.fromJson(json);
}

/// @nodoc
mixin _$StockHoldingItem {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_id')
  String get accountId => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_item_id')
  String get stockItemId => throw _privateConstructorUsedError;
  double get principal => throw _privateConstructorUsedError; // 초기/누적 투자 원금
  @JsonKey(name: 'purchase_date')
  String? get purchaseDate => throw _privateConstructorUsedError; // 최초 매수일
  bool get isTerminated => throw _privateConstructorUsedError;

  /// Serializes this StockHoldingItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StockHoldingItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockHoldingItemCopyWith<StockHoldingItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockHoldingItemCopyWith<$Res> {
  factory $StockHoldingItemCopyWith(
    StockHoldingItem value,
    $Res Function(StockHoldingItem) then,
  ) = _$StockHoldingItemCopyWithImpl<$Res, StockHoldingItem>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'stock_item_id') String stockItemId,
    double principal,
    @JsonKey(name: 'purchase_date') String? purchaseDate,
    bool isTerminated,
  });
}

/// @nodoc
class _$StockHoldingItemCopyWithImpl<$Res, $Val extends StockHoldingItem>
    implements $StockHoldingItemCopyWith<$Res> {
  _$StockHoldingItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockHoldingItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? accountId = null,
    Object? stockItemId = null,
    Object? principal = null,
    Object? purchaseDate = freezed,
    Object? isTerminated = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            accountId:
                null == accountId
                    ? _value.accountId
                    : accountId // ignore: cast_nullable_to_non_nullable
                        as String,
            stockItemId:
                null == stockItemId
                    ? _value.stockItemId
                    : stockItemId // ignore: cast_nullable_to_non_nullable
                        as String,
            principal:
                null == principal
                    ? _value.principal
                    : principal // ignore: cast_nullable_to_non_nullable
                        as double,
            purchaseDate:
                freezed == purchaseDate
                    ? _value.purchaseDate
                    : purchaseDate // ignore: cast_nullable_to_non_nullable
                        as String?,
            isTerminated:
                null == isTerminated
                    ? _value.isTerminated
                    : isTerminated // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StockHoldingItemImplCopyWith<$Res>
    implements $StockHoldingItemCopyWith<$Res> {
  factory _$$StockHoldingItemImplCopyWith(
    _$StockHoldingItemImpl value,
    $Res Function(_$StockHoldingItemImpl) then,
  ) = __$$StockHoldingItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'stock_item_id') String stockItemId,
    double principal,
    @JsonKey(name: 'purchase_date') String? purchaseDate,
    bool isTerminated,
  });
}

/// @nodoc
class __$$StockHoldingItemImplCopyWithImpl<$Res>
    extends _$StockHoldingItemCopyWithImpl<$Res, _$StockHoldingItemImpl>
    implements _$$StockHoldingItemImplCopyWith<$Res> {
  __$$StockHoldingItemImplCopyWithImpl(
    _$StockHoldingItemImpl _value,
    $Res Function(_$StockHoldingItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockHoldingItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? accountId = null,
    Object? stockItemId = null,
    Object? principal = null,
    Object? purchaseDate = freezed,
    Object? isTerminated = null,
  }) {
    return _then(
      _$StockHoldingItemImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        accountId:
            null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                    as String,
        stockItemId:
            null == stockItemId
                ? _value.stockItemId
                : stockItemId // ignore: cast_nullable_to_non_nullable
                    as String,
        principal:
            null == principal
                ? _value.principal
                : principal // ignore: cast_nullable_to_non_nullable
                    as double,
        purchaseDate:
            freezed == purchaseDate
                ? _value.purchaseDate
                : purchaseDate // ignore: cast_nullable_to_non_nullable
                    as String?,
        isTerminated:
            null == isTerminated
                ? _value.isTerminated
                : isTerminated // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StockHoldingItemImpl implements _StockHoldingItem {
  const _$StockHoldingItemImpl({
    this.id,
    @JsonKey(name: 'account_id') required this.accountId,
    @JsonKey(name: 'stock_item_id') required this.stockItemId,
    this.principal = 0.0,
    @JsonKey(name: 'purchase_date') this.purchaseDate,
    this.isTerminated = false,
  });

  factory _$StockHoldingItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockHoldingItemImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'account_id')
  final String accountId;
  @override
  @JsonKey(name: 'stock_item_id')
  final String stockItemId;
  @override
  @JsonKey()
  final double principal;
  // 초기/누적 투자 원금
  @override
  @JsonKey(name: 'purchase_date')
  final String? purchaseDate;
  // 최초 매수일
  @override
  @JsonKey()
  final bool isTerminated;

  @override
  String toString() {
    return 'StockHoldingItem(id: $id, accountId: $accountId, stockItemId: $stockItemId, principal: $principal, purchaseDate: $purchaseDate, isTerminated: $isTerminated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockHoldingItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.stockItemId, stockItemId) ||
                other.stockItemId == stockItemId) &&
            (identical(other.principal, principal) ||
                other.principal == principal) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.isTerminated, isTerminated) ||
                other.isTerminated == isTerminated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    accountId,
    stockItemId,
    principal,
    purchaseDate,
    isTerminated,
  );

  /// Create a copy of StockHoldingItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockHoldingItemImplCopyWith<_$StockHoldingItemImpl> get copyWith =>
      __$$StockHoldingItemImplCopyWithImpl<_$StockHoldingItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StockHoldingItemImplToJson(this);
  }
}

abstract class _StockHoldingItem implements StockHoldingItem {
  const factory _StockHoldingItem({
    final String? id,
    @JsonKey(name: 'account_id') required final String accountId,
    @JsonKey(name: 'stock_item_id') required final String stockItemId,
    final double principal,
    @JsonKey(name: 'purchase_date') final String? purchaseDate,
    final bool isTerminated,
  }) = _$StockHoldingItemImpl;

  factory _StockHoldingItem.fromJson(Map<String, dynamic> json) =
      _$StockHoldingItemImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'account_id')
  String get accountId;
  @override
  @JsonKey(name: 'stock_item_id')
  String get stockItemId;
  @override
  double get principal; // 초기/누적 투자 원금
  @override
  @JsonKey(name: 'purchase_date')
  String? get purchaseDate; // 최초 매수일
  @override
  bool get isTerminated;

  /// Create a copy of StockHoldingItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockHoldingItemImplCopyWith<_$StockHoldingItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
