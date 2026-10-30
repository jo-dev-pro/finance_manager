import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../../models/monthly_data/monthly_bank_balance.dart';
import '../../providers/dashboard/dashboard_provider.dart';
import '../../providers/monthly_data/monthly_bank_balance_provider.dart';

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
          await firestore.collection('pension_holding_products').get();

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

    try {
      setState(() {
        _isLoading = true;
        _statusText = '마이그레이션 진행 중...';
      });

      // 1. 연금 마스터(보유 상품) 목록 가져오기 (각 상품의 initialPurchaseDate가 들어있음)
      final productSnapshot =
          await firestore.collection('pension_holding_products').get();

      // '계좌ID_상품ID' 또는 '상품ID'를 키로 매수일 맵 생성
      // (구조에 따라 키 조합은 조정이 필요할 수 있습니다. 보통 accountId + productId 조합)
      final Map<String, String> masterDateMap = {};
      for (var doc in productSnapshot.docs) {
        final data = doc.data();
        final accountId = data['account_id'] ?? '';
        final productId =
            data['stock_item_id'] ?? data['product_id'] ?? ''; // 구조에 맞게 수정
        final purchaseDate = data['initial_purchase_date'];

        if (purchaseDate != null && purchaseDate.toString().isNotEmpty) {
          masterDateMap['${accountId}_$productId'] = purchaseDate;
          // 혹은 상품ID 단독으로 관리되는 경우를 대비해 productId만으로도 맵핑 가능
          masterDateMap[productId] = purchaseDate;
        }
      }

      // 2. 월말 연금 데이터 전체 가져오기
      final balanceSnapshot =
          await firestore.collection('monthly_pension_balance').get();

      WriteBatch batch = firestore.batch();
      int updateCount = 0;

      for (var doc in balanceSnapshot.docs) {
        final data = doc.data();
        final currentPurchaseDate = data['purchase_date'];

        // purchase_date가 비어있는 경우에만 마스터에서 찾아 채움
        if (currentPurchaseDate == null ||
            currentPurchaseDate.toString().isEmpty) {
          final accountId = data['account_id'] ?? '';
          final productId = data['product_id'] ?? '';

          // 매칭되는 최초 매수일 찾기 (계좌ID_상품ID 우선, 없으면 상품ID 단독 검색)
          final matchedDate =
              masterDateMap['${accountId}_$productId'] ??
              masterDateMap[productId];

          if (matchedDate != null) {
            batch.update(doc.reference, {'purchase_date': matchedDate});
            updateCount++;
          }
        }

        // Firestore Batch는 한 번에 최대 500개까지만 처리 가능하므로 분기 처리
        if (updateCount > 0 && updateCount % 400 == 0) {
          await batch.commit();
          batch = firestore.batch();
        }
      }

      if (updateCount > 0) {
        await batch.commit();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = '연금 월말 데이터 매수일 마이그레이션 완료! 총 $updateCount개 문서 업데이트됨';
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
                onPressed: _isLoading ? null : _migratePensionHoldingProductsToMasterSchema,
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
                onPressed: _isLoading ? null : () => _migratePensionPurchaseDates(ref),
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
