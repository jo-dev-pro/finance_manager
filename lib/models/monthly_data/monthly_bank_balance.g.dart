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
  accountId: json['account_id'] as String,
  balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$MonthlyBankBalanceImplToJson(
  _$MonthlyBankBalanceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'year_month': instance.yearMonth,
  'account_id': instance.accountId,
  'balance': instance.balance,
};
