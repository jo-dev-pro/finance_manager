// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_transaction_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockTransactionTypeImpl _$$StockTransactionTypeImplFromJson(
  Map<String, dynamic> json,
) => _$StockTransactionTypeImpl(
  id: json['id'] as String?,
  typeName: json['typeName'] as String,
  type: json['type'] as String? ?? 'plus',
);

Map<String, dynamic> _$$StockTransactionTypeImplToJson(
  _$StockTransactionTypeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'typeName': instance.typeName,
  'type': instance.type,
};
