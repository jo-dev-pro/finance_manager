// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_bank_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlyBankBalanceImpl _$$MonthlyBankBalanceImplFromJson(
  Map<String, dynamic> json,
) => _$MonthlyBankBalanceImpl(
  id: json['id'] as String?,
  yearMonth: json['year_month'] as String,
  financialInstitution: json['financial_institution'] as String,
  accountName: json['account_name'] as String,
  balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$MonthlyBankBalanceImplToJson(
  _$MonthlyBankBalanceImpl instance,
) => <String, dynamic>{
  if (instance.id case final value?) 'id': value,
  'year_month': instance.yearMonth,
  'financial_institution': instance.financialInstitution,
  'account_name': instance.accountName,
  'balance': instance.balance,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};
