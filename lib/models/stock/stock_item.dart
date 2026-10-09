import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/date_time_converter.dart';

part 'stock_item.freezed.dart';
part 'stock_item.g.dart';

@freezed
class StockItem with _$StockItem {
  const factory StockItem({
    String? id,
    @JsonKey(name: 'symbol_code') required String symbolCode,
    required String name,
    @Default('KOSPI') String market,
    String? memo,
  }) = _StockItem;

  factory StockItem.fromJson(Map<String, dynamic> json) =>
      _$StockItemFromJson(json);
}
