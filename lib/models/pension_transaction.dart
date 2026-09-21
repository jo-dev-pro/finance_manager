import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/utils/date_time_converter.dart';

part 'pension_transaction.freezed.dart';
part 'pension_transaction.g.dart';

@freezed
class PensionTransaction with _$PensionTransaction {
  const factory PensionTransaction({
    String? id,
    @JsonKey(name: 'transaction_date') required String transactionDate,
    @JsonKey(name: 'financial_institution') String? financialInstitution,
    @JsonKey(name: 'account_name') required String accountName,
    @JsonKey(name: 'product_name') String? productName,
    @JsonKey(name: 'transaction_type') required String transactionType,
    @Default(0) double amount,
    String? memo,
    @JsonKey(name: 'created_at')
    @TimestampConverter() // 👈 이 줄을 추가합니다.
    DateTime? createdAt,
  }) = _PensionTransaction;

  factory PensionTransaction.fromJson(Map<String, dynamic> json) =>
      _$PensionTransactionFromJson(json);
}
