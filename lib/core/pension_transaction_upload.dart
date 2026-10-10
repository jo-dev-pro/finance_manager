import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../models/pension/pension_transaction.dart';
import '../providers/pension/pension_transaction_provider.dart';

class PensionTransactionUploadScreen extends ConsumerStatefulWidget {
  const PensionTransactionUploadScreen({super.key});

  @override
  ConsumerState<PensionTransactionUploadScreen> createState() =>
      _PensionTransactionUploadScreenState();
}

class _PensionTransactionUploadScreenState
    extends ConsumerState<PensionTransactionUploadScreen> {
  bool _isLoading = false;
  String? _statusText;

  // 💡 엑셀 Serial Number(숫자 날짜)를 변환하는 헬퍼 함수 추가
  String _formatDate(dynamic raw) {
    if (raw == null) return '';

    // 1. 숫자이거나 문자열 형태의 숫자(예: "44545" 또는 "44545.0")인 경우 처리
    num? numericValue;
    if (raw is num) {
      numericValue = raw;
    } else {
      final cleaned = raw.toString().trim();
      numericValue = double.tryParse(cleaned);
    }

    // 엑셀 날짜 시리얼 번호 범위에 해당한다면 (예: 30000 이상은 1982년 이후) 날짜로 변환
    if (numericValue != null && numericValue > 30000 && numericValue < 60000) {
      final DateTime excelEpoch = DateTime(1899, 12, 30);
      final DateTime convertedDate = excelEpoch.add(
        Duration(days: numericValue.toInt()),
      );
      return '${convertedDate.year.toString().padLeft(4, '0')}-'
          '${convertedDate.month.toString().padLeft(2, '0')}-'
          '${convertedDate.day.toString().padLeft(2, '0')}';
    }

    // 2. 이미 "2021-08-15" 또는 "2021.08.15" 같은 일반 문자열 형태인 경우
    String str = raw.toString().trim();
    str = str.replaceAll('.', '-').replaceAll('/', '-');

    final parts = str.split('-');
    if (parts.length >= 3) {
      final year = parts[0].trim();
      final month = parts[1].trim().padLeft(2, '0');
      final day = parts[2].trim().padLeft(2, '0');
      return '$year-$month-$day';
    }

    return str;
  }

  Future<void> _pickAndUploadExcel() async {
    try {
      // 1. .xlsx 파일 선택[cite: 13]
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _isLoading = true;
        _statusText = '엑셀 파일 읽는 중...[cite: 13]';
      });

      List<int>? bytes;
      final file = result.files.first;

      if (kIsWeb || file.bytes != null) {
        bytes = file.bytes;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes == null) throw Exception('파일 데이터를 읽지 못했습니다.[cite: 13]');

      // 2. SpreadsheetDecoder로 엑셀 파싱[cite: 13]
      final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: false);
      final sheetName = decoder.tables.keys.first;
      final table = decoder.tables[sheetName];

      if (table == null || table.maxRows <= 1) {
        throw Exception('시트에 데이터가 없습니다.[cite: 13]');
      }

      setState(() {
        _statusText = '파이어베이스 저장 중...[cite: 13]';
      });

      final firestore = FirebaseFirestore.instance;
      // 연금 거래 데이터가 저장되는 컬렉션명 (기존 정의된 이름 사용 가능)
      final collectionRef = firestore.collection('pension_transaction');

      WriteBatch batch = firestore.batch();
      int count = 0;

      // 💡 엑셀 컬럼 구조 예시 (엑셀 양식에 맞춰 인덱스 조정 필요)
      // row[0]: 거래일자 (transactionDate)
      // row[1]: 계좌 ID (accountId)
      // row[2]: 상품 ID (productId - 선택)
      // row[3]: 거래구분 ID (transactionTypeId)
      // row[4]: 금액 (amount)
      // row[5]: 메모 (memo - 선택)
      // row[6]: 상품 매수일 (purchaseDate - 선택)
      for (int i = 1; i < table.maxRows; i++) {
        final row = table.rows[i];

        if (row.isEmpty ||
            row.every(
              (cell) => cell == null || cell.toString().trim().isEmpty,
            )) {
          continue;
        }

        if (row.length < 5 || row[0] == null) {
          continue;
        }

        final rawDate = row[0]?.toString() ?? '';
        final accountId = row[1]?.toString().trim() ?? '';
        final transactionTypeId = row[2]?.toString().trim() ?? '';
        final rawProductId = row[3]?.toString().trim() ?? '';
        final rawAmount = row[4]?.toString() ?? '0';
        final memo =
            row.length > 5 && row[5] != null ? row[5]?.toString().trim() : null;
        final rawPurchaseDate =
            row.length > 6 && row[6] != null ? row[6]?.toString().trim() : null;

        if (rawDate.isEmpty || accountId.isEmpty || transactionTypeId.isEmpty) {
          continue;
        }

        final transactionDate = _formatDate(rawDate);
        final amount = double.tryParse(rawAmount) ?? 0.0;
        final productId = rawProductId.isEmpty ? null : rawProductId;
        final purchaseDate =
            (rawPurchaseDate == null || rawPurchaseDate.isEmpty)
                ? null
                : _formatDate(rawPurchaseDate);

        final model = PensionTransaction(
          transactionDate: transactionDate,
          accountId: accountId,
          productId: productId,
          transactionTypeId: transactionTypeId,
          amount: amount,
          memo: (memo == null || memo.isEmpty) ? null : memo,
          purchaseDate: purchaseDate,
          sortOrder: i, // 💡 엑셀의 행 번호를 순서로 지정하여 순서 고정
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

      // 3. 저장 완료 후 Riverpod 캐시 무효화 (UI 즉시 반영)[cite: 13]
      ref.invalidate(pensionTransactionNotifierProvider);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = '성공! 총 $count건의 연금 거래내역이 업로드되었습니다.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = '오류 발생: $e[cite: 13]';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('연금 거래내역 업로드')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.upload_file_rounded,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickAndUploadExcel,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.table_view),
                label: Text(_isLoading ? '처리 중...' : '연금 거래 엑셀(.xlsx) 파일 선택'),
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
                    color:
                        _statusText!.startsWith('오류')
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
