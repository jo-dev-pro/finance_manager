import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/utils/date_time_converter.dart';

part 'monthly_bank_balance.freezed.dart';
part 'monthly_bank_balance.g.dart';

@freezed
class MonthlyBankBalance with _$MonthlyBankBalance {
  const factory MonthlyBankBalance({
    String? id,
    @JsonKey(name: 'year_month') required String yearMonth,
    @JsonKey(name: 'financial_institution')
    required String financialInstitution,
    @JsonKey(name: 'account_name') required String accountName,
    @Default(0.0) double balance,
    @JsonKey(name: 'created_at')
    @TimestampConverter() // 👈 이 줄을 추가합니다.
    DateTime? createdAt,
  }) = _MonthlyBankBalance;

  factory MonthlyBankBalance.fromJson(Map<String, dynamic> json) =>
      _$MonthlyBankBalanceFromJson(json);
}
