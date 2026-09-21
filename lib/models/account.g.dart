// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountImpl _$$AccountImplFromJson(Map<String, dynamic> json) =>
    _$AccountImpl(
      id: json['id'] as String?,
      financialInstitution: json['financial_institution'] as String,
      accountType: json['account_type'] as String,
      logoUrl: json['logo_url'] as String?,
      accountName: json['account_name'] as String,
      status: json['status'] as String? ?? '활동',
      createdAt: const TimestampConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$$AccountImplToJson(_$AccountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'financial_institution': instance.financialInstitution,
      'account_type': instance.accountType,
      'logo_url': instance.logoUrl,
      'account_name': instance.accountName,
      'status': instance.status,
      'created_at': const TimestampConverter().toJson(instance.createdAt),
    };
