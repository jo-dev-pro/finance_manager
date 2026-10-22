// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pension_holding_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PensionHoldingProductImpl _$$PensionHoldingProductImplFromJson(
  Map<String, dynamic> json,
) => _$PensionHoldingProductImpl(
  id: json['id'] as String?,
  accountId: json['account_id'] as String,
  productId: json['product_id'] as String,
  principal: (json['principal'] as num?)?.toDouble() ?? 0.0,
  purchaseDate: json['purchase_date'] as String?,
  totalPayout: (json['total_payout'] as num?)?.toDouble() ?? 0.0,
  isTerminated: json['is_terminated'] as bool? ?? false,
);

Map<String, dynamic> _$$PensionHoldingProductImplToJson(
  _$PensionHoldingProductImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'account_id': instance.accountId,
  'product_id': instance.productId,
  'principal': instance.principal,
  'purchase_date': instance.purchaseDate,
  'total_payout': instance.totalPayout,
  'is_terminated': instance.isTerminated,
};
