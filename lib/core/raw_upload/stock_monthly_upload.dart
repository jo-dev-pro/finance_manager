import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../../../../core/utils/collection_name.dart';
import '../../../../core/utils/toss_direct_api_service.dart';
import '../../../../core/utils/upbit_api_service.dart';
import '../../../../models/monthly_data/monthly_stock_account_balance.dart';
import '../../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../../models/account/account.dart';
import '../../../../models/account/account_name.dart';
import '../../../../models/stock/stock_item.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
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

  // 기준월 포맷 정제 (Excel Serial Date 또는 YYYY.MM 등을 YYYY-MM으로 변환)
  String _formatYearMonth(dynamic raw) {
    if (raw == null) return '';
    String str = raw.toString().trim();
    if (str.isEmpty) return '';

    if (double.tryParse(str) != null && !str.contains('.') && !str.contains('-') && !str.contains('/')) {
      try {
        final days = double.parse(str);
        final dt = DateTime(1899, 12, 30).add(Duration(days: days.toInt()));
        return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

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

  // 1. 월말 주식 계좌 엑셀 업로드 (기존 파일 선택 방식 유지)
  Future<void> _pickAndUploadAccountBalance() async {
    await _processFilePickerExcel(
      title: '월말주식계좌',
      targetCollection: monthlyStockAccountBalanceDBName,
      isAccount: true,
      rowParser: (row, accountMap, accountNameMap, stockItemMap) {
        if (row.length < 4 || row[0] == null || row[1] == null) return null;

        final rawYM = row[0]; // 1열: 기준년월
        final accountId = row[1]?.toString().trim() ?? ''; // 2열: 계좌id
        if (accountId.isEmpty) return null;

        final yearMonth = _formatYearMonth(rawYM);
        if (yearMonth.isEmpty) return null;

        // 엑셀 열 순서: 1열 기준년월, 2열 계좌id, 3열 계좌명, 4열 잔액, 5열 당월입금액, 6열 누적입금액, 7열 당월인출액, 8열 누적인출액
        final cashBalance = row.length > 3 && row[3] != null ? double.tryParse(row[3].toString().replaceAll(',', '').trim()) ?? 0.0 : 0.0;
        final monthlyPrincipal = row.length > 4 && row[4] != null ? double.tryParse(row[4].toString().replaceAll(',', '').trim()) ?? 0.0 : 0.0;
        final principal = row.length > 5 && row[5] != null ? double.tryParse(row[5].toString().replaceAll(',', '').trim()) ?? 0.0 : 0.0;
        final monthlyWithdrawal = row.length > 6 && row[6] != null ? double.tryParse(row[6].toString().replaceAll(',', '').trim()) ?? 0.0 : 0.0;
        final totalWithdrawal = row.length > 7 && row[7] != null ? double.tryParse(row[7].toString().replaceAll(',', '').trim()) ?? 0.0 : 0.0;

        String? resolvedAccountName;
        final matchedAcc = accountMap[accountId];
        if (matchedAcc != null) {
          final matchedNameObj = accountNameMap[matchedAcc.accountNameId];
          if (matchedNameObj != null) {
            final inst = matchedAcc.financialInstitution;
            resolvedAccountName = '[$inst] ${matchedNameObj.accountName}';
          }
        }
        if ((resolvedAccountName == null || resolvedAccountName.isEmpty) && row.length > 2 && row[2] != null) {
          resolvedAccountName = row[2].toString().trim();
        }

        final model = MonthlyStockAccountBalance(
          yearMonth: yearMonth,
          accountId: accountId,
          accountName: resolvedAccountName,
          cashBalance: cashBalance,
          monthlyPrincipal: monthlyPrincipal,
          principal: principal,
          monthlyWithdrawal: monthlyWithdrawal,
          totalWithdrawal: totalWithdrawal,
        );

        final docId = '${yearMonth}_$accountId';
        return MapEntry(docId, model.toJson()..remove('id'));
      },
      onSuccessInvalidate: (ym) {
        ref.invalidate(monthlyStockAccountBalanceNotifierProvider(ym));
        ref.invalidate(allMonthlyStockAccountBalancesProvider);
      },
    );
  }

  // 2. 월말 주식 잔액(종목별) - assets/월말주식잔액.xlsx 에셋 파일 자동 업로드
  Future<void> _uploadStockBalanceFromAsset() async {
    await _processAssetExcelFile(
      title: '월말주식잔액',
      targetCollection: monthlyStockBalanceDBName,
      assetPath: 'assets/월말주식잔액.xlsx',
      isAccount: false,
      rowParser: (row, accountMap, accountNameMap, stockItemMap) {
        if (row.length < 6 || row[0] == null || row[1] == null || row[2] == null) return null;

        final rawYM = row[0]; // 1열: 기준년월
        final accountId = row[1]?.toString().trim() ?? ''; // 2열: 계좌id
        final stockItemId = row[2]?.toString().trim() ?? ''; // 3열: 종목id
        if (accountId.isEmpty || stockItemId.isEmpty) return null;

        final yearMonth = _formatYearMonth(rawYM);
        if (yearMonth.isEmpty) return null;

        // 15개 열 순서 매핑
        final quantity = row.length > 5 && row[5] != null ? double.tryParse(row[5].toString().replaceAll(',', '').trim()) ?? 0.0 : 0.0;
        
        double currentPrice = row.length > 6 && row[6] != null && row[6].toString().trim().isNotEmpty 
            ? double.tryParse(row[6].toString().replaceAll(',', '').trim()) ?? 0.0 
            : 0.0;
            
        double balance = row.length > 7 && row[7] != null && row[7].toString().trim().isNotEmpty 
            ? double.tryParse(row[7].toString().replaceAll(',', '').trim()) ?? 0.0 
            : 0.0;

        final monthlyPrincipal = row.length > 8 && row[8] != null ? double.tryParse(row[8].toString().replaceAll(',', '').trim()) ?? 0.0 : 0.0;
        final principal = row.length > 9 && row[9] != null ? double.tryParse(row[9].toString().replaceAll(',', '').trim()) ?? 0.0 : 0.0;
        
        final monthlyPayout = row.length > 10 && row[10] != null ? double.tryParse(row[10].toString().replaceAll(',', '').trim()) ?? 0.0 : 0.0;
        final totalPayout = row.length > 11 && row[11] != null ? double.tryParse(row[11].toString().replaceAll(',', '').trim()) ?? 0.0 : 0.0;
        
        final monthlyWithdrawal = row.length > 12 && row[12] != null ? double.tryParse(row[12].toString().replaceAll(',', '').trim()) ?? 0.0 : 0.0;
        final totalWithdrawal = row.length > 13 && row[13] != null ? double.tryParse(row[13].toString().replaceAll(',', '').trim()) ?? 0.0 : 0.0;

        // 매수일 파싱
        final rawPurchaseDate = row.length > 14 ? row[14] : null;
        String? purchaseDate;
        if (rawPurchaseDate != null) {
          final pStr = rawPurchaseDate.toString().trim();
          if (double.tryParse(pStr) != null && !pStr.contains('-') && !pStr.contains('.')) {
            try {
              final days = double.parse(pStr);
              final dt = DateTime(1899, 12, 30).add(Duration(days: days.toInt()));
              purchaseDate = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
            } catch (_) {}
          } else if (pStr.isNotEmpty) {
            purchaseDate = pStr.replaceAll('.', '-').replaceAll('/', '-');
          }
        }

        // 계좌명 자동 매핑
        String? resolvedAccountName;
        final matchedAcc = accountMap[accountId];
        if (matchedAcc != null) {
          final matchedNameObj = accountNameMap[matchedAcc.accountNameId];
          if (matchedNameObj != null) {
            final inst = matchedAcc.financialInstitution;
            resolvedAccountName = '[$inst] ${matchedNameObj.accountName}';
          }
        }
        if ((resolvedAccountName == null || resolvedAccountName.isEmpty) && row.length > 3 && row[3] != null) {
          resolvedAccountName = row[3].toString().trim();
        }

        // 종목명 자동 매핑 ("종목명 (종목코드)" 형식)
        String? resolvedStockName;
        final matchedStock = stockItemMap[stockItemId];
        if (matchedStock != null) {
          resolvedStockName = '${matchedStock.itemName} (${matchedStock.stockCode})';
        }
        if ((resolvedStockName == null || resolvedStockName.isEmpty) && row.length > 4 && row[4] != null) {
          resolvedStockName = row[4].toString().trim();
        }

        final model = MonthlyStockBalance(
          yearMonth: yearMonth,
          accountId: accountId,
          stockItemId: stockItemId,
          accountName: resolvedAccountName,
          stockItemName: resolvedStockName,
          quantity: quantity,
          currentPrice: currentPrice,
          balance: balance,
          principal: principal,
          monthlyPrincipal: monthlyPrincipal,
          totalPayout: totalPayout,
          monthlyPayout: monthlyPayout,
          totalWithdrawal: totalWithdrawal,
          monthlyWithdrawal: monthlyWithdrawal,
          purchaseDate: (purchaseDate != null && purchaseDate.isNotEmpty) ? purchaseDate : null,
        );

        final docId = '${yearMonth}_${accountId}_$stockItemId';
        return MapEntry(docId, model);
      },
      onSuccessInvalidate: (ym) {
        ref.invalidate(monthlyStockBalanceNotifierProvider(ym));
        ref.invalidate(allMonthlyStockBalancesProvider);
        ref.invalidate(availableYearMonthsProvider);
      },
    );
  }

  // FilePicker를 사용하는 공통 처리 메서드 (월말주식계좌용)
  Future<void> _processFilePickerExcel({
    required String title,
    required String targetCollection,
    required bool isAccount,
    required dynamic Function(
      List<dynamic> row,
      Map<String, Account> accountMap,
      Map<String, AccountName> accountNameMap,
      Map<String, StockItem> stockItemMap,
    ) rowParser,
    required Function(String yearMonth) onSuccessInvalidate,
  }) async {
    try {
      final accounts = await ref.read(accountNotifierProvider.future);
      final accountNames = await ref.read(accountNameNotifierProvider.future);
      final stockItems = await ref.read(stockItemNotifierProvider.future);

      final accountMap = {for (var a in accounts) if (a.id != null) a.id!: a};
      final accountNameMap = {for (var an in accountNames) if (an.id != null) an.id!: an};
      final stockItemMap = {for (var s in stockItems) if (s.id != null) s.id!: s};

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
        _statusText = '파이어베이스 저장 중...';
      });

      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection(targetCollection);

      WriteBatch batch = firestore.batch();
      int count = 0;
      String? lastProcessedYearMonth;

      for (int i = 1; i < table.maxRows; i++) {
        final row = table.rows[i];
        if (row.isEmpty) continue;

        final parsed = rowParser(row, accountMap, accountNameMap, stockItemMap);
        if (parsed == null) continue;

        String docId = parsed.key;
        Map<String, dynamic> dataMap = parsed.value;
        String yearMonth = docId.split('_').first;
        lastProcessedYearMonth = yearMonth;

        final docRef = collectionRef.doc(docId);
        batch.set(docRef, dataMap, SetOptions(merge: true));
        count++;

        if (count % 400 == 0) {
          await batch.commit();
          batch = firestore.batch();
        }
      }

      await batch.commit();
      if (lastProcessedYearMonth != null) {
        onSuccessInvalidate(lastProcessedYearMonth);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = '성공! [$title] 총 $count건 업로드 완료되었습니다.';
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

 // 에셋 파일을 읽어 처리하는 공통 메서드 (월말주식잔액용 + 토스 API 연동 + 딜레이 적용)
  Future<void> _processAssetExcelFile({
    required String title,
    required String targetCollection,
    required String assetPath,
    required bool isAccount,
    required dynamic Function(
      List<dynamic> row,
      Map<String, Account> accountMap,
      Map<String, AccountName> accountNameMap,
      Map<String, StockItem> stockItemMap,
    ) rowParser,
    required Function(String yearMonth) onSuccessInvalidate,
  }) async {
    try {
      final accounts = await ref.read(accountNotifierProvider.future);
      final accountNames = await ref.read(accountNameNotifierProvider.future);
      final stockItems = await ref.read(stockItemNotifierProvider.future);

      final accountMap = {for (var a in accounts) if (a.id != null) a.id!: a};
      final accountNameMap = {for (var an in accountNames) if (an.id != null) an.id!: an};
      final stockItemMap = {for (var s in stockItems) if (s.id != null) s.id!: s};

      setState(() {
        _isLoading = true;
        _statusText = '$assetPath 파일 읽는 중...';
      });

      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: false);
      if (decoder.tables.keys.isEmpty) throw Exception('엑셀 시트가 존재하지 않습니다.');

      final sheetName = decoder.tables.keys.first;
      final table = decoder.tables[sheetName];

      if (table == null || table.maxRows <= 1) {
        throw Exception('시트에 데이터가 없습니다.');
      }

      setState(() {
        _statusText = '파이어베이스 저장 및 토스 시세 매핑 중... (API 제한 방지 딜레이 적용)';
      });

      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection(targetCollection);

      WriteBatch batch = firestore.batch();
      int count = 0;
      String? lastProcessedYearMonth;

      for (int i = 1; i < table.maxRows; i++) {
        final row = table.rows[i];
        if (row.isEmpty) continue;

        final parsed = rowParser(row, accountMap, accountNameMap, stockItemMap);
        if (parsed == null) continue;

        Map<String, dynamic> dataMap;
        String docId = parsed.key;
        MonthlyStockBalance balanceModel = parsed.value;
        String yearMonth = docId.split('_').first;
        lastProcessedYearMonth = yearMonth;

      // 현재가 또는 평가액이 0이고 수량이 있는 경우 시세 자동 조회
        if ((balanceModel.currentPrice == 0 || balanceModel.balance == 0) && balanceModel.quantity > 0) {
          final stockItem = stockItemMap[balanceModel.stockItemId];
          if (stockItem != null && stockItem.stockCode.trim().isNotEmpty) {
            final symbol = stockItem.stockCode.trim();
            double? price;

            try {
              if (symbol.startsWith('KRW-')) {
                // 💡 1. 가상자산인 경우 업비트 API 호출 (요청 간 150ms 딜레이)
                await Future.delayed(const Duration(milliseconds: 150));
                price = await UpbitApiService.getMonthlyClosePrice(symbol, balanceModel.yearMonth);
                
                if (price != null && price > 0) {
                  print('✅ [업비트 시세 성공] $symbol (${balanceModel.yearMonth}): $price원');
                } else {
                  print('⚠️ [업비트 시세 실패] $symbol (${balanceModel.yearMonth})');
                }
              } else {
                // 💡 2. 주식 종목인 경우 토스 API 호출 (429 에러 방지 1초 딜레이)
                await Future.delayed(const Duration(milliseconds: 1000));
                price = await TossDirectApiService.getMonthlyClosePrice(symbol, balanceModel.yearMonth);

                if (price != null && price > 0) {
                  print('✅ [토스 시세 성공] $symbol (${balanceModel.yearMonth}): $price원');
                } else {
                  print('⚠️ [토스 시세 실패] $symbol (${balanceModel.yearMonth})');
                }
              }

              // 조회된 가격이 있으면 현재가 및 평가액 반영
              if (price != null && price > 0) {
                final calculatedBalance = balanceModel.quantity * price;
                balanceModel = balanceModel.copyWith(
                  currentPrice: price,
                  balance: calculatedBalance,
                );
              }
            } catch (e) {
              print('❌ [시세 조회 예외 발생] ($symbol): $e');
            }
          }
        }
        
        dataMap = balanceModel.toJson()..remove('id');

        final docRef = collectionRef.doc(docId);
        batch.set(docRef, dataMap, SetOptions(merge: true));
        count++;

        if (count % 400 == 0) {
          await batch.commit();
          batch = firestore.batch();
        }
      }

      await batch.commit();
      if (lastProcessedYearMonth != null) {
        onSuccessInvalidate(lastProcessedYearMonth);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = '성공! [$title] 에셋 파일에서 총 $count건 업로드 및 토스 시세 매핑 완료!';
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
      appBar: AppBar(title: const Text('주식 월말 자료 업로드')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.table_chart_outlined, size: 64, color: Colors.indigo),
              const SizedBox(height: 24),
              const Text(
                '주식 월말 엑셀 파일 업로드 안내\n'
                '• 월말주식계좌: 파일 선택 방식\n'
                '• 월말주식잔액: assets/월말주식잔액.xlsx 자동 업로드 (토스 시세연동)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 320,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickAndUploadAccountBalance,
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('1. 월말주식계좌 엑셀 업로드 (파일선택)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 320,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _uploadStockBalanceFromAsset,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('2. 월말주식잔액 에셋 업로드 (토스시세연동)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.teal.shade600,
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
                    color: _statusText!.startsWith('오류') ? Colors.red : Colors.indigo.shade800,
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