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
    @JsonKey(name: 'account_name') String? accountName,       // 💡 콘솔 확인용 계좌명 추가
    @JsonKey(name: 'stock_item_name') String? stockItemName, // 💡 콘솔 확인용 주식 종목명 추가

    @Default(0.0) double quantity, // 당월 말 보유 수량
    @JsonKey(name: 'current_price') @Default(0.0) double currentPrice, // 당월 말 현재가
    @Default(0.0) double balance, // 당월 말 평가액 (quantity * currentPrice)

    // 1. 투자 원금 (누적 및 당월분)
    @Default(0.0) double principal, // 누적 투자 원금
    @JsonKey(name: 'monthly_principal') @Default(0.0) double monthlyPrincipal, // 당월 추가 매수/입금 원금

    // 2. 배당금 및 기타 수령액 (누적 및 당월분)
    @JsonKey(name: 'total_payout') @Default(0.0) double totalPayout, // 누적 배당금/수령액
    @JsonKey(name: 'monthly_payout') @Default(0.0) double monthlyPayout, // 당월 배당금/수령액

    // 3. 매도 및 인출액 (누적 및 당월분)
    @JsonKey(name: 'total_withdrawal') @Default(0.0) double totalWithdrawal, // 누적 매도/인출액
    @JsonKey(name: 'monthly_withdrawal') @Default(0.0) double monthlyWithdrawal, // 당월 매도/인출액

    @JsonKey(name: 'purchase_date') String? purchaseDate, // 최초 매수일 (마스터 연동)
  }) = _MonthlyStockBalance;

  factory MonthlyStockBalance.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStockBalanceFromJson(json);

  // [총 평가 손익] = (현재 평가액 + 누적 배당수령액 + 누적 매도인출액) - 누적 투자 원금[cite: 11]
  double get profitOrLoss => (balance + totalPayout + totalWithdrawal) - principal;

  // [누적 수익률 (%)][cite: 11]
  double get returnRate =>
      principal > 0 ? (profitOrLoss / principal) * 100 : 0.0;

  // [평균 단가]
  double get averagePurchasePrice =>
      quantity > 0 ? principal / quantity : 0.0;

  // [연환산 수익률 (CAGR %)] - 최초 매수일 기준 고정 산출[cite: 11]
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
      final totalValue = balance + totalPayout + totalWithdrawal;
      final totalRatio = totalValue / principal;

      if (totalRatio <= 0) return -100.0;

      final cagr = (pow(totalRatio, 1.0 / years) - 1.0) * 100;
      return cagr.toDouble();
    } catch (_) {
      return 0.0;
    }
  }
}