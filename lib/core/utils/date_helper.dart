import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHelper {
  /// 📅 한글 날짜 선택기 다이얼로그를 띄우고 선택된 날짜를 반환합니다.
  static Future<DateTime?> pickDate(BuildContext context, {DateTime? initialDate}) async {
    final DateTime now = DateTime.now();
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now, // 처음 선택되어 있을 날짜
      firstDate: DateTime(now.year - 10), // 선택 가능한 가장 과거 날짜 (10년 전)
      lastDate: DateTime(now.year + 10),  // 선택 가능한 가장 미래 날짜 (10년 후)
      
      // 달력 내부 디자인을 커스텀하고 싶다면 추가 (선택사항)
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(textStyle: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          child: child!,
        );
      },
    );
    
    return picked;
  }

  /// [유틸] DateTime 객체를 "2026년 03월 12일 (목)" 형식의 한글 텍스트로 변환합니다.
  static String formatToKorean(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(date);
  }
}
