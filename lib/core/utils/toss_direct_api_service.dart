import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RealtimeQuote {
  final double currentPrice;
  final double changePrice;

  const RealtimeQuote({
    required this.currentPrice,
    this.changePrice = 0.0,
  });
}

class TossDirectApiService {
  static const String _baseUrl = 'https://openapi.tossinvest.com';

  static String get clientId => dotenv.env['TOSS_CLIENT_ID'] ?? '';
  static String get clientSecret => dotenv.env['TOSS_CLIENT_SECRET'] ?? '';

  static String? _accessToken;
  static DateTime? _tokenExpiryTime;

  /// OAuth 2.0 Access Token 발급 및 캐싱
  static Future<String> _getAccessToken() async {
    final now = DateTime.now();
    if (_accessToken != null &&
        _tokenExpiryTime != null &&
        now.isBefore(_tokenExpiryTime!)) {
      return _accessToken!;
    }

    final url = Uri.parse('$_baseUrl/oauth2/token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      final int expiresIn = data['expires_in'] ?? 3600;
      _tokenExpiryTime = now.add(Duration(seconds: expiresIn - 600));
      return _accessToken!;
    } else {
      throw Exception('토스 토큰 발급 실패: ${response.statusCode} -${response.body}');
    }
  }

  /// 특정 종목 코드의 실시간 현재가 및 전일 대비 변동액 조회
  static Future<RealtimeQuote?> getRealtimeQuote(String stockCode) async {
    try {
      final token = await _getAccessToken();
      final url = Uri.parse('$_baseUrl/api/v1/prices?symbols=$stockCode');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data is Map && data['result'] != null)
            ? data['result'] as List
            : (data is List ? data : []);

        if (list.isNotEmpty) {
          final item = list.first;
          final current = double.tryParse(
                (item['lastPrice'] ?? item['closePrice'] ?? item['price'] ?? 0)
                    .toString(),
              ) ??
              0.0;
          final prevClose = double.tryParse(
            (item['prevClosePrice'] ?? item['basePrice'] ?? '').toString(),
          );
          final explicitChange = double.tryParse(
            (item['changePrice'] ?? '').toString(),
          );

          final change = explicitChange ??
              (prevClose != null && prevClose > 0 ? current - prevClose : 0.0);

          if (current > 0) {
            return RealtimeQuote(currentPrice: current, changePrice: change);
          }
        }
      }
    } catch (e) {
      print('토스 실시간 시세 조회 오류 ($stockCode):$e');
    }
    return null;
  }

  /// 실시간 원·달러 환율 조회
  static Future<double?> getCurrentExchangeRate() async {
    try {
      final token = await _getAccessToken();
      final url = Uri.parse(
        '$_baseUrl/api/v1/exchange-rate?baseCurrency=USD&quoteCurrency=KRW',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['result'] != null) {
          final rateStr = data['result']['rate'] ?? data['result']['midRate'];
          return double.tryParse(rateStr.toString());
        }
      }
    } catch (e) {
      print('토스 실시간 환율 조회 오류: $e');
    }
    return null;
  }

  /// 특정 종목 코드와 연월('yyyy-MM')을 받아 해당 월의 말일 종가를 가져옵니다[cite: 18].
  static Future<double?> getMonthlyClosePrice(
    String stockCode,
    String yearMonth,
  ) async {
    try {
      final token = await _getAccessToken();
      final parts = yearMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final lastDay = DateTime(year, month + 1, 0);

      final formattedDay = lastDay.day.toString().padLeft(2, '0');
      final formattedMonth = lastDay.month.toString().padLeft(2, '0');
      final beforeStr = '$year-$formattedMonth-${formattedDay}T23:59:59+09:00';

      final url = Uri.parse(
        '$_baseUrl/api/v1/candles?symbol=$stockCode&interval=1d&count=30&before=$beforeStr',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data is Map &&
          data['result'] != null &&
          data['result']['candles'] != null) {
        final candles = data['result']['candles'] as List;
        for (var candle in candles) {
          final timestamp = candle['timestamp'].toString();
          if (timestamp.startsWith(yearMonth)) {
            final priceStr = candle['closePrice'];
            if (priceStr != null) {
              return double.tryParse(priceStr.toString());
            }
          }
        }
      }
      return null;
    } catch (e) {
      print('토스증권 월말 시세 조회 예외: $e');
      return null;
    }
  }

  /// 특정 연월('yyyy-MM')의 월말 기준 원·달러 환율 조회[cite: 18]
  static Future<double?> getMonthlyExchangeRate(String yearMonth) async {
    try {
      final token = await _getAccessToken();
      final parts = yearMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final lastDay = DateTime(year, month + 1, 0);

      final formattedDay = lastDay.day.toString().padLeft(2, '0');
      final formattedMonth = lastDay.month.toString().padLeft(2, '0');
      final dateTimeStr =
          '$year-$formattedMonth-${formattedDay}T15:30:00+09:00';

      final url = Uri.parse(
        '$_baseUrl/api/v1/exchange-rate?baseCurrency=USD&quoteCurrency=KRW&dateTime=$dateTimeStr',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data is Map && data['result'] != null) {
        final result = data['result'];
        final rateStr = result['rate'] ?? result['midRate'];
        if (rateStr != null) {
          return double.tryParse(rateStr.toString());
        }
      }
      return null;
    } catch (e) {
      print('토스증권 월말 환율 조회 예외: $e');
      return null;
    }
  }
}