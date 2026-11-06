import 'dart:convert';
import 'package:http/http.dart' as http;

class UpbitApiService {
  static const String _baseUrl = 'https://api.upbit.com/v1';

  /// 1. 현재가 조회 (Ticker)
  static Future<double?> getCurrentPrice(String market) async {
    try {
      final url = Uri.parse('$_baseUrl/ticker?markets=$market');
      final response = await http.get(url, headers: {'accept': 'application/json'});

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return double.tryParse(data[0]['trade_price'].toString());
        }
      }
    } catch (e) {
      print('업비트 현재가 조회 오류 ($market): $e');
    }
    return null;
  }

  /// 2. 특정 월의 말일 종가 조회 (Candles Days 연동)
  static Future<double?> getMonthlyClosePrice(String market, String yearMonth) async {
    try {
      // yearMonth 형식: 'YYYY-MM' -> 해당 월의 말일 계산 (예: 2025-03 -> 2025-03-31)
      final parts = yearMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final lastDay = DateTime(year, month + 1, 0); // 다음 달의 0일 = 이번 달 마지막 날

      final formattedDate = '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}T23:59:59';

      // 업비트 일봉 API 호출 (to 파라미터에 해당 일시를 전달하면 그 이전 혹은 해당 일자의 캔들 조회 가능)
      final url = Uri.parse('$_baseUrl/candles/days?market=$market&to=$formattedDate&count=1');
      
      // 업비트 API Rate Limit(초당 10회) 고려 딜레이
      await Future.delayed(const Duration(milliseconds: 150));

      final response = await http.get(url, headers: {'accept': 'application/json'});

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return double.tryParse(data[0]['trade_price'].toString());
        }
      } else {
        print('업비트 월말 시세 오류 코드 (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('업비트 월말 시세 조회 예외 ($market, $yearMonth): $e');
    }
    return null;
  }
}