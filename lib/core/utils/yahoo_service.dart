import 'dart:convert';
import 'package:http/http.dart' as http;

class YahooFinanceService {
  /// 특정 종목 코드(stockCode, 예: '285490.KQ' 또는 'AAPL')와 연월('yyyy-MM')을 받아
  /// 해당 월의 말일(가장 마지막 거래일) 종가를 가져옵니다.
  static Future<double?> getMonthlyClosePrice(String stockCode, String yearMonth) async {
    try {
      final parts = yearMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      // 조회 범위: 해당월 1일 ~ 다음달 10일 넉넉하게 설정
      final startDate = DateTime.utc(year, month, 1);
      final endDate = DateTime.utc(year, month + 1, 10);

      final period1 = startDate.millisecondsSinceEpoch ~/ 1000;
      final period2 = endDate.millisecondsSinceEpoch ~/ 1000;

      // 야후 파이낸스 v8 chart API 엔드포인트
      final url = Uri.parse(
        'https://query1.finance.yahoo.com/v8/finance/chart/$stockCode?period1=$period1&period2=$period2&interval=1d',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print('야후 API 응답 오류 코드: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      final chart = data['chart'];
      if (chart == null || chart['error'] != null) {
        print('야후 API 차트 에러: ${chart?['error']}');
        return null;
      }

      final result = chart['result'];
      if (result == null || (result as List).isEmpty) return null;

      final timestamps = result[0]['timestamp'] as List<dynamic>?;
      final quotes = result[0]['indicators']['quote'][0];
      final closes = quotes['close'] as List<dynamic>?;

      if (timestamps == null || closes == null || timestamps.isEmpty) {
        return null;
      }

      double? targetPrice;

      // UTC 기준으로 해당 연월(year-month)에 속하는 유효한 종가 찾기
      for (int i = 0; i < timestamps.length; i++) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000, isUtc: true);
        if (date.year == year && date.month == month) {
          final price = closes[i];
print('조회된 날짜: ${date.toIso8601String()}, 가격: $price');        
          if (price != null) {
            targetPrice = (price as num).toDouble();
          }
        }
      }

      return targetPrice;
    } catch (e) {
      print('야후 파이낸스 가격 조회 예외 발생: $e');
      return null;
    }
  }
}