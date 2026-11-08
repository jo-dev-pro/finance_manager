import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
class Account with _$Account {
  // 💡 커스텀 겟터/메서드를 사용하기 위한 명시적 생성자 선언
  const Account._();

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
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    
    // 💡 1. 통화 구분 필드 추가 (기본값 'KRW', 해외 달러 계좌의 경우 'USD')
    @JsonKey(name: 'currency') @Default('KRW') String currency,
  }) = _Account;

  // 💡 외화 계좌 여부 판별 겟터
  bool get isForeignCurrency => currency.toUpperCase() != 'KRW';

  // 💡 원화 계좌 여부 판별 겟터
  bool get isKrw => currency.toUpperCase() == 'KRW';
  
  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}