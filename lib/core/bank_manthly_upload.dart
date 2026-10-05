import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../models/monthly_data/monthly_bank_balance.dart';
import '../providers/dashboard/dashboard_provider.dart';
import '../providers/monthly_data/monthly_bank_balance_provider.dart';

class BankMonthlyUploadScreen extends ConsumerStatefulWidget {
  const BankMonthlyUploadScreen({super.key});

  @override
  ConsumerState<BankMonthlyUploadScreen> createState() =>
      _BankMonthlyUploadScreenState();
}

class _BankMonthlyUploadScreenState
    extends ConsumerState<BankMonthlyUploadScreen> {
  bool _isLoading = false;
  String? _statusText;

  // 💡 YYYY.MM / YYYY.M / YYYY-M 형식을 YYYY-MM 포맷으로 정확히 정제
  String _formatYearMonth(dynamic raw) {
    String str = raw.toString().trim();

    // 구분자 통일 (. 또는 / 를 - 로 변경)
    str = str.replaceAll('.', '-').replaceAll('/', '-');

    if (str.contains('-')) {
      final parts = str.split('-');
      if (parts.length >= 2) {
        final year = parts[0].trim();
        // padLeft를 써야 '1' -> '01'이 됩니다. (기존 padRight 버그 수정)
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
      final collectionRef = firestore.collection('monthly_bank_balance');

      WriteBatch batch = firestore.batch();
      int count = 0;

      for (int i = 1; i < table.maxRows; i++) {
        final row = table.rows[i];
        if (row.length < 3 || row[0] == null) continue;

        final rawYM = row[0]?.toString() ?? '';
        final accountId = row[1]?.toString().trim() ?? '';
        final rawBalance = row[2]?.toString() ?? '0';

        if (rawYM.isEmpty || accountId.isEmpty) continue;

        final yearMonth = _formatYearMonth(rawYM);
        final balance = double.tryParse(rawBalance) ?? 0.0;

        final model = MonthlyBankBalance(
          yearMonth: yearMonth,
          accountId: accountId,
          balance: balance,
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

      // 💡 3. 저장 완료 후 Riverpod 캐시 무효화 (UI 즉시 반영)
      ref.invalidate(availableYearMonthsProvider);
      ref.invalidate(allMonthlyBankBalancesProvider);

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
        title: const Text('은행 월말자료 업로드'),
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
                color: Colors.blue,
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
                label: Text(_isLoading ? '처리 중...' : '구글시트 엑셀(.xlsx) 파일 선택'),
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
                        : Colors.blue,
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