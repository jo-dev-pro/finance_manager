import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_pension_balance.freezed.dart';
part 'monthly_pension_balance.g.dart';

@freezed
class MonthlyPensionBalance with _$MonthlyPensionBalance {
  const factory MonthlyPensionBalance({
    String? id,
    @JsonKey(name: 'year_month') required String yearMonth,
    @JsonKey(name: 'financial_institution') String? financialInstitution,
    @JsonKey(name: 'account_name') required String accountName,
    @JsonKey(name: 'product_name') String? productName,
   @JsonKey(name: 'evaluation_amount') @Default(0.0) double evaluationAmount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _MonthlyPensionBalance;

  factory MonthlyPensionBalance.fromJson(Map<String, dynamic> json) =>
      _$MonthlyPensionBalanceFromJson(json);
}