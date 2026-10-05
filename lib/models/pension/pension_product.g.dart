// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pension_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String?,
      accountId: json['account_id'] as String,
      productName: json['product_name'] as String,
      status: json['status'] as String? ?? '활동',
      createdAt: const TimestampConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'product_name': instance.productName,
      'status': instance.status,
      'created_at': const TimestampConverter().toJson(instance.createdAt),
    };
