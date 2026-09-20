import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
@JsonSerializable(includeIfNull: false)
class Account with _$Account {
  // includeIfNull: false 옵션을 통해 null 값인 id와 createdAt이 JSON 변환 시 제외됩니다.
  const factory Account({
    String? id,
    @JsonKey(name: 'financial_institution')
    required String financialInstitution,
    @JsonKey(name: 'account_type') required String accountType,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'account_name') required String accountName,
    @Default('활동') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
