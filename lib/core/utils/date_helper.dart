import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHelper {
  /// 📅 한글 날짜 선택기 다이얼로그를 띄우고 선택된 날짜를 반환합니다.
  static Future<DateTime?> pickDate(BuildContext context, {DateTime? initialDate}) async {
    final DateTime now = DateTime.now();
    
    // Theme 밖으로 생성 로직 추출하여 렌더링 딜레이 방지
    final customTheme = Theme.of(context).copyWith(
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: customTheme,
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