// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pension_transaction_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PensionTransactionType _$PensionTransactionTypeFromJson(
  Map<String, dynamic> json,
) {
  return _PensionTransactionType.fromJson(json);
}

/// @nodoc
mixin _$PensionTransactionType {
  String? get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_sign')
  String get amountSign => throw _privateConstructorUsedError; // 💡 금액 부호 (+ 또는 -)
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_order')
  int get displayOrder => throw _privateConstructorUsedError;

  /// Serializes this PensionTransactionType to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PensionTransactionType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PensionTransactionTypeCopyWith<PensionTransactionType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PensionTransactionTypeCopyWith<$Res> {
  factory $PensionTransactionTypeCopyWith(
    PensionTransactionType value,
    $Res Function(PensionTransactionType) then,
  ) = _$PensionTransactionTypeCopyWithImpl<$Res, PensionTransactionType>;
  @useResult
  $Res call({
    String? id,
    String name,
    @JsonKey(name: 'amount_sign') String amountSign,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'display_order') int displayOrder,
  });
}

/// @nodoc
class _$PensionTransactionTypeCopyWithImpl<
  $Res,
  $Val extends PensionTransactionType
>
    implements $PensionTransactionTypeCopyWith<$Res> {
  _$PensionTransactionTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PensionTransactionType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? amountSign = null,
    Object? isActive = null,
    Object? displayOrder = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            amountSign:
                null == amountSign
                    ? _value.amountSign
                    : amountSign // ignore: cast_nullable_to_non_nullable
                        as String,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
            displayOrder:
                null == displayOrder
                    ? _value.displayOrder
                    : displayOrder // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PensionTransactionTypeImplCopyWith<$Res>
    implements $PensionTransactionTypeCopyWith<$Res> {
  factory _$$PensionTransactionTypeImplCopyWith(
    _$PensionTransactionTypeImpl value,
    $Res Function(_$PensionTransactionTypeImpl) then,
  ) = __$$PensionTransactionTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String name,
    @JsonKey(name: 'amount_sign') String amountSign,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'display_order') int displayOrder,
  });
}

/// @nodoc
class __$$PensionTransactionTypeImplCopyWithImpl<$Res>
    extends
        _$PensionTransactionTypeCopyWithImpl<$Res, _$PensionTransactionTypeImpl>
    implements _$$PensionTransactionTypeImplCopyWith<$Res> {
  __$$PensionTransactionTypeImplCopyWithImpl(
    _$PensionTransactionTypeImpl _value,
    $Res Function(_$PensionTransactionTypeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PensionTransactionType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? amountSign = null,
    Object? isActive = null,
    Object? displayOrder = null,
  }) {
    return _then(
      _$PensionTransactionTypeImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        amountSign:
            null == amountSign
                ? _value.amountSign
                : amountSign // ignore: cast_nullable_to_non_nullable
                    as String,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
        displayOrder:
            null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PensionTransactionTypeImpl implements _PensionTransactionType {
  const _$PensionTransactionTypeImpl({
    this.id,
    required this.name,
    @JsonKey(name: 'amount_sign') this.amountSign = '+',
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'display_order') this.displayOrder = 0,
  });

  factory _$PensionTransactionTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PensionTransactionTypeImplFromJson(json);

  @override
  final String? id;
  @override
  final String name;
  @override
  @JsonKey(name: 'amount_sign')
  final String amountSign;
  // 💡 금액 부호 (+ 또는 -)
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'display_order')
  final int displayOrder;

  @override
  String toString() {
    return 'PensionTransactionType(id: $id, name: $name, amountSign: $amountSign, isActive: $isActive, displayOrder: $displayOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PensionTransactionTypeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amountSign, amountSign) ||
                other.amountSign == amountSign) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, amountSign, isActive, displayOrder);

  /// Create a copy of PensionTransactionType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PensionTransactionTypeImplCopyWith<_$PensionTransactionTypeImpl>
  get copyWith =>
      __$$PensionTransactionTypeImplCopyWithImpl<_$PensionTransactionTypeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PensionTransactionTypeImplToJson(this);
  }
}

abstract class _PensionTransactionType implements PensionTransactionType {
  const factory _PensionTransactionType({
    final String? id,
    required final String name,
    @JsonKey(name: 'amount_sign') final String amountSign,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'display_order') final int displayOrder,
  }) = _$PensionTransactionTypeImpl;

  factory _PensionTransactionType.fromJson(Map<String, dynamic> json) =
      _$PensionTransactionTypeImpl.fromJson;

  @override
  String? get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'amount_sign')
  String get amountSign; // 💡 금액 부호 (+ 또는 -)
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'display_order')
  int get displayOrder;

  /// Create a copy of PensionTransactionType
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PensionTransactionTypeImplCopyWith<_$PensionTransactionTypeImpl>
  get copyWith => throw _privateConstructorUsedError;
}
