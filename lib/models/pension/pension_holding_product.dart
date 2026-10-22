import 'package:freezed_annotation/freezed_annotation.dart';

part 'pension_holding_product.freezed.dart';
part 'pension_holding_product.g.dart';

@freezed
class PensionHoldingProduct with _$PensionHoldingProduct {
  const PensionHoldingProduct._();

  const factory PensionHoldingProduct({
    String? id,
    @JsonKey(name: 'account_id') required String accountId,   // 연금 계좌 ID
    @JsonKey(name: 'product_id') required String productId,   // 공용 상품 ID
    @Default(0.0) double principal,                           // 총 투자 원금
    @JsonKey(name: 'purchase_date') String? purchaseDate,     // 최초 매수일 (YYYY-MM-DD)
    @JsonKey(name: 'total_payout') @Default(0.0) double totalPayout, // 💡 누적 연금 수령(지급)액
    @JsonKey(name: 'is_terminated') @Default(false) bool isTerminated, // 💡 연금 수령 완료(종료) 여부
  }) = _PensionHoldingProduct;

  factory PensionHoldingProduct.fromJson(Map<String, dynamic> json) =>
      _$PensionHoldingProductFromJson(json);

  // 💡 [핵심] 현재 평가액이 들어왔을 때, 누적 수령액을 포함한 총 평가손익 계산
  // 총 손익 = (현재 평가액 + 누적 연금 수령액) - 총 투자 원금
  double calculateTotalProfitOrLoss(double currentBalance) {
    return (currentBalance + totalPayout) - principal;
  }

  // 💡 누적 수령액 포함 총 수익률 (%)
  double calculateTotalReturnRate(double currentBalance) {
    if (principal <= 0) return 0.0;
    return (calculateTotalProfitOrLoss(currentBalance) / principal) * 100;
  }
}