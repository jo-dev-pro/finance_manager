import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/account/account.dart';
import '../../models/account/account_name.dart';
import '../../models/monthly_data/monthly_pension_account_balance.dart';
import '../account/account_name_provider.dart';
import '../account/account_provider.dart';

part 'monthly_pension_account_balance_provider.g.dart';

class MonthlyPensionAccountBalanceWithDetail {
  final MonthlyPensionAccountBalance balanceItem;
  final Account? account;
  final AccountName? accountName;

  MonthlyPensionAccountBalanceWithDetail({
    required this.balanceItem,
    this.account,
    this.accountName,
  });

  String get accountNameDisplay => accountName?.accountName ?? '알 수 없는 계좌';
  String get financialInstitution => account?.financialInstitution ?? '';
}

@Riverpod(keepAlive: true)
class MonthlyPensionAccountBalanceNotifier
    extends _$MonthlyPensionAccountBalanceNotifier {
  @override
  Future<List<MonthlyPensionAccountBalance>> build(String yearMonth) async {
    return fetchBalances(yearMonth);
  }

  Future<List<MonthlyPensionAccountBalance>> fetchBalances(
    String yearMonth,
  ) async {
    final firestore = ref.read(firestoreProvider);

    final snapshot =
        await firestore
            .collection(monthlyPensionAccountBalanceDBName)
            .where('year_month', isEqualTo: yearMonth)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MonthlyPensionAccountBalance.fromJson(data);
    }).toList();
  }

  Future<MonthlyPensionAccountBalance> _enrichBalanceNames(
    MonthlyPensionAccountBalance balance,
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
          resolvedAccountName = '[$inst] ${matchedNameObj.accountName}';
        }
      }
    } catch (_) {}

    return balance.copyWith(accountName: resolvedAccountName);
  }

  Future<void> saveBalance(MonthlyPensionAccountBalance balance) async {
    final firestore = ref.read(firestoreProvider);
    final targetItem = await _enrichBalanceNames(balance);
    final docId = '${targetItem.yearMonth}_${targetItem.accountId}';
    final data = targetItem.toJson()..remove('id');

    await firestore
        .collection(monthlyPensionAccountBalanceDBName)
        .doc(docId)
        .set(data, SetOptions(merge: true));

    ref.invalidateSelf();
  }

  Future<void> deleteBalance(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore
        .collection(monthlyPensionAccountBalanceDBName)
        .doc(id)
        .delete();

    ref.invalidateSelf();
  }
}