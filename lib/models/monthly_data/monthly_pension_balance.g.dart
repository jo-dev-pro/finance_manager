// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_pension_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MonthlyPensionBalance _$MonthlyPensionBalanceFromJson(
  Map<String, dynamic> json,
) => _MonthlyPensionBalance(
  id: json['id'] as String?,
  yearMonth: json['year_month'] as String,
  accountId: json['account_id'] as String,
  productId: json['product_id'] as String,
  accountName: json['account_name'] as String?,
  productName: json['product_name'] as String?,
  balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  principal: (json['principal'] as num?)?.toDouble() ?? 0.0,
  monthlyPrincipal: (json['monthly_principal'] as num?)?.toDouble() ?? 0.0,
  totalSale: (json['total_sale'] as num?)?.toDouble() ?? 0.0,
  monthlySale: (json['monthly_sale'] as num?)?.toDouble() ?? 0.0,
  purchaseDate: json['purchase_date'] as String?,
);

Map<String, dynamic> _$MonthlyPensionBalanceToJson(
  _MonthlyPensionBalance instance,
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
  'total_sale': instance.totalSale,
  'monthly_sale': instance.monthlySale,
  'purchase_date': instance.purchaseDate,
};
