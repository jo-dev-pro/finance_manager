import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_pension_balance.freezed.dart';
part 'monthly_pension_balance.g.dart';

@freezed
class MonthlyPensionBalance with _$MonthlyPensionBalance {
  const MonthlyPensionBalance._();

  const factory MonthlyPensionBalance({
    String? id,
    @JsonKey(name: 'year_month') required String yearMonth,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'product_id') required String productId,
    @Default(0.0) double balance,     // 월말 평가액
    @Default(0.0) double principal,   // 투자 원금
    @JsonKey(name: 'purchase_date') String? purchaseDate, // 상품 최초 매수일 (YYYY-MM-dd)
  }) = _MonthlyPensionBalance;

  factory MonthlyPensionBalance.fromJson(Map<String, dynamic> json) =>
      _$MonthlyPensionBalanceFromJson(json);

  // 1. 평가 손익 계산
  double get profitOrLoss => balance - principal;

  // 2. 누적 수익률 (%) 계산
  double get returnRate =>
      principal > 0 ? (profitOrLoss / principal) * 100 : 0.0;

  // 3. 연환산 수익률 (CAGR %) 계산
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
      final totalRatio = balance / principal;

      if (totalRatio <= 0) return -100.0;

      final cagr = (pow(totalRatio, 1.0 / years) - 1.0) * 100;
      return cagr.toDouble();
    } catch (_) {
      return 0.0;
    }
  }
}