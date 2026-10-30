import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_item.freezed.dart';
part 'stock_item.g.dart';

@freezed
class StockItem with _$StockItem {
  const factory StockItem({
    String? id, // 문서 ID (docId) 매핑용
    @JsonKey(name: 'itemName') required String itemName,     // 종목명 (예: 노바텍)
    @JsonKey(name: 'otherName') @Default('') String otherName,         // 기타 이름
    @JsonKey(name: 'stockCode') required String stockCode,    // 종목 코드 (예: 285490)
    @JsonKey(name: 'yahooName') String? yahooName,          // 시장 구분 또는 야후 심볼 등 (예: KQ)[cite: 14]
  }) = _StockItem;

  factory StockItem.fromJson(Map<String, dynamic> json) =>
      _$StockItemFromJson(json);
}