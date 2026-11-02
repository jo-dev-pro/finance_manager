import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TossDirectApiService {
  static const String _baseUrl = 'https://openapi.tossinvest.com';

  static String get clientId => dotenv.env['TOSS_CLIENT_ID'] ?? '';
  static String get clientSecret => dotenv.env['TOSS_CLIENT_SECRET'] ?? '';

  static String? _accessToken;
  static DateTime? _tokenExpiryTime;

  /// 1. OAuth 2.0 Access Token 발급 및 캐싱
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
      // 안전하게 만료 10분 전 갱신 설정
      _tokenExpiryTime = now.add(Duration(seconds: expiresIn - 600));
      return _accessToken!;
    } else {
      throw Exception('토스 토큰 발급 실패: ${response.statusCode} - ${response.body}');
    }
  }

  /// 특정 종목 코드와 연월('yyyy-MM')을 받아 해당 월의 말일 종가를 가져옵니다.
 /// 특정 종목 코드와 연월('yyyy-MM')을 받아 해당 월의 말일 종가를 가져옵니다.
  static Future<double?> getMonthlyClosePrice(String stockCode, String yearMonth) async {
    try {
      final token = await _getAccessToken();
      
      // 해당 연월의 마지막 날짜 계산 (예: 2026-09 -> 2026-09-30)
      final parts = yearMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final lastDay = DateTime(year, month + 1, 0); 
      
      // ISO 8601 형식의 before 파라미터 생성 (해당 월 말일 장 마감 기준)
      final formattedDay = lastDay.day.toString().padLeft(2, '0');
      final formattedMonth = lastDay.month.toString().padLeft(2, '0');
      final beforeStr = '$year-$formattedMonth-${formattedDay}T23:59:59+09:00';
      
      // ✅ 올바른 캔들 조회 엔드포인트: /api/v1/candles
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

      if (response.statusCode != 200) {
        print('토스 API 응답 오류 코드: ${response.statusCode} - ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      
      // 응답 구조 파싱 (result -> candles 배열)
      if (data is Map && data['result'] != null && data['result']['candles'] != null) {
        final candles = data['result']['candles'] as List;
        if (candles.isNotEmpty) {
          // 내림차순 정렬된 캔들 중 요청한 연월(yearMonth)에 일치하는 첫 번째(가장 월말에 가까운) 데이터 선택[cite: 4]
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
      }

      return null;
    } catch (e) {
      print('토스증권 월말 시세 조회 예외 발생: $e');
      return null;
    }
  }

  /// 2. 특정 종목 코드의 실시간 가격 조회 (국내/해외 통합)
  /// [stockCode]: 국내 종목코드 (예: '005930') 또는 해외 티커 (예: 'AAPL')
  static Future<double?> getCurrentPrice(
    String stockCode,
    String yearMonth,
  ) async {
    try {
      final token = await _getAccessToken();

      // 토스증권 Open API 규격에 맞는 시세 엔드포인트 호출
      final url = Uri.parse('$_baseUrl/api/v1/prices?symbols=$stockCode');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print('토스 API 응답 오류 코드: ${response.statusCode} - ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);

      // 응답 데이터 구조에서 가격 추출 (배열 또는 객체 형태에 맞게 조정)
      if (data is Map && data['result'] != null) {
        final list = data['result'] as List;
        if (list.isNotEmpty) {
          final item = list.first;
          final priceStr =
              item['lastPrice'] ?? item['closePrice'] ?? item['price'];
          if (priceStr != null) {
            return double.tryParse(priceStr.toString());
          }
        }
      } else if (data is List && data.isNotEmpty) {
        final item = data.first;
        final priceStr =
            item['lastPrice'] ?? item['closePrice'] ?? item['price'];
        if (priceStr != null) {
          return double.tryParse(priceStr.toString());
        }
      }

      return null;
    } catch (e) {
      print('토스증권 가격 조회 예외 발생: $e');
      return null;
    }
  }
}
