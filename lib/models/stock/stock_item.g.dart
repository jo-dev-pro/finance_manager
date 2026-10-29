// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockItemImpl _$$StockItemImplFromJson(Map<String, dynamic> json) =>
    _$StockItemImpl(
      id: json['id'] as String?,
      itemName: json['itemName'] as String,
      otherName: json['otherName'] as String?,
      stockCode: json['stockCode'] as String,
      yahooName: json['yahooName'] as String?,
    );

Map<String, dynamic> _$$StockItemImplToJson(_$StockItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemName': instance.itemName,
      'otherName': instance.otherName,
      'stockCode': instance.stockCode,
      'yahooName': instance.yahooName,
    };
