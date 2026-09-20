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
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$InvestmentImplToJson(_$InvestmentImpl instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      'description': instance.description,
      'amount': instance.amount,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };
