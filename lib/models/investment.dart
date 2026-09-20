import 'package:freezed_annotation/freezed_annotation.dart';

part 'investment.freezed.dart';
part 'investment.g.dart';


@freezed
class Investment with _$Investment {
  // includeIfNull: false 옵션을 통해 null 값인 id와 createdAt이 JSON 변환 시 제외됩니다.
  @JsonSerializable(includeIfNull: false)
  const factory Investment({
    String? id,
    required String description,
    @Default(0) double amount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Investment;

  factory Investment.fromJson(Map<String, dynamic> json) =>
      _$InvestmentFromJson(json);
}