import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_holding_item.freezed.dart';
part 'stock_holding_item.g.dart';

@freezed
class StockHoldingItem with _$StockHoldingItem {
  const factory StockHoldingItem({
    String? id,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'stock_item_id') required String stockItemId,
    @Default(0.0) double principal,               // 초기/누적 투자 원금
    @JsonKey(name: 'purchase_date') String? purchaseDate, // 최초 매수일
    @Default(false) bool isTerminated,            // 전량 매도/종료 여부
  }) = _StockHoldingItem;

  factory StockHoldingItem.fromJson(Map<String, dynamic> json) =>
      _$StockHoldingItemFromJson(json);
}