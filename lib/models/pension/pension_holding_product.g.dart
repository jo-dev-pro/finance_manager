// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pension_holding_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PensionHoldingProduct _$PensionHoldingProductFromJson(
  Map<String, dynamic> json,
) => _PensionHoldingProduct(
  id: json['id'] as String?,
  accountId: json['account_id'] as String,
  productId: json['product_id'] as String,
  accountName: json['account_name'] as String?,
  productName: json['product_name'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  initialPurchaseDate: json['initial_purchase_date'] as String?,
);

Map<String, dynamic> _$PensionHoldingProductToJson(
  _PensionHoldingProduct instance,
) => <String, dynamic>{
  'id': instance.id,
  'account_id': instance.accountId,
  'product_id': instance.productId,
  'account_name': instance.accountName,
  'product_name': instance.productName,
  'is_active': instance.isActive,
  'initial_purchase_date': instance.initialPurchaseDate,
};
