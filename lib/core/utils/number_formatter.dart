import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../widgets/jtext.dart';

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

  /// 소수점 자릿수 고정 3자리 콤마 환율 문자열 (예: 1380 -> "1,380.00")
  String toExchangeRateString({int fractionDigits = 2}) {
    final pattern =
        fractionDigits > 0 ? '#,##0.${'0' * fractionDigits}' : '#,##0';
    return NumberFormat(pattern).format(this);
  }

  /// 뒤에 '원' 부착 (예: 15000 -> "15,000원")
  String toWon() {
    return '${toCommaString()}원';
  }

  /// 뒤에 '달러($)' 및 앞에 기호 부착 (예: 187.05 -> "$187.05")
  String toUSD() {
    return '\$${toCommaString()}';
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
    final clean =
        formatted.endsWith('.0')
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
    bool isDarkCard = false, // 💡 어두운 카드 배경인지 여부 (기본값: false = 하얀 바탕)
    String suffix = '원',
    bool showPlusSign = true,
  }) {
    final Color positiveColor =
        isDarkCard ? const Color(0xFFFF8A80) : Colors.red.shade700;
    final Color negativeColor =
        isDarkCard ? const Color(0xFF82B1FF) : Colors.blue.shade700;
    final Color zeroColor = Colors.grey;

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

    return JText(
      '$formattedNumber$suffix',
      style: (style ?? const TextStyle()).copyWith(color: textColor),
    );
  }

  /// 부호(+/-)에 따라 색상이 적용된 퍼센트 Text 위젯 리턴
  Widget toSignedPercentText({
    TextStyle? style,
    bool isDarkCard = false, // 💡 어두운 카드 배경인지 여부 추가
    int fractionDigits = 1,
    bool showPlusSign = true,
    bool withParentheses = false,
  }) {
    final Color positiveColor =
        isDarkCard ? const Color(0xFFFF8A80) : Colors.red.shade700;
    final Color negativeColor =
        isDarkCard ? const Color(0xFF82B1FF) : Colors.blue.shade700;
    final Color zeroColor = Colors.grey;

    Color textColor;
    if (this > 0) {
      textColor = positiveColor;
    } else if (this < 0) {
      textColor = negativeColor;
    } else {
      textColor = zeroColor;
    }

    final String formattedPercent =
        showPlusSign
            ? toSignedPercent(fractionDigits: fractionDigits)
            : toPercent(fractionDigits: fractionDigits);

    final String displayText =
        withParentheses ? '($formattedPercent)' : formattedPercent;

    return JText(
      displayText,
      style: (style ?? const TextStyle()).copyWith(color: textColor),
    );
  }

  /// 외화 여부에 따라 원화(반올림 + 원) 또는 달러($) 문자열 반환
  String toCurrency({required bool isForeign}) {
    return isForeign ? toUSD() : round().toWon();
  }

  /// 외화 여부에 따라 부호(+/-)와 색상이 적용된 금액 Text 위젯 반환
  Widget toSignedCurrencyText({
    required bool isForeign,
    TextStyle? style,
    bool isDarkCard = false,
    bool showPlusSign = true,
  }) {
    if (!isForeign) {
      return round().toSignedPriceText(
        style: style,
        isDarkCard: isDarkCard,
        suffix: '원',
        showPlusSign: showPlusSign,
      );
    }

    final Color positiveColor =
        isDarkCard ? const Color(0xFFFF8A80) : Colors.red.shade700;
    final Color negativeColor =
        isDarkCard ? const Color(0xFF82B1FF) : Colors.blue.shade700;
    final Color zeroColor = Colors.grey;

    final Color textColor =
        this > 0
            ? positiveColor
            : this < 0
            ? negativeColor
            : zeroColor;

    final String formattedNumber =
        showPlusSign ? toSignedCommaString() : toCommaString();

    return JText(
      '\$$formattedNumber',
      style: (style ?? const TextStyle()).copyWith(color: textColor),
    );
  }
}

// ==========================================
// 3. [DateTime Extension] 날짜 포맷팅 헬퍼
// ==========================================
extension DateFormatter on DateTime {
  /// yyyy.MM.dd 형식 날짜 문자열 반환 (예: 2026.11.22)
  String toYmdDot() {
    return DateFormat('yyyy.MM.dd').format(this);
  }
}