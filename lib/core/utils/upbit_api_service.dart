import 'dart:convert';
import 'package:http/http.dart' as http;
import 'toss_direct_api_service.dart'; // RealtimeQuote 공통 모델 활용

class UpbitApiService {
  static const String _baseUrl = 'https://api.upbit.com/v1';

  /// 복수 마켓의 실시간 현재가 및 전일 대비 변동액 일괄 조회
  static Future getRealtimeQuotes(
    List<String> markets,
  ) async {
    final Map<String, RealtimeQuote> result = {};
    if (markets.isEmpty) return result;

    try {
      final joinedMarkets = markets.join(',');
      final url = Uri.parse('$_baseUrl/ticker?markets=$joinedMarkets');
      final response = await http.get(url, headers: {'accept': 'application/json'});

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        for (var item in data) {
          final market = item['market']?.toString() ?? '';
          final price = double.tryParse(item['trade_price'].toString()) ?? 0.0;
          final change =
              double.tryParse(item['signed_change_price'].toString()) ?? 0.0;
          if (market.isNotEmpty && price > 0) {
            result[market] = RealtimeQuote(
              currentPrice: price,
              changePrice: change,
            );
          }
        }
      }
    } catch (e) {
      print('업비트 일괄 시세 조회 오류: $e');
    }
    return result;
  }

  /// 단건 현재가 조회 (Ticker)[cite: 19]
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
      print('업비트 현재가 조회 오류 ($market):$e');
    }
    return null;
  }

  /// 특정 월의 말일 종가 조회 (Candles Days 연동)[cite: 19]
  static Future<double?> getMonthlyClosePrice(String market, String yearMonth) async {
    try {
      final parts = yearMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final lastDay = DateTime(year, month + 1, 0);

      final formattedDate = '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}T23:59:59';

      final url = Uri.parse('$_baseUrl/candles/days?market=$market&to=$formattedDate&count=1');
      await Future.delayed(const Duration(milliseconds: 150));

      final response = await http.get(url, headers: {'accept': 'application/json'});

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return double.tryParse(data[0]['trade_price'].toString());
        }
      }
    } catch (e) {
      print('업비트 월말 시세 조회 예외 ($market, $yearMonth):$e');
    }
    return null;
  }
}