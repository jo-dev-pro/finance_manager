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
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$PensionTransactionTypeImplToJson(
  _$PensionTransactionTypeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'displayOrder': instance.displayOrder,
  'isActive': instance.isActive,
};
