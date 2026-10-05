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
  amountSign: json['amountSign'] as String,
  quantitySign: json['quantitySign'] as String,
);

Map<String, dynamic> _$$StockTransactionTypeImplToJson(
  _$StockTransactionTypeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'typeName': instance.typeName,
  'amountSign': instance.amountSign,
  'quantitySign': instance.quantitySign,
};
