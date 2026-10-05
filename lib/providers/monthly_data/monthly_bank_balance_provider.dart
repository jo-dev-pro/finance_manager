import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/firestore_provider.dart';
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

  final snapshot = await firestore.collection('monthly_bank_balance').get();

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

@riverpod
class MonthlyBankBalanceNotifier extends _$MonthlyBankBalanceNotifier {
  @override
  Future<List<MonthlyBankBalance>> build(String yearMonth) async {
    return fetchBalances(yearMonth);
  }

  Future<List<MonthlyBankBalance>> fetchBalances(String yearMonth) async {
    final firestore = ref.read(firestoreProvider);
    final snapshot =
        await firestore
            .collection('monthly_bank_balance')
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
    final data = balance.toJson()..remove('id');

    if (balance.id == null) {
      await firestore.collection('monthly_bank_balance').add(data);
    } else {
      await firestore
          .collection('monthly_bank_balance')
          .doc(balance.id)
          .update(data);
    }
    ref.invalidateSelf();
    ref.invalidate(allMonthlyBankBalancesProvider);
  }

  Future<void> deleteBalance(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection('monthly_bank_balance').doc(id).delete();
    ref.invalidateSelf();
    ref.invalidate(allMonthlyBankBalancesProvider);
  }
}
