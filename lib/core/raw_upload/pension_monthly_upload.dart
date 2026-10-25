import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';

class PensionMonthlyUploadScreen extends ConsumerStatefulWidget {
  const PensionMonthlyUploadScreen({super.key});

  @override
  ConsumerState<PensionMonthlyUploadScreen> createState() =>
      _PensionMonthlyUploadScreenState();
}

class _PensionMonthlyUploadScreenState
    extends ConsumerState<PensionMonthlyUploadScreen> {
  bool _isLoading = false;
  String? _statusText;

  // 💡 YYYY.MM / YYYY.M / YYYY-M 형식을 YYYY-MM 포맷으로 정확히 정제
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
      final collectionRef = firestore.collection('monthly_pension_balance');

      WriteBatch batch = firestore.batch();
      int count = 0;

      for (int i = 1; i < table.maxRows; i++) {
        final row = table.rows[i];
        // 💡 엑셀 열 구성: 0(기준월), 1(계좌ID), 2(상품ID), 3(평가액), 4(원금), 5(수령액), 6(인출금)
        if (row.length < 4 || row[0] == null || row[1] == null || row[2] == null) continue;

        final rawYM = row[0]?.toString() ?? '';
        final accountId = row[1]?.toString().trim() ?? '';
        final productId = row[2]?.toString().trim() ?? '';
        
        final rawBalance = row.length > 3 ? row[3]?.toString() ?? '0' : '0';
        final rawPrincipal = row.length > 4 ? row[4]?.toString() ?? '0' : '0';
        final rawPayout = row.length > 5 ? row[5]?.toString() ?? '0' : '0';
        final rawWithdrawal = row.length > 6 ? row[6]?.toString() ?? '0' : '0';

        if (rawYM.isEmpty || accountId.isEmpty || productId.isEmpty) continue;

        final yearMonth = _formatYearMonth(rawYM);
        final balance = double.tryParse(rawBalance) ?? 0.0;
        final principal = double.tryParse(rawPrincipal) ?? 0.0;
        final totalPayout = double.tryParse(rawPayout) ?? 0.0;
        final totalWithdrawal = double.tryParse(rawWithdrawal) ?? 0.0;

        final model = MonthlyPensionBalance(
          yearMonth: yearMonth,
          accountId: accountId,
          productId: productId,
          balance: balance,
          principal: principal,
          totalPayout: totalPayout,
          totalWithdrawal: totalWithdrawal,
        );

        final docData = model.toJson()..remove('id');
        batch.set(collectionRef.doc(), docData);
        count++;

        if (count % 400 == 0) {
          await batch.commit();
          batch = firestore.batch();
        }
      }

      await batch.commit();

      // 3. 저장 완료 후 Riverpod 캐시 무효화 (UI 즉시 반영)
      ref.invalidate(availableYearMonthsProvider);
      ref.invalidate(allMonthlyPensionBalancesProvider);

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
        title: const Text('연금 월말자료 업로드'),
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
                '엑셀 파일 양식 안내\n[A열: 기준월, B열: 계좌ID, C열: 상품ID(또는 현금성키),\nD열: 평가액, E열: 누적원금, F열: 누적수령액, G열: 누적인출금]',
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
                label: Text(_isLoading ? '처리 중...' : '연금 월말 엑셀(.xlsx) 파일 선택'),
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