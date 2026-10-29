import 'dart:convert';
import 'package:http/http.dart' as http;

class YahooFinanceService {
  /// 특정 종목 코드(stockCode, 예: '005930.KS' 또는 'AAPL')와 연월('yyyy-MM')을 받아
  /// 해당 월의 말일(가장 마지막 거래일) 종가를 가져옵니다.
  static Future<double?> getMonthlyClosePrice(String stockCode, String yearMonth) async {
    try {
      // 1. 해당 연월의 시작일과 종료일 계산
      final parts = yearMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      // 조회 범위: 해당월 1일 ~ 다음달 5일 넉넉하게 설정하여 마지막 거래일 포함
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 5);

      final period1 = startDate.millisecondsSinceEpoch ~/ 1000;
      final period2 = endDate.millisecondsSinceEpoch ~/ 1000;

      // 야후 파이낸스 v8 chart API 엔드포인트
      final url = Uri.parse(
        'https://query1.finance.yahoo.com/v8/finance/chart/$stockCode?period1=$period1&period2=$period2&interval=1d',
      );

      final response = await http.get(url, headers: {
        'User-Agent': 'Mozilla/5.0', // 야후 API 차단 방지용 헤더
      });

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final chart = data['chart'];
      if (chart['error'] != null) return null;

      final result = chart['result'][0];
      final timestamps = result['timestamp'] as List<dynamic>?;
      final quotes = result['indicators']['quote'][0];
      final closes = quotes['close'] as List<dynamic>?;

      if (timestamps == null || closes == null || timestamps.isEmpty) {
        return null;
      }

      // 2. 해당 연월(year-month)에 속하는 데이터 중 가장 마지막 날짜의 종가 찾기
      double? targetPrice;
      for (int i = 0; i < timestamps.length; i++) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000, isUtc: true).toLocal();
        if (date.year == year && date.month == month) {
          final price = closes[i];
          if (price != null) {
            targetPrice = (price as num).toDouble();
          }
        }
      }

      return targetPrice;
    } catch (e) {
      print('야후 파이낸스 가격 조회 오류: $e');
      return null;
    }
  }
}