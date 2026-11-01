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
  accountName: json['account_name'] as String?,
  stockItemName: json['stock_item_name'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  initialPurchaseDate: json['initial_purchase_date'] as String?,
);

Map<String, dynamic> _$$StockHoldingItemImplToJson(
  _$StockHoldingItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'account_id': instance.accountId,
  'stock_item_id': instance.stockItemId,
  'account_name': instance.accountName,
  'stock_item_name': instance.stockItemName,
  'is_active': instance.isActive,
  'initial_purchase_date': instance.initialPurchaseDate,
};
