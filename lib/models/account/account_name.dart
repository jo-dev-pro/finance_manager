import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_name.freezed.dart';
part 'account_name.g.dart';

@freezed
class AccountName with _$AccountName {
  const factory AccountName({
    String? id,
    @JsonKey(name: 'account_name') required String accountName, // 계좌명 (필드명 1개 요청)
  }) = _AccountName;

  factory AccountName.fromJson(Map<String, dynamic> json) =>
      _$AccountNameFromJson(json);
}