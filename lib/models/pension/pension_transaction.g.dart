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
  accountId: json['account_id'] as String,
  transactionTypeId: json['transaction_type_id'] as String,
  productId: json['product_id'] as String?,
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
  memo: json['memo'] as String?,
  purchaseDate: json['purchase_date'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$PensionTransactionImplToJson(
  _$PensionTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'transaction_date': instance.transactionDate,
  'account_id': instance.accountId,
  'transaction_type_id': instance.transactionTypeId,
  'product_id': instance.productId,
  'amount': instance.amount,
  'memo': instance.memo,
  'purchase_date': instance.purchaseDate,
  'sort_order': instance.sortOrder,
};
