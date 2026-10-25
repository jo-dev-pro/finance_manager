// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_holding_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockHoldingItemImpl _$$StockHoldingItemImplFromJson(
  Map<String, dynamic> json,
) => _$StockHoldingItemImpl(
  id: json['id'] as String?,
  accountId: json['account_id'] as String,
  stockItemId: json['stock_item_id'] as String,
  principal: (json['principal'] as num?)?.toDouble() ?? 0.0,
  purchaseDate: json['purchase_date'] as String?,
  isTerminated: json['isTerminated'] as bool? ?? false,
);

Map<String, dynamic> _$$StockHoldingItemImplToJson(
  _$StockHoldingItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'account_id': instance.accountId,
  'stock_item_id': instance.stockItemId,
  'principal': instance.principal,
  'purchase_date': instance.purchaseDate,
  'isTerminated': instance.isTerminated,
};
