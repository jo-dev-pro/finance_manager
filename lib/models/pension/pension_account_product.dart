import 'package:freezed_annotation/freezed_annotation.dart';

part 'pension_account_product.freezed.dart';
part 'pension_account_product.g.dart';

@freezed
class PensionAccountProduct with _$PensionAccountProduct {
  const factory PensionAccountProduct({
    String? id,
    @JsonKey(name: 'account_id') required String accountId,   // 연금 계좌 ID
    @JsonKey(name: 'product_id') required String productId,   // 공용 상품 ID
    @Default(0.0) double principal,                           // 투자 원금
    @JsonKey(name: 'purchase_date') String? purchaseDate,     // 최초 매수일 (YYYY-MM-DD)
  }) = _PensionAccountProduct;

  factory PensionAccountProduct.fromJson(Map<String, dynamic> json) =>
      _$PensionAccountProductFromJson(json);
}