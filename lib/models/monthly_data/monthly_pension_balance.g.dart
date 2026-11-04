// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_pension_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlyPensionBalanceImpl _$$MonthlyPensionBalanceImplFromJson(
  Map<String, dynamic> json,
) => _$MonthlyPensionBalanceImpl(
  id: json['id'] as String?,
  yearMonth: json['year_month'] as String,
  accountId: json['account_id'] as String,
  productId: json['product_id'] as String,
  accountName: json['account_name'] as String?,
  productName: json['product_name'] as String?,
  balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  principal: (json['principal'] as num?)?.toDouble() ?? 0.0,
  monthlyPrincipal: (json['monthly_principal'] as num?)?.toDouble() ?? 0.0,
  totalPayout: (json['total_payout'] as num?)?.toDouble() ?? 0.0,
  monthlyPayout: (json['monthly_payout'] as num?)?.toDouble() ?? 0.0,
  totalWithdrawal: (json['total_withdrawal'] as num?)?.toDouble() ?? 0.0,
  monthlyWithdrawal: (json['monthly_withdrawal'] as num?)?.toDouble() ?? 0.0,
  purchaseDate: json['purchase_date'] as String?,
);

Map<String, dynamic> _$$MonthlyPensionBalanceImplToJson(
  _$MonthlyPensionBalanceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'year_month': instance.yearMonth,
  'account_id': instance.accountId,
  'product_id': instance.productId,
  'account_name': instance.accountName,
  'product_name': instance.productName,
  'balance': instance.balance,
  'principal': instance.principal,
  'monthly_principal': instance.monthlyPrincipal,
  'total_payout': instance.totalPayout,
  'monthly_payout': instance.monthlyPayout,
  'total_withdrawal': instance.totalWithdrawal,
  'monthly_withdrawal': instance.monthlyWithdrawal,
  'purchase_date': instance.purchaseDate,
};
