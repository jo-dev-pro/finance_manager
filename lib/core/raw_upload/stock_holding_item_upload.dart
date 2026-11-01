import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../../../../core/utils/collection_name.dart';
import '../../../../models/stock/stock_holding_item.dart';
import '../../../../providers/stock/stock_holding_item_provider.dart';

class StockHoldingUploadScreen extends ConsumerStatefulWidget {
  const StockHoldingUploadScreen({super.key});

  @override
  ConsumerState<StockHoldingUploadScreen> createState() =>
      _StockHoldingUploadScreenState();
}

class _StockHoldingUploadScreenState
    extends ConsumerState<StockHoldingUploadScreen> {
  bool _isLoading = false;
  String? _statusText;

  // 💡 날짜 포맷 정제 (예: YY-MM-DD 또는 YYYY.MM.DD 등을 YYYY-MM-DD로 변환)
  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    String str = raw.toString().trim();
    if (str.isEmpty) return '';

    str = str.replaceAll('.', '-').replaceAll('/', '-');
    final parts = str.split('-');
    if (parts.length >= 3) {
      String year = parts[0].trim();
      if (year.length == 2) {
        year = '20$year'; // 25 -> 2025
      }
      final month = parts[1].trim().padLeft(2, '0');
      final day = parts[2].trim().padLeft(2, '0');
      return '$year-$month-$day';
    }
    return str;
  }

  // 💡 boolean 값 파싱 (true/false, 1/0, O/X 등 대응)
  bool _parseBool(dynamic raw) {
    if (raw == null) return true;
    if (raw is bool) return raw;
    String str = raw.toString().trim().toLowerCase();
    if (str == 'false' || str == '0' || str == 'x' || str == 'n') {
      return false;
    }
    return true;
  }

  Future<void> _pickAndUploadExcel() async {
    try {
      // 1. .xlsx / .xls 파일 선택
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
      // 💡 주식 보유종목 컬렉션명 (collection_name.dart에 정의된 상수 사용)
      final collectionRef = firestore.collection(stockHoldingItemDBName);

      WriteBatch batch = firestore.batch();
      int count = 0;

      // 3. 행 순회 (헤더 row 0 제외, i = 1부터 시작)
      for (int i = 1; i < table.maxRows; i++) {
        final row = table.rows[i];
        // 💡 엑셀 열 구성: 0(account_id), 1(stock_item_id), 2(is_active), 3(initial_purchase_date)
        if (row.length < 2 || row[0] == null || row[1] == null) continue;

        final accountId = row[0]?.toString().trim() ?? '';
        final stockItemId = row[1]?.toString().trim() ?? '';
        
        if (accountId.isEmpty || stockItemId.isEmpty) continue;

        final rawActive = row.length > 2 ? row[2] : true;
        final rawDate = row.length > 3 ? row[3] : null;

        final isActive = _parseBool(rawActive);
        final initialPurchaseDate = _formatDate(rawDate);

        final model = StockHoldingItem(
          accountId: accountId,
          stockItemId: stockItemId,
          isActive: isActive,
          initialPurchaseDate: initialPurchaseDate.isNotEmpty ? initialPurchaseDate : null,
        );

        // 💡 재매수 이력 보존을 위해 고정 ID 대신 .doc() 자동 생성 ID 사용 (.add와 동일 효과)
        final docRef = collectionRef.doc();
        final docData = model.toJson()..remove('id');

        batch.set(docRef, docData);
        count++;

        // Firestore Batch 최대 제한(500건) 고려하여 400건마다 커밋
        if (count % 400 == 0) {
          await batch.commit();
          batch = firestore.batch();
        }
      }

      await batch.commit();

      // 4. 저장 완료 후 Riverpod 캐시 무효화 (UI 즉시 반영)
      ref.invalidate(stockHoldingItemNotifierProvider);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = '성공! 총 $count건의 주식 보유종목이 업로드되었습니다.';
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
        title: const Text('주식 보유종목 일괄 업로드'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: Colors.indigo,
              ),
              const SizedBox(height: 24),
              const Text(
                '엑셀 파일 양식 안내\n[A열: account_id, B열: stock_item_id,\nC열: is_active (true/false), D열: initial_purchase_date (YYYY-MM-DD)]',
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
                label: Text(_isLoading ? '처리 중...' : '주식 보유종목 엑셀(.xlsx) 파일 선택'),
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