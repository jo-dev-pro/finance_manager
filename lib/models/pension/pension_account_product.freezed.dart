// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pension_account_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PensionAccountProduct _$PensionAccountProductFromJson(
  Map<String, dynamic> json,
) {
  return _PensionAccountProduct.fromJson(json);
}

/// @nodoc
mixin _$PensionAccountProduct {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_id')
  String get accountId => throw _privateConstructorUsedError; // 연금 계좌 ID
  @JsonKey(name: 'product_id')
  String get productId => throw _privateConstructorUsedError; // 공용 상품 ID
  double get principal => throw _privateConstructorUsedError; // 투자 원금
  @JsonKey(name: 'purchase_date')
  String? get purchaseDate => throw _privateConstructorUsedError;

  /// Serializes this PensionAccountProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PensionAccountProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PensionAccountProductCopyWith<PensionAccountProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PensionAccountProductCopyWith<$Res> {
  factory $PensionAccountProductCopyWith(
    PensionAccountProduct value,
    $Res Function(PensionAccountProduct) then,
  ) = _$PensionAccountProductCopyWithImpl<$Res, PensionAccountProduct>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'product_id') String productId,
    double principal,
    @JsonKey(name: 'purchase_date') String? purchaseDate,
  });
}

/// @nodoc
class _$PensionAccountProductCopyWithImpl<
  $Res,
  $Val extends PensionAccountProduct
>
    implements $PensionAccountProductCopyWith<$Res> {
  _$PensionAccountProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PensionAccountProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? accountId = null,
    Object? productId = null,
    Object? principal = null,
    Object? purchaseDate = freezed,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PensionAccountProductImplCopyWith<$Res>
    implements $PensionAccountProductCopyWith<$Res> {
  factory _$$PensionAccountProductImplCopyWith(
    _$PensionAccountProductImpl value,
    $Res Function(_$PensionAccountProductImpl) then,
  ) = __$$PensionAccountProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'account_id') String accountId,
    @JsonKey(name: 'product_id') String productId,
    double principal,
    @JsonKey(name: 'purchase_date') String? purchaseDate,
  });
}

/// @nodoc
class __$$PensionAccountProductImplCopyWithImpl<$Res>
    extends
        _$PensionAccountProductCopyWithImpl<$Res, _$PensionAccountProductImpl>
    implements _$$PensionAccountProductImplCopyWith<$Res> {
  __$$PensionAccountProductImplCopyWithImpl(
    _$PensionAccountProductImpl _value,
    $Res Function(_$PensionAccountProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PensionAccountProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? accountId = null,
    Object? productId = null,
    Object? principal = null,
    Object? purchaseDate = freezed,
  }) {
    return _then(
      _$PensionAccountProductImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PensionAccountProductImpl implements _PensionAccountProduct {
  const _$PensionAccountProductImpl({
    this.id,
    @JsonKey(name: 'account_id') required this.accountId,
    @JsonKey(name: 'product_id') required this.productId,
    this.principal = 0.0,
    @JsonKey(name: 'purchase_date') this.purchaseDate,
  });

  factory _$PensionAccountProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$PensionAccountProductImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'account_id')
  final String accountId;
  // 연금 계좌 ID
  @override
  @JsonKey(name: 'product_id')
  final String productId;
  // 공용 상품 ID
  @override
  @JsonKey()
  final double principal;
  // 투자 원금
  @override
  @JsonKey(name: 'purchase_date')
  final String? purchaseDate;

  @override
  String toString() {
    return 'PensionAccountProduct(id: $id, accountId: $accountId, productId: $productId, principal: $principal, purchaseDate: $purchaseDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PensionAccountProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.principal, principal) ||
                other.principal == principal) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    accountId,
    productId,
    principal,
    purchaseDate,
  );

  /// Create a copy of PensionAccountProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PensionAccountProductImplCopyWith<_$PensionAccountProductImpl>
  get copyWith =>
      __$$PensionAccountProductImplCopyWithImpl<_$PensionAccountProductImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PensionAccountProductImplToJson(this);
  }
}

abstract class _PensionAccountProduct implements PensionAccountProduct {
  const factory _PensionAccountProduct({
    final String? id,
    @JsonKey(name: 'account_id') required final String accountId,
    @JsonKey(name: 'product_id') required final String productId,
    final double principal,
    @JsonKey(name: 'purchase_date') final String? purchaseDate,
  }) = _$PensionAccountProductImpl;

  factory _PensionAccountProduct.fromJson(Map<String, dynamic> json) =
      _$PensionAccountProductImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'account_id')
  String get accountId; // 연금 계좌 ID
  @override
  @JsonKey(name: 'product_id')
  String get productId; // 공용 상품 ID
  @override
  double get principal; // 투자 원금
  @override
  @JsonKey(name: 'purchase_date')
  String? get purchaseDate;

  /// Create a copy of PensionAccountProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PensionAccountProductImplCopyWith<_$PensionAccountProductImpl>
  get copyWith => throw _privateConstructorUsedError;
}
