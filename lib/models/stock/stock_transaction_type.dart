import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_transaction_type.freezed.dart';
part 'stock_transaction_type.g.dart';

@freezed
class StockTransactionType with _$StockTransactionType {
  const factory StockTransactionType({
    String? id,
    required String typeName,
    required String amountSign,
    required String quantitySign,
  }) = _StockTransactionType;

  factory StockTransactionType.fromJson(Map<String, dynamic> json) =>
      _$StockTransactionTypeFromJson(json);
}
