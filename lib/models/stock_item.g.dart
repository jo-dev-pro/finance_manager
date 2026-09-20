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
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$StockItemImplToJson(_$StockItemImpl instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      'symbol_code': instance.symbolCode,
      'name': instance.name,
      'market': instance.market,
      if (instance.memo case final value?) 'memo': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };
