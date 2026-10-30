import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_holding_item.freezed.dart';
part 'stock_holding_item.g.dart';

@freezed
class StockHoldingItem with _$StockHoldingItem {
  const StockHoldingItem._();

  const factory StockHoldingItem({
    String? id,
    @JsonKey(name: 'account_id') required String accountId,       // 계좌 ID
    @JsonKey(name: 'stock_item_id') required String stockItemId, // 종목 ID
    @JsonKey(name: 'is_active') @Default(true) bool isActive,    // 활동 / 비활동 여부
    @JsonKey(name: 'initial_purchase_date') String? initialPurchaseDate, // 최초 매수일 (고정)
  }) = _StockHoldingItem;

  factory StockHoldingItem.fromJson(Map<String, dynamic> json) =>
      _$StockHoldingItemFromJson(json);
}