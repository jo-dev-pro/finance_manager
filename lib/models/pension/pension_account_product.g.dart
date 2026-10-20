// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pension_account_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PensionAccountProductImpl _$$PensionAccountProductImplFromJson(
  Map<String, dynamic> json,
) => _$PensionAccountProductImpl(
  id: json['id'] as String?,
  accountId: json['account_id'] as String,
  productId: json['product_id'] as String,
  principal: (json['principal'] as num?)?.toDouble() ?? 0.0,
  purchaseDate: json['purchase_date'] as String?,
);

Map<String, dynamic> _$$PensionAccountProductImplToJson(
  _$PensionAccountProductImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'account_id': instance.accountId,
  'product_id': instance.productId,
  'principal': instance.principal,
  'purchase_date': instance.purchaseDate,
};
