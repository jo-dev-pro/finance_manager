import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json is Timestamp) {
      return json.toDate(); // Timestamp를 DateTime으로 변환
    } else if (json is String) {
      return DateTime.tryParse(json);
    }
    return null;
  }

  @override
  dynamic toJson(DateTime? date) => date?.toIso8601String();
}
