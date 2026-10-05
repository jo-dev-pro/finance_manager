// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvestmentImpl _$$InvestmentImplFromJson(Map<String, dynamic> json) =>
    _$InvestmentImpl(
      id: json['id'] as String?,
      description: json['description'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      createdAt: const TimestampConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$$InvestmentImplToJson(_$InvestmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'amount': instance.amount,
      'created_at': const TimestampConverter().toJson(instance.createdAt),
    };
