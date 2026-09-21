import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
class Account with _$Account {
  const factory Account({
    String? id,
    @JsonKey(name: 'financial_institution') required String financialInstitution,
    @JsonKey(name: 'account_type') required String accountType,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'account_name') required String accountName,
    @Default('활동') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
