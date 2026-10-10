import 'package:freezed_annotation/freezed_annotation.dart';

part 'pension_transaction_type.freezed.dart';
part 'pension_transaction_type.g.dart';

@freezed
class PensionTransactionType with _$PensionTransactionType {
  const factory PensionTransactionType({
    String? id,
    required String typeName,
    @JsonKey(name: 'amount_sign') @Default('+') String amountSign, // 💡 금액 부호 (+ 또는 -)
  }) = _PensionTransactionType;

  factory PensionTransactionType.fromJson(Map<String, dynamic> json) =>
      _$PensionTransactionTypeFromJson(json);
}