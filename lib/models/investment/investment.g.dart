// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Investment _$InvestmentFromJson(Map<String, dynamic> json) => _Investment(
  id: json['id'] as String?,
  description: json['description'] as String,
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$InvestmentToJson(_Investment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'amount': instance.amount,
      'created_at': instance.createdAt,
    };
