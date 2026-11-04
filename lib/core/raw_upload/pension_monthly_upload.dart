import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../../models/monthly_data/monthly_pension_account_balance.dart';
import '../../../../models/account/account.dart';
import '../../../../models/account/account_name.dart';
import '../../../../models/pension/pension_product.dart';
import '../../../../models/pension/pension_holding_product.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';
import '../../../../providers/pension/pension_holding_product_provider.dart';
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

  // YYYY.MM / YYYY.M / YYYY-M 형식을 YYYY-MM 포맷으로 정제
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

  // 1. 월말연금계좌 엑셀 업로드 (계좌명 자동 매핑 포함)
  Future<void> _pickAndUploadAccountBalance() async {
    await _processExcelFile(
      title: '월말연금계좌',
      targetCollection: monthlyPensionAccountBalanceDBName,
      rowParser: (row, accountMap, accountNameMap, productMap, purchaseDateMap) {
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

        // 계좌명 마스터에서 이름 찾기
        String? resolvedAccountName;
        final matchedAcc = accountMap[accountId];
        if (matchedAcc != null) {
          final matchedNameObj = accountNameMap[matchedAcc.accountNameId];
          if (matchedNameObj != null) {
            final inst = matchedAcc.financialInstitution;
            resolvedAccountName = '[$inst] ${matchedNameObj.accountName}';
          }
        }

        final model = MonthlyPensionAccountBalance(
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
      onSuccessInvalidate: () {},
    );
  }

  // 2. 월말연금잔액 엑셀 업로드 (계좌명, 상품명, 최초매수일 자동 매핑 포함)
  Future<void> _pickAndUploadPensionBalance() async {
    await _processExcelFile(
      title: '월말연금잔액',
      targetCollection: monthlyPensionBalanceDBName,
      rowParser: (row, accountMap, accountNameMap, productMap, purchaseDateMap) {
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
        
        // 엑셀에 수동 입력된 매수일이 있다면 우선 사용, 없으면 연금보유상품 마스터에서 조회
        String? rawPurchaseDate = row.length > 10 ? row[10]?.toString()?.trim() : null;
        if (rawPurchaseDate == null || rawPurchaseDate.isEmpty) {
          rawPurchaseDate = purchaseDateMap['${accountId}_${productId}'];
        }

        // 계좌명 찾기
        String? resolvedAccountName;
        final matchedAcc = accountMap[accountId];
        if (matchedAcc != null) {
          final matchedNameObj = accountNameMap[matchedAcc.accountNameId];
          if (matchedNameObj != null) {
            final inst = matchedAcc.financialInstitution;
            resolvedAccountName = '[$inst] ${matchedNameObj.accountName}';
          }
        }

        // 상품명 찾기
        String? resolvedProductName;
        if (productId == '_CASH_ASSET_PRODUCT_ID_') {
          resolvedProductName = '💵 계좌 공통 현금성 자산 (예수금)';
        } else {
          final matchedProd = productMap[productId.trim()];
          if (matchedProd != null) {
            resolvedProductName = matchedProd.productName;
          }
        }

        final model = MonthlyPensionBalance(
          yearMonth: yearMonth,
          accountId: accountId,
          productId: productId,
          accountName: resolvedAccountName,
          productName: resolvedProductName,
          balance: balance,
          monthlyPrincipal: monthlyPrincipal,
          principal: principal,
          monthlyPayout: monthlyPayout,
          totalPayout: totalPayout,
          monthlyWithdrawal: monthlyWithdrawal,
          totalWithdrawal: totalWithdrawal,
          purchaseDate: (rawPurchaseDate != null && rawPurchaseDate.isNotEmpty) ? rawPurchaseDate : null,
        );

        final docId = '${yearMonth}_${accountId}_$productId';
        return MapEntry(docId, model.toJson()..remove('id'));
      },
      onSuccessInvalidate: () {
        ref.invalidate(availableYearMonthsProvider);
        ref.invalidate(allMonthlyPensionBalancesProvider);
      },
    );
  }

  // 공통 엑셀 파일 처리 및 마스터 데이터(보유상품 포함) 로드 로직
  Future<void> _processExcelFile({
    required String title,
    required String targetCollection,
    required MapEntry<String, Map<String, dynamic>>? Function(
      List<dynamic> row,
      Map<String, Account> accountMap,
      Map<String, AccountName> accountNameMap,
      Map<String, PensionProduct> productMap,
      Map<String, String> purchaseDateMap,
    ) rowParser,
    required VoidCallback onSuccessInvalidate,
  }) async {
    try {
      // 1. 마스터 데이터 및 연금보유상품 데이터 미리 로드
      final accounts = await ref.read(accountNotifierProvider.future);
      final accountNames = await ref.read(accountNameNotifierProvider.future);
      final products = await ref.read(pensionProductNotifierProvider.future);
      
      List<PensionHoldingProduct> holdingProducts = [];
      try {
        holdingProducts = await ref.read(pensionHoldingProductNotifierProvider.future);
      } catch (_) {}

      final accountMap = {for (var a in accounts) if (a.id != null) a.id!: a};
      final accountNameMap = {for (var an in accountNames) if (an.id != null) an.id!: an};
      final productMap = {for (var p in products) if (p.id != null) p.id!.trim(): p};
      
      // 💡 'accountId_productId'를 키로 하여 최초매수일(initialPurchaseDate) 맵 구성
      final purchaseDateMap = {
        for (var hp in holdingProducts)
          if (hp.initialPurchaseDate != null && hp.initialPurchaseDate!.isNotEmpty)
            '${hp.accountId}_${hp.productId}': hp.initialPurchaseDate!
      };

      // 2. 파일 피커 실행
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
        _statusText = '파이어베이스에 정보 매핑 및 $title 저장 중...';
      });

      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection(targetCollection);

      WriteBatch batch = firestore.batch();
      int count = 0;

      for (int i = 1; i < table.maxRows; i++) {
        final row = table.rows[i];
        if (row.isEmpty) continue;

        final parsed = rowParser(row, accountMap, accountNameMap, productMap, purchaseDateMap);
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
          _statusText = '성공! [$title] 총 $count건 업로드 및 자동 매핑 완료되었습니다.';
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
        title: const Text('연금 월말 자료 일괄 업로드 (자동 매핑)'),
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
                '• 계좌명, 상품명, 최초매수일이 마스터 DB에서 자동으로 매핑되어 저장됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 300,
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
                width: 300,
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