import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_stock_balance.freezed.dart';
part 'monthly_stock_balance.g.dart';

@freezed
class MonthlyStockBalance with _$MonthlyStockBalance {
  const MonthlyStockBalance._();

  const factory MonthlyStockBalance({
    String? id,
    @JsonKey(name: 'year_month') required String yearMonth,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'stock_item_id') required String stockItemId,
    @Default(0.0) double quantity,                        // 당월 말 보유 수량
    @JsonKey(name: 'current_price') @Default(0.0) double currentPrice, // 당월 말 현재가
    @Default(0.0) double balance,                         // 당월 말 평가액
    @Default(0.0) double principal,                       // 누적 투자 원금
    @JsonKey(name: 'total_payout') @Default(0.0) double totalPayout, // 누적 배당금 등 수령액
    @JsonKey(name: 'total_withdrawal') @Default(0.0) double totalWithdrawal, // 💡 누적 인출액
    @JsonKey(name: 'purchase_date') String? purchaseDate, // 최초 매수일
  }) = _MonthlyStockBalance;

  factory MonthlyStockBalance.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStockBalanceFromJson(json);

  // 💡 [총 평가 손익] = (현재 평가액 + 누적 수령액 + 누적 인출액) - 누적 투자 원금
  double get profitOrLoss => (balance + totalPayout + totalWithdrawal) - principal;

  // 💡 [누적 수익률 (%)]
  double get returnRate =>
      principal > 0 ? (profitOrLoss / principal) * 100 : 0.0;

  // 평균 단가
  double get averagePurchasePrice =>
      quantity > 0 ? principal / quantity : 0.0;

  // 연환산 수익률 (CAGR %)
  double get annualizedReturnRate {
    if (principal <= 0 || purchaseDate == null || purchaseDate!.isEmpty) {
      return 0.0;
    }

    try {
      final buyDate = DateTime.parse(purchaseDate!);
      final ymParts = yearMonth.split('-');
      final evalDate = DateTime(
        int.parse(ymParts[0]),
        int.parse(ymParts[1]) + 1,
        0,
      );

      final days = evalDate.difference(buyDate).inDays;
      if (days <= 0) return returnRate;

      final years = days / 365.0;
      final totalValue = balance + totalPayout + totalWithdrawal; // 인출액 및 수령액 포함
      final totalRatio = totalValue / principal;

      if (totalRatio <= 0) return -100.0;

      final cagr = (pow(totalRatio, 1.0 / years) - 1.0) * 100;
      return cagr.toDouble();
    } catch (_) {
      return 0.0;
    }
  }
}