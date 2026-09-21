// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_transaction_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StockTransactionType _$StockTransactionTypeFromJson(Map<String, dynamic> json) {
  return _StockTransactionType.fromJson(json);
}

/// @nodoc
mixin _$StockTransactionType {
  String? get id => throw _privateConstructorUsedError;
  String get typeName => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this StockTransactionType to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StockTransactionType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockTransactionTypeCopyWith<StockTransactionType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockTransactionTypeCopyWith<$Res> {
  factory $StockTransactionTypeCopyWith(
    StockTransactionType value,
    $Res Function(StockTransactionType) then,
  ) = _$StockTransactionTypeCopyWithImpl<$Res, StockTransactionType>;
  @useResult
  $Res call({String? id, String typeName, String type});
}

/// @nodoc
class _$StockTransactionTypeCopyWithImpl<
  $Res,
  $Val extends StockTransactionType
>
    implements $StockTransactionTypeCopyWith<$Res> {
  _$StockTransactionTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockTransactionType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? typeName = null,
    Object? type = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            typeName:
                null == typeName
                    ? _value.typeName
                    : typeName // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StockTransactionTypeImplCopyWith<$Res>
    implements $StockTransactionTypeCopyWith<$Res> {
  factory _$$StockTransactionTypeImplCopyWith(
    _$StockTransactionTypeImpl value,
    $Res Function(_$StockTransactionTypeImpl) then,
  ) = __$$StockTransactionTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, String typeName, String type});
}

/// @nodoc
class __$$StockTransactionTypeImplCopyWithImpl<$Res>
    extends _$StockTransactionTypeCopyWithImpl<$Res, _$StockTransactionTypeImpl>
    implements _$$StockTransactionTypeImplCopyWith<$Res> {
  __$$StockTransactionTypeImplCopyWithImpl(
    _$StockTransactionTypeImpl _value,
    $Res Function(_$StockTransactionTypeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockTransactionType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? typeName = null,
    Object? type = null,
  }) {
    return _then(
      _$StockTransactionTypeImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        typeName:
            null == typeName
                ? _value.typeName
                : typeName // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StockTransactionTypeImpl implements _StockTransactionType {
  const _$StockTransactionTypeImpl({
    this.id,
    required this.typeName,
    this.type = 'plus',
  });

  factory _$StockTransactionTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockTransactionTypeImplFromJson(json);

  @override
  final String? id;
  @override
  final String typeName;
  @override
  @JsonKey()
  final String type;

  @override
  String toString() {
    return 'StockTransactionType(id: $id, typeName: $typeName, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockTransactionTypeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.typeName, typeName) ||
                other.typeName == typeName) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, typeName, type);

  /// Create a copy of StockTransactionType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockTransactionTypeImplCopyWith<_$StockTransactionTypeImpl>
  get copyWith =>
      __$$StockTransactionTypeImplCopyWithImpl<_$StockTransactionTypeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StockTransactionTypeImplToJson(this);
  }
}

abstract class _StockTransactionType implements StockTransactionType {
  const factory _StockTransactionType({
    final String? id,
    required final String typeName,
    final String type,
  }) = _$StockTransactionTypeImpl;

  factory _StockTransactionType.fromJson(Map<String, dynamic> json) =
      _$StockTransactionTypeImpl.fromJson;

  @override
  String? get id;
  @override
  String get typeName;
  @override
  String get type;

  /// Create a copy of StockTransactionType
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockTransactionTypeImplCopyWith<_$StockTransactionTypeImpl>
  get copyWith => throw _privateConstructorUsedError;
}
