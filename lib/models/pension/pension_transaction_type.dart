import 'package:freezed_annotation/freezed_annotation.dart';

part 'pension_transaction_type.freezed.dart';
part 'pension_transaction_type.g.dart';

@freezed
class PensionTransactionType with _$PensionTransactionType {
  const factory PensionTransactionType({
    String? id,
    required String name,
    @Default(0) int displayOrder,
    @Default(true) bool isActive,
  }) = _PensionTransactionType;

  factory PensionTransactionType.fromJson(Map<String, dynamic> json) =>
      _$PensionTransactionTypeFromJson(json);
}