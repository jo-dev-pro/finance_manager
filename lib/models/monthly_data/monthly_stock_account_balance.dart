import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_stock_account_balance.freezed.dart';
part 'monthly_stock_account_balance.g.dart';

@freezed
class MonthlyStockAccountBalance with _$MonthlyStockAccountBalance {
  const MonthlyStockAccountBalance._();

  const factory MonthlyStockAccountBalance({
    String? id,
    @JsonKey(name: 'year_month') required String yearMonth,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'account_name') String? accountName,
    @JsonKey(name: 'cash_balance') @Default(0.0) double cashBalance,         // 계좌 현금성 잔액(예수금)

    // 💡 신규 추가: 당월 말일 적용 환율 (예: 1350.50, 원화계좌는 기본값 1.0)
    @JsonKey(name: 'exchange_rate') @Default(1.0) double exchangeRate,

    // 1. 계좌 입금액 / 추가원금 (누적 및 당월분)
    @Default(0.0) double principal, // 누적 계좌 입금액 (원금)
    @JsonKey(name: 'monthly_principal') @Default(0.0) double monthlyPrincipal, // 당월 계좌 입금액

    // 2. 계좌 인출액 (누적 및 당월분)
    @JsonKey(name: 'total_withdrawal') @Default(0.0) double totalWithdrawal, // 누적 계좌 인출액
    @JsonKey(name: 'monthly_withdrawal') @Default(0.0) double monthlyWithdrawal, // 당월 계좌 인출액
  }) = _MonthlyStockAccountBalance;
  factory MonthlyStockAccountBalance.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStockAccountBalanceFromJson(json);
}