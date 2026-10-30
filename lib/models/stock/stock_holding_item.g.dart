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
  isActive: json['is_active'] as bool? ?? true,
  initialPurchaseDate: json['initial_purchase_date'] as String?,
);

Map<String, dynamic> _$$StockHoldingItemImplToJson(
  _$StockHoldingItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'account_id': instance.accountId,
  'stock_item_id': instance.stockItemId,
  'is_active': instance.isActive,
  'initial_purchase_date': instance.initialPurchaseDate,
};
