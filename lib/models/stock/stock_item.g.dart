// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockItemImpl _$$StockItemImplFromJson(Map<String, dynamic> json) =>
    _$StockItemImpl(
      id: json['id'] as String?,
      symbolCode: json['symbol_code'] as String,
      name: json['name'] as String,
      market: json['market'] as String? ?? 'KOSPI',
      memo: json['memo'] as String?,
    );

Map<String, dynamic> _$$StockItemImplToJson(_$StockItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbol_code': instance.symbolCode,
      'name': instance.name,
      'market': instance.market,
      'memo': instance.memo,
    };
