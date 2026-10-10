import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_pension_balance.freezed.dart';
part 'monthly_pension_balance.g.dart';

@freezed
class MonthlyPensionBalance with _$MonthlyPensionBalance {
  const factory MonthlyPensionBalance({
    String? id,
    @JsonKey(name: 'year_month') required String yearMonth,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'product_id') required String productId, // 💡 연금상품 ID 추가
    @Default(0.0) double balance,
  }) = _MonthlyPensionBalance;

  factory MonthlyPensionBalance.fromJson(Map<String, dynamic> json) =>
      _$MonthlyPensionBalanceFromJson(json);
}