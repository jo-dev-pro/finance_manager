// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pension_transaction_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PensionTransactionTypeImpl _$$PensionTransactionTypeImplFromJson(
  Map<String, dynamic> json,
) => _$PensionTransactionTypeImpl(
  id: json['id'] as String?,
  name: json['name'] as String,
  amountSign: json['amount_sign'] as String? ?? '+',
  isActive: json['is_active'] as bool? ?? true,
  displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$PensionTransactionTypeImplToJson(
  _$PensionTransactionTypeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'amount_sign': instance.amountSign,
  'is_active': instance.isActive,
  'display_order': instance.displayOrder,
};
