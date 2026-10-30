import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/account/account.dart';
import '../../models/account/account_name.dart';
import '../../models/monthly_data/monthly_pension_balance.dart';
import '../../models/pension/pension_holding_product.dart';
import '../../models/pension/pension_product.dart';
import '../account/account_name_provider.dart';
import '../account/account_provider.dart';
import '../pension/pension_holding_product_provider.dart';
import '../pension/pension_product_provider.dart';

part 'monthly_pension_balance_provider.g.dart';

@Riverpod(keepAlive: true)
class MonthlyPensionBalanceNotifier extends _$MonthlyPensionBalanceNotifier {
  @override
  Future<List<MonthlyPensionBalance>> build(String yearMonth) async {
    return fetchBalances(yearMonth);
  }

  Future<List<MonthlyPensionBalance>> fetchBalances(String yearMonth) async {
    final firestore = ref.read(firestoreProvider);
    
    // 1. 해당 월의 월말 연금 데이터 가져오기
    final snapshot = await firestore
        .collection(monthlyPensionBalanceDBName)
        .where('year_month', isEqualTo: yearMonth)
        .get();

    final balances = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MonthlyPensionBalance.fromJson(data);
    }).toList();

    // 2. 계좌별 보유 상품(최초 매수일 정보 포함) 목록 가져오기
    List<PensionHoldingProduct> holdingProducts = [];
    try {
      holdingProducts = await ref.watch(pensionHoldingProductNotifierProvider.future);
    } catch (_) {}

    // 3. '계좌ID_상품ID'를 키로 하고 initialPurchaseDate를 값으로 하는 맵 생성
    final purchaseDateMap = {
      for (var hp in holdingProducts)
        '${hp.accountId}_${hp.productId}': hp.initialPurchaseDate
    };

    // 4. 월말 데이터에 매수일이 비어있다면 보유 상품 마스터의 최초 매수일을 찾아 채워넣기
    return balances.map((item) {
      if (item.purchaseDate == null || item.purchaseDate!.isEmpty) {
        final matchedDate = purchaseDateMap['${item.accountId}_${item.productId}'];
        if (matchedDate != null && matchedDate.isNotEmpty) {
          return item.copyWith(purchaseDate: matchedDate);
        }
      }
      return item;
    }).toList();
  }

  Future<void> saveBalance(MonthlyPensionBalance balance) async {
    final firestore = ref.read(firestoreProvider);
    final data = balance.toJson()..remove('id');

    if (balance.id == null) {
      await firestore.collection(monthlyPensionBalanceDBName).add(data);
    } else {
      await firestore
          .collection(monthlyPensionBalanceDBName)
          .doc(balance.id)
          .update(data);
    }
    ref.invalidateSelf();
  }

  Future<void> deleteBalance(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(monthlyPensionBalanceDBName).doc(id).delete();
    ref.invalidateSelf();
  }

  // 💡 여러 개의 월말 연금 데이터를 한 번에 저장하는 배치 메서드 (기준월_계좌ID_상품ID 문서 ID 고정)
  Future<void> saveBatchBalances(List<MonthlyPensionBalance> items) async {
    final firestore = ref.read(firestoreProvider);
    final batch = firestore.batch();
    final collectionRef = firestore.collection(monthlyPensionBalanceDBName);

    for (var item in items) {
      final docId = '${item.yearMonth}_${item.accountId}_${item.productId}';
      final docRef = collectionRef.doc(docId);

      final data = item.toJson()..remove('id');
      batch.set(docRef, data, SetOptions(merge: true));
    }

    await batch.commit();
    ref.invalidateSelf();
  }  
}

// 💡 [추가] 모든 기준월의 연금 월말 데이터를 상세 정보(계좌, 상품 등)와 함께 불러오는 프로바이더
@Riverpod(keepAlive: true)
class AllMonthlyPensionBalances extends _$AllMonthlyPensionBalances {
  @override
  Future<List<MonthlyPensionBalanceWithDetail>> build() async {
    return fetchAllBalances();
  }

  Future<List<MonthlyPensionBalanceWithDetail>> fetchAllBalances() async {
    final firestore = ref.watch(firestoreProvider);
    
    List<Account> accounts = [];
    List<AccountName> accountNames = [];
    List<PensionProduct> products = [];

    try {
      accounts = await ref.watch(accountNotifierProvider.future);
    } catch (_) {}

    try {
      accountNames = await ref.watch(accountNameNotifierProvider.future);
    } catch (_) {}

    try {
      products = await ref.watch(pensionProductNotifierProvider.future);
    } catch (_) {}

    final snapshot = await firestore.collection(monthlyPensionBalanceDBName).get();

    final balances = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MonthlyPensionBalance.fromJson(data);
    }).toList();

    final accountMap = {for (var a in accounts) a.id!: a};
    final accountNameMap = {for (var an in accountNames) an.id: an};
    
    final productMap = {
      for (var p in products) 
        if (p.id != null) p.id!.trim(): p
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
      
      final cleanProductId = b.productId.trim();
      final matchedProduct = productMap[cleanProductId];

      return MonthlyPensionBalanceWithDetail(
        balanceItem: b,
        account: matchedAccount,
        accountName: matchedAccountName,
        product: matchedProduct,
      );
    }).toList();
  }
}

class MonthlyPensionBalanceWithDetail {
  final MonthlyPensionBalance balanceItem;
  final Account? account;
  final AccountName? accountName;
  final PensionProduct? product;

  MonthlyPensionBalanceWithDetail({
    required this.balanceItem,
    this.account,
    this.accountName,
    this.product,
  });
}