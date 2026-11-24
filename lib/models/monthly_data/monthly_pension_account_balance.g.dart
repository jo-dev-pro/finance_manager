// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_pension_account_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MonthlyPensionAccountBalance _$MonthlyPensionAccountBalanceFromJson(
  Map<String, dynamic> json,
) => _MonthlyPensionAccountBalance(
  id: json['id'] as String?,
  yearMonth: json['year_month'] as String,
  accountId: json['account_id'] as String,
  accountName: json['account_name'] as String?,
  cashBalance: (json['cash_balance'] as num?)?.toDouble() ?? 0.0,
  principal: (json['principal'] as num?)?.toDouble() ?? 0.0,
  monthlyPrincipal: (json['monthly_principal'] as num?)?.toDouble() ?? 0.0,
  monthlyWithdrawal: (json['monthly_withdrawal'] as num?)?.toDouble() ?? 0.0,
  totalWithdrawal: (json['total_withdrawal'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$MonthlyPensionAccountBalanceToJson(
  _MonthlyPensionAccountBalance instance,
) => <String, dynamic>{
  'id': instance.id,
  'year_month': instance.yearMonth,
  'account_id': instance.accountId,
  'account_name': instance.accountName,
  'cash_balance': instance.cashBalance,
  'principal': instance.principal,
  'monthly_principal': instance.monthlyPrincipal,
  'monthly_withdrawal': instance.monthlyWithdrawal,
  'total_withdrawal': instance.totalWithdrawal,
};
