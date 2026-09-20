import 'package:freezed_annotation/freezed_annotation.dart';

part 'pension_transaction.freezed.dart';
part 'pension_transaction.g.dart';

@freezed
class PensionTransaction with _$PensionTransaction {
  // includeIfNull: false 옵션을 통해 null 값인 id와 createdAt이 JSON 변환 시 제외됩니다.
 @JsonSerializable(includeIfNull: false)
  const factory PensionTransaction({
    String? id,
    @JsonKey(name: 'transaction_date') required String transactionDate,
    @JsonKey(name: 'financial_institution') String? financialInstitution,
    @JsonKey(name: 'account_name') required String accountName,
    @JsonKey(name: 'product_name') String? productName,
    @JsonKey(name: 'transaction_type') required String transactionType,
    @Default(0) double amount,
    String? memo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _PensionTransaction;

  factory PensionTransaction.fromJson(Map<String, dynamic> json) =>
      _$PensionTransactionFromJson(json);
}