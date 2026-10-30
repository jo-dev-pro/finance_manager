import 'package:freezed_annotation/freezed_annotation.dart';

part 'pension_holding_product.freezed.dart';
part 'pension_holding_product.g.dart';

@freezed
class PensionHoldingProduct with _$PensionHoldingProduct {
  const PensionHoldingProduct._();

  const factory PensionHoldingProduct({
    String? id,
    @JsonKey(name: 'account_id') required String accountId, // 연금 계좌 ID[cite: 6]
    @JsonKey(name: 'product_id') required String productId, // 공용 상품 ID[cite: 6]
    @JsonKey(name: 'is_active') @Default(true) bool isActive, // 활동 / 비활동 여부[cite: 6]
    @JsonKey(name: 'initial_purchase_date')
    String? initialPurchaseDate, // 최초 매수일 (고정)[cite: 6]
  }) = _PensionHoldingProduct;

  factory PensionHoldingProduct.fromJson(Map<String, dynamic> json) =>
      _$PensionHoldingProductFromJson(json);
}