import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/monthly_data/monthly_stock_balance.dart';
import '../../models/stock/stock_holding_item.dart';
import '../stock/stock_holding_item_provider.dart';

part 'monthly_stock_balance_provider.g.dart';

@Riverpod(keepAlive: true)
class MonthlyStockBalanceNotifier extends _$MonthlyStockBalanceNotifier {
  @override
  Future<List<MonthlyStockBalance>> build(String yearMonth) async {
    return fetchBalances(yearMonth);
  }

  Future<List<MonthlyStockBalance>> fetchBalances(String yearMonth) async {
    final firestore = ref.read(firestoreProvider);
    
    // 1. 해당 월의 월말 주식 데이터 가져오기
    final snapshot = await firestore
        .collection(monthlyStockBalanceDBName)
        .where('year_month', isEqualTo: yearMonth)
        .get();

    final balances = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MonthlyStockBalance.fromJson(data);
    }).toList();

    // 2. 계좌별 보유 종목(매수일 정보 포함) 목록 가져오기
    List<StockHoldingItem> holdingItems = [];
    try {
      holdingItems = await ref.watch(stockHoldingItemNotifierProvider.future);
    } catch (_) {}

    // 3. '계좌ID_종목ID'를 키로 하고 purchaseDate를 값으로 하는 맵 생성
    final purchaseDateMap = {
      for (var hi in holdingItems)
        '${hi.accountId}_${hi.stockItemId}': hi.purchaseDate
    };

    // 4. 월말 데이터에 매수일이 비어있다면 보유 종목의 매수일을 찾아 채워넣기
    return balances.map((item) {
      if (item.purchaseDate == null || item.purchaseDate!.isEmpty) {
        final matchedDate = purchaseDateMap['${item.accountId}_${item.stockItemId}'];
        if (matchedDate != null && matchedDate.isNotEmpty) {
          return item.copyWith(purchaseDate: matchedDate);
        }
      }
      return item;
    }).toList();
  }

  Future<void> saveBalance(MonthlyStockBalance balance) async {
    final firestore = ref.read(firestoreProvider);
    final data = balance.toJson()..remove('id');

    if (balance.id == null) {
      await firestore.collection(monthlyStockBalanceDBName).add(data);
    } else {
      await firestore
          .collection(monthlyStockBalanceDBName)
          .doc(balance.id)
          .update(data);
    }
    ref.invalidateSelf();
  }

  Future<void> deleteBalance(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(monthlyStockBalanceDBName).doc(id).delete();
    ref.invalidateSelf();
  }

  // 여러 월말 데이터를 한 번에 저장하는 Batch 메서드
  Future<void> saveBatchBalances(List<MonthlyStockBalance> items) async {
    final firestore = ref.read(firestoreProvider);
    final batch = firestore.batch();
    final collectionRef = firestore.collection(monthlyStockBalanceDBName);

    for (var item in items) {
      final docId = '${item.yearMonth}_${item.accountId}_${item.stockItemId}';
      final docRef = collectionRef.doc(docId);
      final data = item.toJson()..remove('id');
      batch.set(docRef, data, SetOptions(merge: true));
    }

    await batch.commit();
    ref.invalidateSelf();
  }
}