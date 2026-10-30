import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/account/account.dart';
import '../../models/account/account_name.dart';
import '../../models/monthly_data/monthly_stock_balance.dart';
import '../../models/stock/stock_holding_item.dart';
import '../../models/stock/stock_item.dart';
import '../account/account_provider.dart';
import '../account/account_name_provider.dart';
import '../stock/stock_holding_item_provider.dart';
import '../stock/stock_item_provider.dart';

part 'monthly_stock_balance_provider.g.dart';

class MonthlyStockBalanceWithDetail {
  final MonthlyStockBalance balanceItem;
  final Account? account;
  final AccountName? accountName;
  final StockItem? stockItem;

  MonthlyStockBalanceWithDetail({
    required this.balanceItem,
    this.account,
    this.accountName,
    this.stockItem,
  });

  String get accountNameDisplay => accountName?.accountName ?? '알 수 없는 계좌';
  String get financialInstitution => account?.financialInstitution ?? '';
  String get stockName => stockItem?.itemName ?? '알 수 없는 종목';
}

// 💡 1. 모든 월의 주식 월말 데이터를 상세 계좌/종목 정보와 함께 불러오는 프로바이더 (연금의 AllMonthlyPensionBalances와 동일 구조)
@riverpod
class AllMonthlyStockBalances extends _$AllMonthlyStockBalances {
  @override
  Future<List<MonthlyStockBalanceWithDetail>> build() async {
    return fetchAllBalances();
  }

  Future<List<MonthlyStockBalanceWithDetail>> fetchAllBalances() async {
    final firestore = ref.watch(firestoreProvider);

    List<Account> accounts = [];
    List<AccountName> accountNames = [];
    List<StockItem> stockItems = [];

    try {
      accounts = await ref.watch(accountNotifierProvider.future);
    } catch (_) {}

    try {
      accountNames = await ref.watch(accountNameNotifierProvider.future);
    } catch (_) {}

    try {
      stockItems = await ref.watch(stockItemNotifierProvider.future);
    } catch (_) {}

    final snapshot = await firestore.collection(monthlyStockBalanceDBName).get();

    final balances = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MonthlyStockBalance.fromJson(data);
    }).toList();

    final accountMap = {for (var a in accounts) a.id!: a};
    final accountNameMap = {for (var an in accountNames) an.id: an};
    
    final stockMap = {
      for (var s in stockItems) 
        if (s.id != null) s.id!.trim(): s
    };

    // 정렬 로직 (기준월 최신순 -> 계좌명순)
    balances.sort((a, b) {
      int monthCompare = b.yearMonth.compareTo(a.yearMonth);
      if (monthCompare != 0) return monthCompare;

      final accA = accountMap[a.accountId];
      final accB = accountMap[b.accountId];
      
      final nameA = '${accA?.financialInstitution ?? ''}_${accountNameMap[accA?.accountNameId]?.accountName ?? ''}';
      final nameB = '${accB?.financialInstitution ?? ''}_${accountNameMap[accB?.accountNameId]?.accountName ?? ''}';

      return nameA.compareTo(nameB);
    });

    return balances.map((b) {
      final matchedAccount = accountMap[b.accountId];
      final matchedAccountName = matchedAccount != null ? accountNameMap[matchedAccount.accountNameId] : null;
      
      final cleanStockItemId = b.stockItemId.trim();
      final matchedStockItem = stockMap[cleanStockItemId];

      return MonthlyStockBalanceWithDetail(
        balanceItem: b,
        account: matchedAccount,
        accountName: matchedAccountName,
        stockItem: matchedStockItem,
      );
    }).toList();
  }
}

// 💡 2. 특정 연월별 주식 월말 잔액 관리 및 매수일 자동 연동 Notifier
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
        '${hi.accountId}_${hi.stockItemId}': hi.initialPurchaseDate
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
    ref.invalidate(allMonthlyStockBalancesProvider); // 전체 목록 프로바이더 갱신 추가
  }

  Future<void> deleteBalance(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(monthlyStockBalanceDBName).doc(id).delete();
    ref.invalidateSelf();
    ref.invalidate(allMonthlyStockBalancesProvider); // 전체 목록 프로바이더 갱신 추가
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
    ref.invalidate(allMonthlyStockBalancesProvider); // 전체 목록 프로바이더 갱신 추가
  }
}