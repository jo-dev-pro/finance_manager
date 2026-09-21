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
  createdAt: const TimestampConverter().fromJson(json['created_at']),
);

Map<String, dynamic> _$$MonthlyBankBalanceImplToJson(
  _$MonthlyBankBalanceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'year_month': instance.yearMonth,
  'financial_institution': instance.financialInstitution,
  'account_name': instance.accountName,
  'balance': instance.balance,
  'created_at': const TimestampConverter().toJson(instance.createdAt),
};
