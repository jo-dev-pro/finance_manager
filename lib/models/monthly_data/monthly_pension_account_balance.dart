import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_pension_account_balance.freezed.dart';
part 'monthly_pension_account_balance.g.dart';

@freezed
class MonthlyPensionAccountBalance with _$MonthlyPensionAccountBalance {
  const MonthlyPensionAccountBalance._();

  const factory MonthlyPensionAccountBalance({
    String? id,
    @JsonKey(name: 'year_month') required String yearMonth,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'account_name') String? accountName, // 콘솔 확인용 계좌명
    @JsonKey(name: 'cash_balance') @Default(0.0) double cashBalance,         // 연금 계좌 현금성 잔액 (예수금)

    // 💡 1. 원금 관련 필드 추가 (당월 납입액 및 누적 원금)
    @JsonKey(name: 'principal') @Default(0.0) double principal,             // 계좌 누적 원금
    @JsonKey(name: 'monthly_principal') @Default(0.0) double monthlyPrincipal, // 계좌 당월 납입액 (추가 납입액)
    
    @JsonKey(name: 'monthly_withdrawal') @Default(0.0) double monthlyWithdrawal, // 당월 중도 인출금
    @JsonKey(name: 'total_withdrawal') @Default(0.0) double totalWithdrawal,     // 누적 중도 인출금
  }) = _MonthlyPensionAccountBalance;

  factory MonthlyPensionAccountBalance.fromJson(Map<String, dynamic> json) =>
      _$MonthlyPensionAccountBalanceFromJson(json);
}