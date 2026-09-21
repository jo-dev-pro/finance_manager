// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pension_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PensionTransactionImpl _$$PensionTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$PensionTransactionImpl(
  id: json['id'] as String?,
  transactionDate: json['transaction_date'] as String,
  financialInstitution: json['financial_institution'] as String?,
  accountName: json['account_name'] as String,
  productName: json['product_name'] as String?,
  transactionType: json['transaction_type'] as String,
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
  memo: json['memo'] as String?,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$PensionTransactionImplToJson(
  _$PensionTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'transaction_date': instance.transactionDate,
  'financial_institution': instance.financialInstitution,
  'account_name': instance.accountName,
  'product_name': instance.productName,
  'transaction_type': instance.transactionType,
  'amount': instance.amount,
  'memo': instance.memo,
  'created_at': instance.createdAt?.toIso8601String(),
};
