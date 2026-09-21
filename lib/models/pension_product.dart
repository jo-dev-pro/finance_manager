import 'package:freezed_annotation/freezed_annotation.dart';

part 'pension_product.freezed.dart';
part 'pension_product.g.dart';

@freezed
class PensionProduct with _$PensionProduct {
  const factory PensionProduct({
    String? id,
    @JsonKey(name: 'account_name') required String accountName,
    @JsonKey(name: 'product_name') required String productName,
    @Default('활동') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Product;

  factory PensionProduct.fromJson(Map<String, dynamic> json) => _$PensionProductFromJson(json);
}