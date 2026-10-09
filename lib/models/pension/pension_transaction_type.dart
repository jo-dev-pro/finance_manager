import 'package:freezed_annotation/freezed_annotation.dart';

part 'pension_transaction_type.freezed.dart';
part 'pension_transaction_type.g.dart';

@freezed
class PensionTransactionType with _$PensionTransactionType {
  const factory PensionTransactionType({
    String? id,
    required String name,
    @JsonKey(name: 'amount_sign') @Default('+') String amountSign, // 💡 금액 부호 (+ 또는 -)
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
  }) = _PensionTransactionType;

  factory PensionTransactionType.fromJson(Map<String, dynamic> json) =>
      _$PensionTransactionTypeFromJson(json);
}