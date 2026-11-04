import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../../models/monthly_data/monthly_pension_account_balance.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../utils/collection_name.dart';

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

  // 1. 월말연금잔액 엑셀 업로드 처리
  Future<void> _pickAndUploadPensionBalance() async {
    await _processExcelFile(
      title: '월말연금잔액',
      targetCollection: monthlyPensionBalanceDBName,
      rowParser: (row) {
        // A(0):기준월, B(1):계좌ID, C(2):상품ID, D(3):평가액, E(4):당월납입액, F(5):누적원금, G(6):당월수령액, H(7):누적수령액, I(8):당월인출금, J(9):누적인출금, K(10):매수일
        if (row.length < 4 || row[0] == null || row[1] == null || row[2] == null) return null;

        final rawYM = row[0]?.toString() ?? '';
        final accountId = row[1]?.toString().trim() ?? '';
        final productId = row[2]?.toString().trim() ?? '';
        if (rawYM.isEmpty || accountId.isEmpty || productId.isEmpty) return null;

        final yearMonth = _formatYearMonth(rawYM);
        final balance = double.tryParse(row[3]?.toString() ?? '0') ?? 0.0;
        final monthlyPrincipal = row.length > 4 ? double.tryParse(row[4]?.toString() ?? '0') ?? 0.0 : 0.0;
        final principal = row.length > 5 ? double.tryParse(row[5]?.toString() ?? '0') ?? 0.0 : 0.0;
        final monthlyPayout = row.length > 6 ? double.tryParse(row[6]?.toString() ?? '0') ?? 0.0 : 0.0;
        final totalPayout = row.length > 7 ? double.tryParse(row[7]?.toString() ?? '0') ?? 0.0 : 0.0;
        final monthlyWithdrawal = row.length > 8 ? double.tryParse(row[8]?.toString() ?? '0') ?? 0.0 : 0.0;
        final totalWithdrawal = row.length > 9 ? double.tryParse(row[9]?.toString() ?? '0') ?? 0.0 : 0.0;
        final rawPurchaseDate = row.length > 10 ? row[10]?.toString()?.trim() : null;

        final model = MonthlyPensionBalance(
          yearMonth: yearMonth,
          accountId: accountId,
          productId: productId,
          balance: balance,
          monthlyPrincipal: monthlyPrincipal,
          principal: principal,
          monthlyPayout: monthlyPayout,
          totalPayout: totalPayout,
          monthlyWithdrawal: monthlyWithdrawal,
          totalWithdrawal: totalWithdrawal,
          purchaseDate: (rawPurchaseDate != null && rawPurchaseDate.isNotEmpty) ? rawPurchaseDate : null,
        );

        final docId = '${yearMonth}_${accountId}_${productId}';
        return MapEntry(docId, model.toJson()..remove('id'));
      },
      onSuccessInvalidate: () {
        ref.invalidate(availableYearMonthsProvider);
        ref.invalidate(allMonthlyPensionBalancesProvider);
      },
    );
  }

  // 2. 월말연금계좌 엑셀 업로드 처리
  Future<void> _pickAndUploadAccountBalance() async {
    await _processExcelFile(
      title: '월말연금계좌',
      targetCollection: monthlyPensionAccountBalanceDBName,
      rowParser: (row) {
        // A(0):기준월, B(1):계좌ID, C(2):예수금, D(3):당월납입액, E(4):누적원금, F(5):당월인출금, G(6):누적인출금
        if (row.length < 3 || row[0] == null || row[1] == null) return null;

        final rawYM = row[0]?.toString() ?? '';
        final accountId = row[1]?.toString().trim() ?? '';
        if (rawYM.isEmpty || accountId.isEmpty) return null;

        final yearMonth = _formatYearMonth(rawYM);
        final cashBalance = double.tryParse(row[2]?.toString() ?? '0') ?? 0.0;
        final monthlyPrincipal = row.length > 3 ? double.tryParse(row[3]?.toString() ?? '0') ?? 0.0 : 0.0;
        final principal = row.length > 4 ? double.tryParse(row[4]?.toString() ?? '0') ?? 0.0 : 0.0;
        final monthlyWithdrawal = row.length > 5 ? double.tryParse(row[5]?.toString() ?? '0') ?? 0.0 : 0.0;
        final totalWithdrawal = row.length > 6 ? double.tryParse(row[6]?.toString() ?? '0') ?? 0.0 : 0.0;

        final model = MonthlyPensionAccountBalance(
          yearMonth: yearMonth,
          accountId: accountId,
          cashBalance: cashBalance,
          monthlyPrincipal: monthlyPrincipal,
          principal: principal,
          monthlyWithdrawal: monthlyWithdrawal,
          totalWithdrawal: totalWithdrawal,
        );

        final docId = '${yearMonth}_$accountId';
        return MapEntry(docId, model.toJson()..remove('id'));
      },
      onSuccessInvalidate: () {
        // 필요한 경우 계좌 관련 Provider 무효화 추가 가능
      },
    );
  }

  // 공통 엑셀 파일 피커 및 파이어스토어 일괄 업로드 로직
  Future<void> _processExcelFile({
    required String title,
    required String targetCollection,
    required MapEntry<String, Map<String, dynamic>>? Function(List<dynamic> row) rowParser,
    required VoidCallback onSuccessInvalidate,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _isLoading = true;
        _statusText = '$title 엑셀 파일 읽는 중...';
      });

      List<int>? bytes;
      final file = result.files.first;

      if (kIsWeb || file.bytes != null) {
        bytes = file.bytes;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes == null) throw Exception('파일 데이터를 읽지 못했습니다.');

      final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: false);
      if (decoder.tables.keys.isEmpty) throw Exception('엑셀 시트가 존재하지 않습니다.');

      final sheetName = decoder.tables.keys.first;
      final table = decoder.tables[sheetName];

      if (table == null || table.maxRows <= 1) {
        throw Exception('시트에 데이터가 없습니다.');
      }

      setState(() {
        _statusText = '파이어베이스에 $title 저장 중...';
      });

      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection(targetCollection);

      WriteBatch batch = firestore.batch();
      int count = 0;

      for (int i = 1; i < table.maxRows; i++) {
        final row = table.rows[i];
        if (row.isEmpty) continue;

        final parsed = rowParser(row);
        if (parsed == null) continue;

        final docRef = collectionRef.doc(parsed.key);
        batch.set(docRef, parsed.value, SetOptions(merge: true));
        count++;

        if (count % 400 == 0) {
          await batch.commit();
          batch = firestore.batch();
        }
      }

      await batch.commit();
      onSuccessInvalidate();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = '성공! [$title] 총 $count건 업로드되었습니다.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = '오류 발생 ($title): $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('연금 월말 자료 일괄 업로드'),
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
                color: Colors.teal,
              ),
              const SizedBox(height: 24),
              const Text(
                '연금 월말 엑셀 파일 업로드 안내\n'
                '• 문서 ID 규칙: YYYY-MM_계좌ID (또는 _상품ID)\n'
                '• 덮어쓰기(Merge) 방식으로 안전하게 반영됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 280,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickAndUploadAccountBalance,
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('1. 월말연금계좌 엑셀 업로드'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 280,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickAndUploadPensionBalance,
                  icon: const Icon(Icons.savings),
                  label: const Text('2. 월말연금잔액 엑셀 업로드'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
              if (_statusText != null) ...[
                const SizedBox(height: 20),
                Text(
                  _statusText!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _statusText!.startsWith('오류')
                        ? Colors.red
                        : Colors.teal.shade800,
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