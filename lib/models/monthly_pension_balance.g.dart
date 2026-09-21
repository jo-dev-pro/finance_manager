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
  financialInstitution: json['financial_institution'] as String?,
  accountName: json['account_name'] as String,
  productName: json['product_name'] as String?,
  evaluationAmount: (json['evaluation_amount'] as num?)?.toDouble() ?? 0.0,
  createdAt: const TimestampConverter().fromJson(json['created_at']),
);

Map<String, dynamic> _$$MonthlyPensionBalanceImplToJson(
  _$MonthlyPensionBalanceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'year_month': instance.yearMonth,
  'financial_institution': instance.financialInstitution,
  'account_name': instance.accountName,
  'product_name': instance.productName,
  'evaluation_amount': instance.evaluationAmount,
  'created_at': const TimestampConverter().toJson(instance.createdAt),
};
