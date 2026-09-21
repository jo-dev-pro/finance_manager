import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/utils/date_time_converter.dart';

part 'investment.freezed.dart';
part 'investment.g.dart';

@freezed
class Investment with _$Investment {
  const factory Investment({
    String? id,
    required String description,
    @Default(0) double amount,
    @JsonKey(name: 'created_at')
    @TimestampConverter() // 👈 이 줄을 추가합니다.
    DateTime? createdAt,
  }) = _Investment;

  factory Investment.fromJson(Map<String, dynamic> json) =>
      _$InvestmentFromJson(json);
}
