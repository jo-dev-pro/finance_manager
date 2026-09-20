// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  id: json['id'] as String?,
  financialInstitution: json['financial_institution'] as String,
  accountType: json['account_type'] as String,
  logoUrl: json['logo_url'] as String?,
  accountName: json['account_name'] as String,
  status: json['status'] as String,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  if (instance.id case final value?) 'id': value,
  'financial_institution': instance.financialInstitution,
  'account_type': instance.accountType,
  if (instance.logoUrl case final value?) 'logo_url': value,
  'account_name': instance.accountName,
  'status': instance.status,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};

_$AccountImpl _$$AccountImplFromJson(Map<String, dynamic> json) =>
    _$AccountImpl(
      id: json['id'] as String?,
      financialInstitution: json['financial_institution'] as String,
      accountType: json['account_type'] as String,
      logoUrl: json['logo_url'] as String?,
      accountName: json['account_name'] as String,
      status: json['status'] as String? ?? '활동',
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$AccountImplToJson(_$AccountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'financial_institution': instance.financialInstitution,
      'account_type': instance.accountType,
      'logo_url': instance.logoUrl,
      'account_name': instance.accountName,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
    };
