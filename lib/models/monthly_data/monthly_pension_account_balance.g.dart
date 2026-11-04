// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_pension_account_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlyPensionAccountBalanceImpl _$$MonthlyPensionAccountBalanceImplFromJson(
  Map<String, dynamic> json,
) => _$MonthlyPensionAccountBalanceImpl(
  id: json['id'] as String?,
  yearMonth: json['year_month'] as String,
  accountId: json['account_id'] as String,
  accountName: json['account_name'] as String?,
  cashBalance: (json['cash_balance'] as num?)?.toDouble() ?? 0.0,
  monthlyWithdrawal: (json['monthly_withdrawal'] as num?)?.toDouble() ?? 0.0,
  totalWithdrawal: (json['total_withdrawal'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$MonthlyPensionAccountBalanceImplToJson(
  _$MonthlyPensionAccountBalanceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'year_month': instance.yearMonth,
  'account_id': instance.accountId,
  'account_name': instance.accountName,
  'cash_balance': instance.cashBalance,
  'monthly_withdrawal': instance.monthlyWithdrawal,
  'total_withdrawal': instance.totalWithdrawal,
};
