// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pension_holding_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PensionHoldingProduct _$PensionHoldingProductFromJson(
  Map<String, dynamic> json,
) {
  return _PensionHoldingProduct.fromJson(json);
}

/// @nodoc
mixin _$PensionHoldingProduct {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_id')
  String get accountId => throw _privateConstructorUsedError; // 연금 계좌 ID[cite: 6]
  @JsonKey(name: 'product_id')
  String get productId => throw _privateConstructorUsedError; // 공용 상품 ID[cite: 6]
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError; // 활동 / 비활동 여부[cite: 6]
  @JsonKey(name: 'initial_purchase_date')
  String? get initialPurchaseDate => throw _privateConstructorUsedError;

  /// Serializes this PensionHoldingProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PensionHoldingProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PensionHoldingProductCopyWith<PensionHoldingProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PensionHoldingProductCopyWith<$Res> {
  factory $PensionHoldingProductCopyWith(
    PensionHoldingProduct value,
    $Res Function(PensionHoldingProduct) then,
  ) = _$PensionHoldingProductCopyWithImpl<$Res, PensionHoldingProduct>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'product_id') String productId,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'initial_purchase_date') String? initialPurchaseDate,
  });
}

/// @nodoc
class _$PensionHoldingProductCopyWithImpl<
  $Res,
  $Val extends PensionHoldingProduct
>
    implements $PensionHoldingProductCopyWith<$Res> {
  _$PensionHoldingProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PensionHoldingProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? accountId = null,
    Object? productId = null,
    Object? isActive = null,
    Object? initialPurchaseDate = freezed,
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
            productId:
                null == productId
                    ? _value.productId
                    : productId // ignore: cast_nullable_to_non_nullable
                        as String,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
            initialPurchaseDate:
                freezed == initialPurchaseDate
                    ? _value.initialPurchaseDate
                    : initialPurchaseDate // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PensionHoldingProductImplCopyWith<$Res>
    implements $PensionHoldingProductCopyWith<$Res> {
  factory _$$PensionHoldingProductImplCopyWith(
    _$PensionHoldingProductImpl value,
    $Res Function(_$PensionHoldingProductImpl) then,
  ) = __$$PensionHoldingProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'product_id') String productId,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'initial_purchase_date') String? initialPurchaseDate,
  });
}

/// @nodoc
class __$$PensionHoldingProductImplCopyWithImpl<$Res>
    extends
        _$PensionHoldingProductCopyWithImpl<$Res, _$PensionHoldingProductImpl>
    implements _$$PensionHoldingProductImplCopyWith<$Res> {
  __$$PensionHoldingProductImplCopyWithImpl(
    _$PensionHoldingProductImpl _value,
    $Res Function(_$PensionHoldingProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PensionHoldingProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? accountId = null,
    Object? productId = null,
    Object? isActive = null,
    Object? initialPurchaseDate = freezed,
  }) {
    return _then(
      _$PensionHoldingProductImpl(
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
        productId:
            null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                    as String,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
        initialPurchaseDate:
            freezed == initialPurchaseDate
                ? _value.initialPurchaseDate
                : initialPurchaseDate // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PensionHoldingProductImpl extends _PensionHoldingProduct {
  const _$PensionHoldingProductImpl({
    this.id,
    @JsonKey(name: 'account_id') required this.accountId,
    @JsonKey(name: 'product_id') required this.productId,
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'initial_purchase_date') this.initialPurchaseDate,
  }) : super._();

  factory _$PensionHoldingProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$PensionHoldingProductImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'account_id')
  final String accountId;
  // 연금 계좌 ID[cite: 6]
  @override
  @JsonKey(name: 'product_id')
  final String productId;
  // 공용 상품 ID[cite: 6]
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  // 활동 / 비활동 여부[cite: 6]
  @override
  @JsonKey(name: 'initial_purchase_date')
  final String? initialPurchaseDate;

  @override
  String toString() {
    return 'PensionHoldingProduct(id: $id, accountId: $accountId, productId: $productId, isActive: $isActive, initialPurchaseDate: $initialPurchaseDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PensionHoldingProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.initialPurchaseDate, initialPurchaseDate) ||
                other.initialPurchaseDate == initialPurchaseDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    accountId,
    productId,
    isActive,
    initialPurchaseDate,
  );

  /// Create a copy of PensionHoldingProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PensionHoldingProductImplCopyWith<_$PensionHoldingProductImpl>
  get copyWith =>
      __$$PensionHoldingProductImplCopyWithImpl<_$PensionHoldingProductImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PensionHoldingProductImplToJson(this);
  }
}

abstract class _PensionHoldingProduct extends PensionHoldingProduct {
  const factory _PensionHoldingProduct({
    final String? id,
    @JsonKey(name: 'account_id') required final String accountId,
    @JsonKey(name: 'product_id') required final String productId,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'initial_purchase_date') final String? initialPurchaseDate,
  }) = _$PensionHoldingProductImpl;
  const _PensionHoldingProduct._() : super._();

  factory _PensionHoldingProduct.fromJson(Map<String, dynamic> json) =
      _$PensionHoldingProductImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'account_id')
  String get accountId; // 연금 계좌 ID[cite: 6]
  @override
  @JsonKey(name: 'product_id')
  String get productId; // 공용 상품 ID[cite: 6]
  @override
  @JsonKey(name: 'is_active')
  bool get isActive; // 활동 / 비활동 여부[cite: 6]
  @override
  @JsonKey(name: 'initial_purchase_date')
  String? get initialPurchaseDate;

  /// Create a copy of PensionHoldingProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PensionHoldingProductImplCopyWith<_$PensionHoldingProductImpl>
  get copyWith => throw _privateConstructorUsedError;
}
