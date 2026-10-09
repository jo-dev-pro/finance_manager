import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/date_time_converter.dart';

part 'pension_product.freezed.dart';
part 'pension_product.g.dart';

@freezed
class PensionProduct with _$PensionProduct {
  const factory PensionProduct({
    String? id,
    @JsonKey(name: 'product_name') required String productName,
  }) = _Product;

  factory PensionProduct.fromJson(Map<String, dynamic> json) =>
      _$PensionProductFromJson(json);
}
