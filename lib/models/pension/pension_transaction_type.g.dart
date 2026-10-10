// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pension_transaction_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PensionTransactionTypeImpl _$$PensionTransactionTypeImplFromJson(
  Map<String, dynamic> json,
) => _$PensionTransactionTypeImpl(
  id: json['id'] as String?,
  typeName: json['typeName'] as String,
  amountSign: json['amount_sign'] as String? ?? '+',
);

Map<String, dynamic> _$$PensionTransactionTypeImplToJson(
  _$PensionTransactionTypeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'typeName': instance.typeName,
  'amount_sign': instance.amountSign,
};
