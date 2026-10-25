// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_stock_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlyStockBalanceImpl _$$MonthlyStockBalanceImplFromJson(
  Map<String, dynamic> json,
) => _$MonthlyStockBalanceImpl(
  id: json['id'] as String?,
  yearMonth: json['year_month'] as String,
  accountId: json['account_id'] as String,
  stockItemId: json['stock_item_id'] as String,
  quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
  currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
  balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  principal: (json['principal'] as num?)?.toDouble() ?? 0.0,
  totalPayout: (json['total_payout'] as num?)?.toDouble() ?? 0.0,
  totalWithdrawal: (json['total_withdrawal'] as num?)?.toDouble() ?? 0.0,
  purchaseDate: json['purchase_date'] as String?,
);

Map<String, dynamic> _$$MonthlyStockBalanceImplToJson(
  _$MonthlyStockBalanceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'year_month': instance.yearMonth,
  'account_id': instance.accountId,
  'stock_item_id': instance.stockItemId,
  'quantity': instance.quantity,
  'current_price': instance.currentPrice,
  'balance': instance.balance,
  'principal': instance.principal,
  'total_payout': instance.totalPayout,
  'total_withdrawal': instance.totalWithdrawal,
  'purchase_date': instance.purchaseDate,
};
