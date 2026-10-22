import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
class Account with _$Account {
  const factory Account({
    String? id,
    @JsonKey(name: 'financial_institution')
    required String financialInstitution,
    @JsonKey(name: 'account_name_id') String? accountNameId,
    @JsonKey(name: 'account_name') String? accountName,
    @JsonKey(name: 'account_type') required String accountType,
    @JsonKey(name: 'account_number') String? accountNumber,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @Default('활동') String status,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder, // 💡 출력 순서 필드 추가
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
