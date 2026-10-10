import 'package:freezed_annotation/freezed_annotation.dart';

part 'pension_transaction.freezed.dart';
part 'pension_transaction.g.dart';

@freezed
class PensionTransaction with _$PensionTransaction {
  const factory PensionTransaction({
    String? id,
    @JsonKey(name: 'transaction_date') required String transactionDate,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'transaction_type_id') required String transactionTypeId,
    @JsonKey(name: 'product_id') String? productId,
    @Default(0) double amount,
    String? memo,
    @JsonKey(name: 'purchase_date') String? purchaseDate,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder, // 💡 순서 정렬용 필드 추가
  }) = _PensionTransaction;

  factory PensionTransaction.fromJson(Map<String, dynamic> json) =>
      _$PensionTransactionFromJson(json);
}