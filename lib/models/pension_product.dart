import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/utils/date_time_converter.dart';

part 'pension_product.freezed.dart';
part 'pension_product.g.dart';

@freezed
class PensionProduct with _$PensionProduct {
  const factory PensionProduct({
    String? id,
    @JsonKey(name: 'account_name') required String accountName,
    @JsonKey(name: 'product_name') required String productName,
    @Default('활동') String status,
    @JsonKey(name: 'created_at')
    @TimestampConverter() // 👈 이 줄을 추가합니다.
    DateTime? createdAt,
  }) = _Product;

  factory PensionProduct.fromJson(Map<String, dynamic> json) =>
      _$PensionProductFromJson(json);
}
