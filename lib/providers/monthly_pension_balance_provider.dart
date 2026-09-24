import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/providers/firestore_provider.dart';
import '../models/monthly_pension_balance.dart';

part 'monthly_pension_balance_provider.g.dart';

@riverpod
class MonthlyPensionBalanceNotifier extends _$MonthlyPensionBalanceNotifier {
  @override
  Future<List<MonthlyPensionBalance>> build(String yearMonth) async {
    return fetchBalances(yearMonth);
  }

  Future<List<MonthlyPensionBalance>> fetchBalances(String yearMonth) async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore
        .collection('monthly_pension_balance')
        .where('year_month', isEqualTo: yearMonth)
        .orderBy('financial_institution', descending: false)
        .orderBy('account_id', descending: false) // 👈 account_id 기준 정렬
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MonthlyPensionBalance.fromJson(data);
    }).toList();
  }

  Future<void> saveBalance(MonthlyPensionBalance balance) async {
    final firestore = ref.read(firestoreProvider);
    final data = balance.toJson()..remove('id');

    if (balance.id == null) {
      await firestore.collection('monthly_pension_balance').add(data);
    } else {
      await firestore
          .collection('monthly_pension_balance')
          .doc(balance.id)
          .update(data);
    }
    ref.invalidateSelf();
  }

  Future<void> deleteBalance(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection('monthly_pension_balance').doc(id).delete();
    ref.invalidateSelf();
  }
}

// 🌐 특정 연월(yearMonth)과 계좌 ID(accountId)로 해당 월의 잔액 데이터를 필터링하는 프로바이더
@riverpod
Future<List<MonthlyPensionBalance>> monthlyPensionBalancesByAccount(
  MonthlyPensionBalancesByAccountRef ref, {
  required String yearMonth,
  required String accountId,
}) async {
  if (accountId.isEmpty) return [];

  final balances = await ref.watch(
    monthlyPensionBalanceNotifierProvider(yearMonth).future,
  );
  return balances.where((b) => b.accountId == accountId).toList();
}