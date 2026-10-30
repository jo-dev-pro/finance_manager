import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';

class StockMonthlyUploadScreen extends ConsumerStatefulWidget {
  const StockMonthlyUploadScreen({super.key});

  @override
  ConsumerState<StockMonthlyUploadScreen> createState() =>
      _StockMonthlyUploadScreenState();
}

class _StockMonthlyUploadScreenState
    extends ConsumerState<StockMonthlyUploadScreen> {
  bool _isLoading = false;
  String? _statusText;

  // YYYY.MM / YYYY.M / YYYY-M 형식을 YYYY-MM 포맷으로 정확히 정제
  String _formatYearMonth(dynamic raw) {
    String str = raw.toString().trim();
    str = str.replaceAll('.', '-').replaceAll('/', '-');

    if (str.contains('-')) {
      final parts = str.split('-');
      if (parts.length >= 2) {
        final year = parts[0].trim();
        final month = parts[1].trim().padLeft(2, '0');
        return '$year-$month';
      }
    }
    return str;
  }

  Future<void> _pickAndUploadExcel() async {
    try {
      // 1. .xlsx 파일 선택
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _isLoading = true;
        _statusText = '엑셀 파일 읽는 중...';
      });

      List<int>? bytes;
      final file = result.files.first;

      if (kIsWeb || file.bytes != null) {
        bytes = file.bytes;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes == null) throw Exception('파일 데이터를 읽지 못했습니다.');

      // 2. SpreadsheetDecoder로 엑셀 파싱
      final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: false);
      final sheetName = decoder.tables.keys.first;
      final table = decoder.tables[sheetName];

      if (table == null || table.maxRows <= 1) {
        throw Exception('시트에 데이터가 없습니다.');
      }

      setState(() {
        _statusText = '파이어베이스 저장 중...';
      });

      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection('monthly_stock_balance');

      WriteBatch batch = firestore.batch();
      int count = 0;

      for (int i = 1; i < table.maxRows; i++) {
        final row = table.rows[i];
        // 💡 엑셀 열 구성:
        // 0: 기준월, 1: 계좌ID, 2: 종목ID(또는 예수금키), 3: 수량, 4: 현재가, 5: 평가액, 6: 원금, 7: 배당금, 8: 인출금, 9: 매수일(선택)
        if (row.length < 3 || row[0] == null || row[1] == null || row[2] == null) continue;

        final rawYM = row[0]?.toString() ?? '';
        final accountId = row[1]?.toString().trim() ?? '';
        final stockItemId = row[2]?.toString().trim() ?? '';
        
        final rawQty = row.length > 3 ? row[3]?.toString() ?? '0' : '0';
        final rawPrice = row.length > 4 ? row[4]?.toString() ?? '0' : '0';
        final rawBalance = row.length > 5 ? row[5]?.toString() ?? '0' : '0';
        final rawPrincipal = row.length > 6 ? row[6]?.toString() ?? '0' : '0';
        final rawPayout = row.length > 7 ? row[7]?.toString() ?? '0' : '0';
        final rawWithdrawal = row.length > 8 ? row[8]?.toString() ?? '0' : '0';
        final rawPurchaseDate = row.length > 9 ? row[9]?.toString()?.trim() : null;

        if (rawYM.isEmpty || accountId.isEmpty || stockItemId.isEmpty) continue;

        final yearMonth = _formatYearMonth(rawYM);
        final quantity = double.tryParse(rawQty) ?? 0.0;
        final currentPrice = double.tryParse(rawPrice) ?? 0.0;
        
        double balance = double.tryParse(rawBalance) ?? 0.0;
        if (balance == 0 && quantity > 0 && currentPrice > 0) {
          balance = quantity * currentPrice; // 수량과 단가가 있으면 자동 계산
        }

        final principal = double.tryParse(rawPrincipal) ?? 0.0;
        final totalPayout = double.tryParse(rawPayout) ?? 0.0;
        final totalWithdrawal = double.tryParse(rawWithdrawal) ?? 0.0;

        final model = MonthlyStockBalance(
          yearMonth: yearMonth,
          accountId: accountId,
          stockItemId: stockItemId,
          quantity: quantity,
          currentPrice: currentPrice,
          balance: balance,
          principal: principal,
          totalPayout: totalPayout,
          totalWithdrawal: totalWithdrawal,
          purchaseDate: (rawPurchaseDate != null && rawPurchaseDate.isNotEmpty) ? rawPurchaseDate : null,
        );

        // 💡 기준월_계좌ID_종목ID 조합으로 문서 ID를 고정하여 덮어쓰기 (중복 방지)
        final docId = '${yearMonth}_${accountId}_${stockItemId}';
        final docRef = collectionRef.doc(docId);

        final docData = model.toJson()..remove('id');
        batch.set(docRef, docData, SetOptions(merge: true));
        count++;

        if (count % 400 == 0) {
          await batch.commit();
          batch = firestore.batch();
        }
      }

      await batch.commit();

      // 3. 저장 완료 후 Riverpod 캐시 무효화 (UI 즉시 반영)
      ref.invalidate(availableYearMonthsProvider);
      ref.invalidate(allMonthlyStockBalancesProvider);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = '성공! 총 $count건 업로드되었습니다.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = '오류 발생: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주식 월말자료 업로드'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.table_chart_outlined,
                size: 64,
                color: Colors.indigo,
              ),
              const SizedBox(height: 24),
              const Text(
                '엑셀 파일 양식 안내\n[A: 기준월, B: 계좌ID, C: 종목ID(또는 예수금키),\nD: 수량, E: 주당현재가, F: 평가액, G: 누적원금, H: 배당금, I: 인출금, J: 매수일]',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickAndUploadExcel,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(_isLoading ? '처리 중...' : '주식 월말 엑셀(.xlsx) 파일 선택'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              if (_statusText != null) ...[
                const SizedBox(height: 20),
                Text(
                  _statusText!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _statusText!.startsWith('오류')
                        ? Colors.red
                        : Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}