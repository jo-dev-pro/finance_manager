// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountImpl _$$AccountImplFromJson(Map<String, dynamic> json) =>
    _$AccountImpl(
      id: json['id'] as String?,
      financialInstitution: json['financial_institution'] as String,
      accountNameId: json['account_name_id'] as String?,
      accountType: json['account_type'] as String,
      accountNumber: json['account_number'] as String?,
      logoUrl: json['logo_url'] as String?,
      status: json['status'] as String? ?? '활동',
    );

Map<String, dynamic> _$$AccountImplToJson(_$AccountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'financial_institution': instance.financialInstitution,
      'account_name_id': instance.accountNameId,
      'account_type': instance.accountType,
      'account_number': instance.accountNumber,
      'logo_url': instance.logoUrl,
      'status': instance.status,
    };
