import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/account/account.dart';
import '../../models/account/account_name.dart';
import '../../models/monthly_data/monthly_bank_balance.dart';
import '../account/account_provider.dart';
import '../account/account_name_provider.dart';

part 'monthly_bank_balance_provider.g.dart';

class MonthlyBankBalanceWithAccount {
  final MonthlyBankBalance balanceItem;
  final Account? account;
  final AccountName? accountName;

  MonthlyBankBalanceWithAccount({
    required this.balanceItem,
    this.account,
    this.accountName,
  });

  String get accountNameDisplay => accountName?.accountName ?? '알 수 없는 계좌';
  String get financialInstitution => account?.financialInstitution ?? '';
}

@riverpod
Future<List<MonthlyBankBalanceWithAccount>> allMonthlyBankBalances(
  AllMonthlyBankBalancesRef ref,
) async {
  final firestore = ref.watch(firestoreProvider);
  final accounts = await ref.watch(accountNotifierProvider.future);
  final accountNames = await ref.watch(accountNameNotifierProvider.future);

  final snapshot = await firestore.collection(monthlyBankBalanceDBName).get();

  final balances =
      snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MonthlyBankBalance.fromJson(data);
      }).toList();

  balances.sort((a, b) => b.yearMonth.compareTo(a.yearMonth));

  return balances.map((b) {
    final matchedAccount = accounts.firstWhereOrNull(
      (a) => a.id == b.accountId,
    );
    final matchedAccountName = accountNames.firstWhereOrNull(
      (an) => an.id == matchedAccount?.accountNameId,
    );

    return MonthlyBankBalanceWithAccount(
      balanceItem: b,
      account: matchedAccount,
      accountName: matchedAccountName,
    );
  }).toList();
}

@Riverpod(keepAlive: true)
class MonthlyBankBalanceNotifier extends _$MonthlyBankBalanceNotifier {
  @override
  Future<List<MonthlyBankBalance>> build(String yearMonth) async {
    return fetchBalances(yearMonth);
  }

  Future<List<MonthlyBankBalance>> fetchBalances(String yearMonth) async {
    final firestore = ref.read(firestoreProvider);
    final snapshot =
        await firestore
            .collection(monthlyBankBalanceDBName)
            .where('year_month', isEqualTo: yearMonth)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MonthlyBankBalance.fromJson(data);
    }).toList();
  }

  Future<void> saveBalance(MonthlyBankBalance balance) async {
    final firestore = ref.read(firestoreProvider);
    // 💡 1. 계좌명과 계좌이름 정보를 가져와서 account_name 문자열 조합
    String? resolvedAccountName = balance.accountName;
    if (resolvedAccountName == null || resolvedAccountName.isEmpty) {
      try {
        final accounts = await ref.read(accountNotifierProvider.future);
        final accountNames = await ref.read(accountNameNotifierProvider.future);

        final matchedAccount = accounts.firstWhereOrNull((a) => a.id == balance.accountId);
        final matchedNameObj = accountNames.firstWhereOrNull((an) => an.id == matchedAccount?.accountNameId);

        if (matchedNameObj != null) {
          final institution = matchedAccount?.financialInstitution ?? '';
          resolvedAccountName = '[$institution] ${matchedNameObj.accountName}';
        }
      } catch (_) {
        // 실패 시 기존 값 유지
      }
    }

    // 💡 2. account_name이 포함된 최신 모델 생성
    final targetBalance = balance.copyWith(accountName: resolvedAccountName);

    // 💡 3. 기준년월_계정ID 형식의 문서 ID 생성
    final docId = '${targetBalance.yearMonth}_${targetBalance.accountId}';
    final data = targetBalance.toJson()..remove('id');

    // 💡 4. .add() 대신 .doc(docId).set()을 사용하여 문서명 고정
    await firestore
        .collection(monthlyBankBalanceDBName)
        .doc(docId)
        .set(data, SetOptions(merge: true));
    
    ref.invalidateSelf();
    ref.invalidate(allMonthlyBankBalancesProvider);
  }

  Future<void> deleteBalance(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(monthlyBankBalanceDBName).doc(id).delete();
    ref.invalidateSelf();
    ref.invalidate(allMonthlyBankBalancesProvider);
  }
}
