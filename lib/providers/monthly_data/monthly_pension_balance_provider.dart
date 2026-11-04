import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/account/account.dart';
import '../../models/account/account_name.dart';
import '../../models/monthly_data/monthly_pension_balance.dart';
import '../../models/pension/pension_holding_product.dart';
import '../../models/pension/pension_product.dart';
import '../account/account_provider.dart';
import '../account/account_name_provider.dart';
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
    
    final snapshot = await firestore
        .collection(monthlyPensionBalanceDBName)
        .where('year_month', isEqualTo: yearMonth)
        .get();

    final balances = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MonthlyPensionBalance.fromJson(data);
    }).toList();

    List<PensionHoldingProduct> holdingProducts = [];
    try {
      holdingProducts = await ref.watch(pensionHoldingProductNotifierProvider.future);
    } catch (_) {}

    final purchaseDateMap = {
      for (var hp in holdingProducts)
        '${hp.accountId}_${hp.productId}': hp.initialPurchaseDate
    };

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

  // 계좌명 및 상품명 텍스트 자동 조회 헬퍼
  Future<MonthlyPensionBalance> _enrichBalanceNames(MonthlyPensionBalance balance) async {
    String? resolvedAccountName = balance.accountName;
    String? resolvedProductName = balance.productName;

    try {
      final accounts = await ref.read(accountNotifierProvider.future);
      final accountNames = await ref.read(accountNameNotifierProvider.future);
      final products = await ref.read(pensionProductNotifierProvider.future);

      if (resolvedAccountName == null || resolvedAccountName.isEmpty) {
        final matchedAcc = accounts.firstWhereOrNull((a) => a.id == balance.accountId);
        final matchedNameObj = accountNames.firstWhereOrNull((an) => an.id == matchedAcc?.accountNameId);
        if (matchedNameObj != null) {
          final inst = matchedAcc?.financialInstitution ?? '';
          resolvedAccountName = '[$inst] ${matchedNameObj.accountName}';
        }
      }

      if (resolvedProductName == null || resolvedProductName.isEmpty) {
        if (balance.productId == '_CASH_ASSET_PRODUCT_ID_') {
          resolvedProductName = '💵 계좌 공통 현금성 자산 (예수금)';
        } else {
          final matchedProd = products.firstWhereOrNull((p) => p.id == balance.productId);
          if (matchedProd != null) {
            resolvedProductName = matchedProd.productName;
          }
        }
      }
    } catch (_) {}

    return balance.copyWith(
      accountName: resolvedAccountName,
      productName: resolvedProductName,
    );
  }

  Future<void> saveBalance(MonthlyPensionBalance balance) async {
    final firestore = ref.read(firestoreProvider);
    final targetItem = await _enrichBalanceNames(balance);
    final docId = '${targetItem.yearMonth}_${targetItem.accountId}_${targetItem.productId}';
    final data = targetItem.toJson()..remove('id');

    await firestore
        .collection(monthlyPensionBalanceDBName)
        .doc(docId)
        .set(data, SetOptions(merge: true));

    ref.invalidateSelf();
  }

  Future<void> deleteBalance(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(monthlyPensionBalanceDBName).doc(id).delete();
    ref.invalidateSelf();
  }

  Future<void> saveBatchBalances(List<MonthlyPensionBalance> items) async {
    final firestore = ref.read(firestoreProvider);
    final batch = firestore.batch();
    final collectionRef = firestore.collection(monthlyPensionBalanceDBName);

    for (var item in items) {
      final targetItem = await _enrichBalanceNames(item);
      final docId = '${targetItem.yearMonth}_${targetItem.accountId}_${targetItem.productId}';
      final docRef = collectionRef.doc(docId);

      final data = targetItem.toJson()..remove('id');
      batch.set(docRef, data, SetOptions(merge: true));
    }

    await batch.commit();
    ref.invalidateSelf();
  }  
}

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