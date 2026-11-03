import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/account/account.dart';
import '../../models/account/account_name.dart';
import '../../models/monthly_data/monthly_stock_account_balance.dart';
import '../account/account_name_provider.dart';
import '../account/account_provider.dart';

part 'monthly_stock_account_balance_provider.g.dart';

class MonthlyStockAccountBalanceWithDetail {
  final MonthlyStockAccountBalance balanceItem;
  final Account? account;
  final AccountName? accountName;

  MonthlyStockAccountBalanceWithDetail({
    required this.balanceItem,
    this.account,
    this.accountName,
  });

  String get accountNameDisplay => accountName?.accountName ?? '알 수 없는 계좌';
  String get financialInstitution => account?.financialInstitution ?? '';
}

@riverpod
class AllMonthlyStockAccountBalances extends _$AllMonthlyStockAccountBalances {
  @override
  Future<List<MonthlyStockAccountBalanceWithDetail>> build() async {
    return fetchAllBalances();
  }

  Future<List<MonthlyStockAccountBalanceWithDetail>> fetchAllBalances() async {
    final firestore = ref.watch(firestoreProvider);

    List<Account> accounts = [];
    List<AccountName> accountNames = [];

    try {
      accounts = await ref.watch(accountNotifierProvider.future);
    } catch (_) {}

    try {
      accountNames = await ref.watch(accountNameNotifierProvider.future);
    } catch (_) {}

    final snapshot =
        await firestore.collection(monthlyStockAccountBalanceDBName).get();

    final balances = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MonthlyStockAccountBalance.fromJson(data);
    }).toList();

    final accountMap = {for (var a in accounts) a.id!: a};
    final accountNameMap = {for (var an in accountNames) an.id: an};

    balances.sort((a, b) {
      int monthCompare = b.yearMonth.compareTo(a.yearMonth);
      if (monthCompare != 0) return monthCompare;

      final accA = accountMap[a.accountId];
      final accB = accountMap[b.accountId];

      final nameA =
          '${accA?.financialInstitution ?? ''}_${accountNameMap[accA?.accountNameId]?.accountName ?? ''}';
      final nameB =
          '${accB?.financialInstitution ?? ''}_${accountNameMap[accB?.accountNameId]?.accountName ?? ''}';

      return nameA.compareTo(nameB);
    });

    return balances.map((b) {
      final matchedAccount = accountMap[b.accountId];
      final matchedAccountName =
          matchedAccount != null
              ? accountNameMap[matchedAccount.accountNameId]
              : null;

      return MonthlyStockAccountBalanceWithDetail(
        balanceItem: b,
        account: matchedAccount,
        accountName: matchedAccountName,
      );
    }).toList();
  }
}

@Riverpod(keepAlive: true)
class MonthlyStockAccountBalanceNotifier
    extends _$MonthlyStockAccountBalanceNotifier {
  @override
  Future<List<MonthlyStockAccountBalance>> build(String yearMonth) async {
    return fetchBalances(yearMonth);
  }

  Future<List<MonthlyStockAccountBalance>> fetchBalances(
    String yearMonth,
  ) async {
    final firestore = ref.read(firestoreProvider);

    final snapshot =
        await firestore
            .collection(monthlyStockAccountBalanceDBName)
            .where('year_month', isEqualTo: yearMonth)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MonthlyStockAccountBalance.fromJson(data);
    }).toList();
  }

  Future<MonthlyStockAccountBalance> _enrichBalanceNames(
    MonthlyStockAccountBalance balance,
  ) async {
    String? resolvedAccountName = balance.accountName;

    try {
      final accounts = await ref.read(accountNotifierProvider.future);
      final accountNames = await ref.read(accountNameNotifierProvider.future);

      if (resolvedAccountName == null || resolvedAccountName.isEmpty) {
        final matchedAcc = accounts.firstWhereOrNull(
          (a) => a.id == balance.accountId,
        );
        final matchedNameObj = accountNames.firstWhereOrNull(
          (an) => an.id == matchedAcc?.accountNameId,
        );
        if (matchedNameObj != null) {
          final inst = matchedAcc?.financialInstitution ?? '';
          resolvedAccountName = '[$inst]${matchedNameObj.accountName}';
        }
      }
    } catch (_) {}

    return balance.copyWith(accountName: resolvedAccountName);
  }

  Future<void> saveBalance(MonthlyStockAccountBalance balance) async {
    final firestore = ref.read(firestoreProvider);
    final targetItem = await _enrichBalanceNames(balance);
    final docId = '${targetItem.yearMonth}_${targetItem.accountId}';
    final data = targetItem.toJson()..remove('id');

    await firestore
        .collection(monthlyStockAccountBalanceDBName)
        .doc(docId)
        .set(data, SetOptions(merge: true));

    ref.invalidateSelf();
    ref.invalidate(allMonthlyStockAccountBalancesProvider);
  }

  Future<void> deleteBalance(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore
        .collection(monthlyStockAccountBalanceDBName)
        .doc(id)
        .delete();

    ref.invalidateSelf();
    ref.invalidate(allMonthlyStockAccountBalancesProvider);
  }
}