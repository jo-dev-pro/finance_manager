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
  balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$MonthlyPensionBalanceImplToJson(
  _$MonthlyPensionBalanceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'year_month': instance.yearMonth,
  'account_id': instance.accountId,
  'product_id': instance.productId,
  'balance': instance.balance,
};
