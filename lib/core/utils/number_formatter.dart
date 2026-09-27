import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ==========================================
// 1. [TextInputFormatter] 천 단위 콤마 입력 포맷터
// ==========================================
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'ko_KR');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 숫자 이외의 모든 문자 제거
    final cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = double.tryParse(cleanText);
    if (number == null) {
      return oldValue;
    }

    final newString = _formatter.format(number);

    // 커서 위치 보정 (입력 중간에서 삭제/삽입 시 맨 뒤로 튕기는 현상 방지)
    int cursorOffset = newValue.selection.baseOffset;
    int digitCountBeforeCursor = 0;

    for (int i = 0; i < cursorOffset && i < newValue.text.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(newValue.text[i])) {
        digitCountBeforeCursor++;
      }
    }

    int newCursorOffset = 0;
    int digitCount = 0;
    for (int i = 0; i < newString.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(newString[i])) {
        digitCount++;
      }
      if (digitCount == digitCountBeforeCursor) {
        newCursorOffset = i + 1;
        break;
      }
    }

    if (digitCountBeforeCursor == 0) {
      newCursorOffset = 0;
    } else if (newCursorOffset == 0 || newCursorOffset > newString.length) {
      newCursorOffset = newString.length;
    }

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }
}

// ==========================================
// 2. [num Extension] 숫자 포맷팅 및 Text 위젯 헬퍼
// ==========================================
extension NumberFormatter on num {
  /// 3자리마다 콤마 포함 (예: 15000 -> "15,000", 15000.5 -> "15,000.5")
  String toCommaString() {
    return NumberFormat('#,###.##').format(this);
  }

  /// 뒤에 '원' 부착 (예: 15000 -> "15,000원")
  String toWon() {
    return '${toCommaString()}원';
  }

  /// 부호 포함 3자리 콤마 (예: 1500 -> "+1,500", -500 -> "-500", 0 -> "0")
  String toSignedCommaString() {
    if (this > 0) return '+${toCommaString()}';
    return toCommaString();
  }

  /// 부호 포함 원화 표시 (예: 1500 -> "+1,500원", -500 -> "-500원", 0 -> "0원")
  String toSignedWon() {
    return '${toSignedCommaString()}원';
  }

  /// 만/억 단위 한글 변환 (예: 15000 -> "1만 5,000원", 150000000 -> "1억 5,000만원")
  String toKoreanWon() {
    if (this == 0) return '0원';

    final isNegative = this < 0;
    final value = abs().toInt();

    final uk = value ~/ 100000000; // 억
    final man = (value % 100000000) ~/ 10000; // 만
    final remainder = value % 10000; // 이하

    final List<String> parts = [];

    if (uk > 0) parts.add('${uk.toCommaString()}억');
    if (man > 0) parts.add('${man.toCommaString()}만');
    if (remainder > 0 || parts.isEmpty) {
      parts.add(remainder.toCommaString());
    }

    final formatted = parts.join(' ');
    final sign = isNegative ? '-' : '';

    return '$sign$formatted원';
  }

  /// 퍼센트 문자열 변환 (예: 15.5 -> "15.5%")
  String toPercent({int fractionDigits = 1}) {
    if (this == 0) return '0%';
    final formatted = toStringAsFixed(fractionDigits);
    final clean = formatted.endsWith('.0')
        ? formatted.substring(0, formatted.length - 2)
        : formatted;
    return '$clean%';
  }

  /// 부호 포함 퍼센트 문자열 변환 (예: 12.3 -> "+12.3%", -5.1 -> "-5.1%")
  String toSignedPercent({int fractionDigits = 1}) {
    if (this > 0) return '+${toPercent(fractionDigits: fractionDigits)}';
    return toPercent(fractionDigits: fractionDigits);
  }

  /// [대시보드/은행/연금 공용] 부호(+/-)에 따라 색상이 적용된 금액 Text 위젯 리턴
  Widget toSignedPriceText({
    TextStyle? style,
    Color positiveColor = const Color(0xFFFF8A80), // 플러스(수익/상승) Red/Orange
    Color negativeColor = const Color(0xFF82B1FF), // 마이너스(손실/하락) Blue
    Color zeroColor = Colors.grey,
    String suffix = '원',
    bool showPlusSign = true,
  }) {
    Color textColor;
    if (this > 0) {
      textColor = positiveColor;
    } else if (this < 0) {
      textColor = negativeColor;
    } else {
      textColor = zeroColor;
    }

    final String formattedNumber =
        showPlusSign ? toSignedCommaString() : toCommaString();

    return Text(
      '$formattedNumber$suffix',
      style: (style ?? const TextStyle()).copyWith(
        color: textColor,
      ),
    );
  }

  /// 부호(+/-)에 따라 색상이 적용된 퍼센트 Text 위젯 리턴
  Widget toSignedPercentText({
    TextStyle? style,
    Color positiveColor = const Color(0xFFFF8A80), // 플러스(수익/상승) Red/Orange
    Color negativeColor = const Color(0xFF82B1FF), // 마이너스(손실/하락) Blue
    Color zeroColor = Colors.grey,
    int fractionDigits = 1,
    bool showPlusSign = true,
    bool withParentheses = false,
  }) {
    Color textColor;
    if (this > 0) {
      textColor = positiveColor;
    } else if (this < 0) {
      textColor = negativeColor;
    } else {
      textColor = zeroColor;
    }

    final String formattedPercent = showPlusSign
        ? toSignedPercent(fractionDigits: fractionDigits)
        : toPercent(fractionDigits: fractionDigits);

    final String displayText =
        withParentheses ? '($formattedPercent)' : formattedPercent;

    return Text(
      displayText,
      style: (style ?? const TextStyle()).copyWith(
        color: textColor,
      ),
    );
  }
}