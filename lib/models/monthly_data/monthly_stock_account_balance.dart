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
    @JsonKey(name: 'monthly_withdrawal') @Default(0.0) double monthlyWithdrawal, // 💡 당월 인출액
    @JsonKey(name: 'total_withdrawal') @Default(0.0) double totalWithdrawal,     // 💡 누적 인출액 (전월 누적 + 당월)
  }) = _MonthlyStockAccountBalance;

  factory MonthlyStockAccountBalance.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStockAccountBalanceFromJson(json);
}