import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/account/account_name_provider.dart';
import '../../providers/account/account_provider.dart';
import '../../providers/pension/pension_product_provider.dart';
import '../../providers/stock/stock_item_provider.dart';
import '../utils/collection_name.dart';
import '../../core/providers/firestore_provider.dart';

class FirestoreDBMigrateScreen extends ConsumerStatefulWidget {
  const FirestoreDBMigrateScreen({super.key});

  @override
  ConsumerState<FirestoreDBMigrateScreen> createState() =>
      _FirestoreDBMigrateScreenState();
}

class _FirestoreDBMigrateScreenState
    extends ConsumerState<FirestoreDBMigrateScreen> {
  bool _isLoading = false;
  String? _statusText;

  Future<void> _migratePensionHoldingProductsToMasterSchema() async {
    final firestore = FirebaseFirestore.instance;

    try {
      setState(() {
        _isLoading = true;
        _statusText = '마이그레이션 진행 중...';
      });

      // 1. 기존 pension_holding_products 컬렉션의 모든 문서 가져오기
      final snapshot =
          await firestore.collection(pensionHoldingProductDBName).get();

      WriteBatch batch = firestore.batch();
      int count = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // 기존 is_terminated 값을 가져와서 반대로 뒤집어 isActive 결정 (기본값 true)
        bool isTerminated = data['is_terminated'] ?? false;
        bool isActive = !isTerminated;

        // 기존 purchase_date 가져오기
        String? purchaseDate =
            data['purchase_date'] ?? data['initial_purchase_date'];

        // 새로운 마스터 모델 구조에 맞는 데이터 맵 구성
        // (principal, total_payout 등 누적 데이터는 월말 잔액 모델로 이관되었으므로 마스터에서는 제외)
        final Map<String, dynamic> updatedData = {
          'account_id': data['account_id'],
          'product_id': data['product_id'],
          'is_active': isActive,
          'initial_purchase_date': purchaseDate,
        };

        // 기존 문서 업데이트 (불필요한 필드 정리를 위해 set with merge 대신 update 또는 set 사용 가능)
        // 기존 문서의 필드를 완전히 교체하려면 set을 사용할 수 있습니다.
        batch.set(doc.reference, updatedData);
        count++;

        // 파이어베이스 Batch 제한(500개) 대응
        if (count % 400 == 0) {
          await batch.commit();
          batch = firestore.batch();
        }
      }

      if (count > 0) {
        await batch.commit();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText =
              '연금 마스터(holding_products) 구조 개편 마이그레이션 완료! 총 $count개 문서 변환됨';
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

  Future<void> _migratePensionPurchaseDates(WidgetRef ref) async {
    final firestore = FirebaseFirestore.instance;

    // 💡 필드 값이 String이든 DocumentReference이든 상관없이 순수 ID만 추출하는 헬퍼 함수
    String extractId(dynamic value) {
      if (value == null) return '';
      try {
        // DocumentReference인 경우 .id를 안전하게 추출
        if (value.runtimeType.toString().contains('DocumentReference')) {
          return (value as dynamic).id.toString().trim();
        }
      } catch (_) {}

      final str = value.toString().trim();
      // 만약 문자열 내부에 파이어베이스 경로('/')가 포함되어 있다면 마지막 조각(ID)만 추출
      if (str.contains('/')) {
        final parts = str.split('/');
        return parts.isNotEmpty ? parts.last.trim() : str;
      }
      return str;
    }

    try {
      // 1. 연금 마스터 데이터 읽기
      final productSnapshot =
          await firestore.collection('pension_holding_product').get();

      final Map<String, String> masterDateMap = {};
      for (var doc in productSnapshot.docs) {
        final data = doc.data();
        final accountId = extractId(data['account_id'] ?? data['accountId']);
        final productId = extractId(
          data['product_id'] ?? data['productId'] ?? data['stock_item_id'],
        );
        final initialDate =
            (data['initial_purchase_date'] ?? data['purchase_date'] ?? '')
                .toString()
                .trim();

        if (accountId.isNotEmpty &&
            productId.isNotEmpty &&
            initialDate.isNotEmpty) {
          masterDateMap['${accountId}_$productId'] = initialDate;
        }
      }

      print('🔍 [방어 진단] 마스터 매핑 맵 생성 완료: ${masterDateMap.length}개');

      // 2. 월말 연금 데이터 읽고 정밀 대조
      final balanceSnapshot =
          await firestore.collection('monthly_pension_balance').get();

      WriteBatch batch = firestore.batch();
      int updateCount = 0;
      int failCount = 0;

      for (var doc in balanceSnapshot.docs) {
        final data = doc.data();
        final accountId = extractId(data['account_id'] ?? data['accountId']);
        final productId = extractId(data['product_id'] ?? data['productId']);

        final lookupKey = '${accountId}_$productId';
        final matchedDate = masterDateMap[lookupKey];

        if (matchedDate != null && matchedDate.isNotEmpty) {
          batch.update(doc.reference, {'purchase_date': matchedDate});
          updateCount++;

          if (updateCount % 400 == 0) {
            await batch.commit();
            batch = firestore.batch();
          }
        } else {
          failCount++;
          print(
            '❌ 최종 매칭 실패: lookupKey=[$lookupKey] (accountId: $accountId, productId: $productId)',
          );
        }
      }

      if (updateCount > 0) {
        await batch.commit();
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = '월말연금 매수일 업데이트! 총 $updateCount 문서 변환됨';
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

  /// 💡 기존 monthly_bank_balance DB의 모든 문서에 account_name 필드를 마이그레이션하는 함수
  Future<void> _migrateMonthlyBankBalanceAccountNames(WidgetRef ref) async {
    final firestore = ref.read(firestoreProvider);

    try {
      print('🚀 [마이그레이션 시작] 월말 은행 잔액 계좌명 마이그레이션을 시작합니다...');

      // 1. 필요한 계좌 마스터 데이터 및 연동 이름 정보 로드
      final accounts = await ref.read(accountNotifierProvider.future);
      final accountNames = await ref.read(accountNameNotifierProvider.future);

      final accountMap = {for (var a in accounts) a.id!: a};
      final accountNameMap = {for (var an in accountNames) an.id: an};

      // 2. monthly_bank_balance 컬렉션의 모든 문서 조회
      final snapshot =
          await firestore.collection(monthlyBankBalanceDBName).get();
      print('📦 총 ${snapshot.docs.length}개의 월말 은행 잔액 문서를 확인했습니다.');

      WriteBatch batch = firestore.batch();
      int updatedCount = 0;
      int skippedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final accountId = data['account_id'] as String?;
        final existingAccountName = data['account_name'] as String?;

        // 이미 account_name이 존재하는 문서라면 패스
        if (existingAccountName != null && existingAccountName.isNotEmpty) {
          skippedCount++;
          continue;
        }

        if (accountId == null || accountId.isEmpty) {
          skippedCount++;
          continue;
        }

        // 3. account_id로 계좌명 및 기관명 추출
        final matchedAccount = accountMap[accountId];
        final matchedNameObj =
            matchedAccount != null
                ? accountNameMap[matchedAccount.accountNameId]
                : null;

        if (matchedNameObj != null) {
          final institution = matchedAccount?.financialInstitution ?? '';
          final fullAccountName =
              '[$institution] ${matchedNameObj.accountName}';

          // 4. batch에 update 작업 추가
          batch.update(doc.reference, {'account_name': fullAccountName});
          updatedCount++;

          // Firestore Batch 처리 제한(500건) 고려하여 400건마다 커밋
          if (updatedCount % 400 == 0) {
            await batch.commit();
            batch = firestore.batch();
            print('🔄 400건 커밋 완료...');
          }
        } else {
          skippedCount++;
        }
      }

      // 남은 배치 커밋
      if (updatedCount % 400 != 0) {
        await batch.commit();
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = '월말은행 account_name 마이그레이션 완료! 총 $updatedCount 문서 변환됨';
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

  /// 💡 기존 monthly_pension_balance DB의 모든 문서에 account_name, product_name 필드를 마이그레이션하는 함수
  Future<void> migrateMonthlyPensionBalanceNames(WidgetRef ref) async {
    final firestore = ref.read(firestoreProvider);

    try {
      print('🚀 [마이그레이션 시작] 월말 연금 데이터(계좌명/상품명) 마이그레이션을 시작합니다...');

      final accounts = await ref.read(accountNotifierProvider.future);
      final accountNames = await ref.read(accountNameNotifierProvider.future);
      final products = await ref.read(pensionProductNotifierProvider.future);

      final accountMap = {for (var a in accounts) a.id!: a};
      final accountNameMap = {for (var an in accountNames) an.id: an};
      final productMap = {for (var p in products) p.id!: p};

      final snapshot =
          await firestore.collection(monthlyPensionBalanceDBName).get();
      print('📦 총 ${snapshot.docs.length}개의 월말 연금 문서를 확인했습니다.');

      WriteBatch batch = firestore.batch();
      int updatedCount = 0;
      int skippedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final accountId = data['account_id'] as String?;
        final productId = data['product_id'] as String?;

        final existingAccountName = data['account_name'] as String?;
        final existingProductName = data['product_name'] as String?;

        // 둘 다 이미 채워져 있다면 스킵
        if (existingAccountName != null &&
            existingAccountName.isNotEmpty &&
            existingProductName != null &&
            existingProductName.isNotEmpty) {
          skippedCount++;
          continue;
        }

        final Map<String, dynamic> updateData = {};

        // 계좌명 조합
        if (accountId != null && accountId.isNotEmpty) {
          final matchedAccount = accountMap[accountId];
          final matchedNameObj =
              matchedAccount != null
                  ? accountNameMap[matchedAccount.accountNameId]
                  : null;

          if (matchedNameObj != null) {
            final inst = matchedAccount?.financialInstitution ?? '';
            updateData['account_name'] =
                '[$inst] ${matchedNameObj.accountName}';
          }
        }

        // 상품명 조합
        if (productId != null && productId.isNotEmpty) {
          if (productId == '_CASH_ASSET_PRODUCT_ID_') {
            updateData['product_name'] = '💵 계좌 공통 현금성 자산 (예수금)';
          } else {
            final matchedProd = productMap[productId];
            if (matchedProd != null) {
              updateData['product_name'] = matchedProd.productName;
            }
          }
        }

        if (updateData.isNotEmpty) {
          batch.update(doc.reference, updateData);
          updatedCount++;

          if (updatedCount % 400 == 0) {
            await batch.commit();
            batch = firestore.batch();
            print('🔄 400건 커밋 완료...');
          }
        } else {
          skippedCount++;
        }
      }

      if (updatedCount % 400 != 0) {
        await batch.commit();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText =
              '월말연금 account_name, product_name 마이그레이션 완료! 총 $updatedCount 문서 변환됨';
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

  /// 💡 주식 및 연금 보유 항목의 계좌명/종목명/상품명 마이그레이션 함수
  Future<void> migrateHoldingNames(WidgetRef ref) async {
    final firestore = ref.read(firestoreProvider);

    try {
      print('🚀 [마이그레이션 시작] 보유 항목 명칭 데이터 동기화를 시작합니다...');

      final accounts = await ref.read(accountNotifierProvider.future);
      final accountNames = await ref.read(accountNameNotifierProvider.future);
      final stockItems = await ref.read(stockItemNotifierProvider.future);
      final pensionProducts = await ref.read(
        pensionProductNotifierProvider.future,
      );

      final accountMap = {for (var a in accounts) a.id!: a};
      final accountNameMap = {for (var an in accountNames) an.id: an};
      final stockMap = {for (var s in stockItems) s.id!: s};
      final pensionProductMap = {for (var p in pensionProducts) p.id!: p};

      // 1. Stock Holding Items 마이그레이션
      final stockSnapshot =
          await firestore.collection(stockHoldingItemDBName).get();
      print('📦 총 ${stockSnapshot.docs.length}개의 주식 보유종목 문서를 확인했습니다.');

      WriteBatch stockBatch = firestore.batch();
      int stockUpdated = 0;

      for (final doc in stockSnapshot.docs) {
        final data = doc.data();
        final accountId = data['account_id'] as String?;
        final stockItemId = data['stock_item_id'] as String?;

        final Map<String, dynamic> updateData = {};

        if (accountId != null && accountId.isNotEmpty) {
          final matchedAcc = accountMap[accountId];
          final matchedNameObj =
              matchedAcc != null
                  ? accountNameMap[matchedAcc.accountNameId]
                  : null;
          if (matchedNameObj != null) {
            final inst = matchedAcc?.financialInstitution ?? '';
            updateData['account_name'] =
                '[$inst] ${matchedNameObj.accountName}';
          }
        }

        if (stockItemId != null && stockItemId.isNotEmpty) {
          final matchedStock = stockMap[stockItemId];
          if (matchedStock != null) {
            updateData['stock_item_name'] =
                '${matchedStock.itemName} (${matchedStock.stockCode})';
          }
        }

        if (updateData.isNotEmpty) {
          stockBatch.update(doc.reference, updateData);
          stockUpdated++;
          if (stockUpdated % 400 == 0) {
            await stockBatch.commit();
            stockBatch = firestore.batch();
          }
        }
      }
      if (stockUpdated % 400 != 0) {
        await stockBatch.commit();
      }

      // 2. Pension Holding Products 마이그레이션
      final pensionSnapshot =
          await firestore.collection(pensionHoldingProductDBName).get();
      print('📦 총 ${pensionSnapshot.docs.length}개의 연금 보유상품 문서를 확인했습니다.');

      WriteBatch pensionBatch = firestore.batch();
      int pensionUpdated = 0;

      for (final doc in pensionSnapshot.docs) {
        final data = doc.data();
        final accountId = data['account_id'] as String?;
        final productId = data['product_id'] as String?;

        final Map<String, dynamic> updateData = {};

        if (accountId != null && accountId.isNotEmpty) {
          final matchedAcc = accountMap[accountId];
          final matchedNameObj =
              matchedAcc != null
                  ? accountNameMap[matchedAcc.accountNameId]
                  : null;
          if (matchedNameObj != null) {
            final inst = matchedAcc?.financialInstitution ?? '';
            updateData['account_name'] =
                '[$inst] ${matchedNameObj.accountName}';
          }
        }

        if (productId != null && productId.isNotEmpty) {
          if (productId == '_CASH_ASSET_PRODUCT_ID_') {
            updateData['product_name'] = '💵 계좌 공통 현금성 자산 (예수금)';
          } else {
            final matchedProd = pensionProductMap[productId];
            if (matchedProd != null) {
              updateData['product_name'] = matchedProd.productName;
            }
          }
        }

        if (updateData.isNotEmpty) {
          pensionBatch.update(doc.reference, updateData);
          pensionUpdated++;
          if (pensionUpdated % 400 == 0) {
            await pensionBatch.commit();
            pensionBatch = firestore.batch();
          }
        }
      }
      if (pensionUpdated % 400 != 0) {
        await pensionBatch.commit();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText =
              '주식 계좌명/종목명 총 $pensionUpdated 문서 변환됨. 연금 보유 항목의 계좌명/상품명 총 $stockUpdated건 마이그레이션 완료';
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
      appBar: AppBar(title: const Text('Firestrore DB 마이그레이션')),
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
                onPressed:
                    _isLoading
                        ? null
                        : _migratePensionHoldingProductsToMasterSchema,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.upload_file),
                label: Text(_isLoading ? '처리 중...' : '연금 보유상품 구조 개편'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed:
                    _isLoading ? null : () => _migratePensionPurchaseDates(ref),
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.upload_file),
                label: Text(_isLoading ? '처리 중...' : '연금 매수일 마이그레이션'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed:
                    _isLoading
                        ? null
                        : () => _migrateMonthlyBankBalanceAccountNames(ref),
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.upload_file),
                label: Text(_isLoading ? '처리 중...' : '월말 은행(계좌명) db 마이그레이션'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed:
                    _isLoading
                        ? null
                        : () => migrateMonthlyPensionBalanceNames(ref),
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.upload_file),
                label: Text(
                  _isLoading ? '처리 중...' : '월말 연금(계좌,상품명 추가) db 마이그레이션',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => migrateHoldingNames(ref),
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.upload_file),
                label: Text(
                  _isLoading ? '처리 중...' : '보유상품, 보유종목 계좌명, 상품명, 종목명 db 마이그레이션',
                ),
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
