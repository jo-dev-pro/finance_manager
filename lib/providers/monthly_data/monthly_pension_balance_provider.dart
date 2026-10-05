import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/firestore_provider.dart';
import '../../models/monthly_data/monthly_pension_balance.dart';

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
        .get();

    final list = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MonthlyPensionBalance.fromJson(data);
    }).toList();

    // 금융기관 -> 계좌 ID 순 메모리 정렬
    list.sort((a, b) {
      int comp = (a.financialInstitution ?? '').compareTo(
        b.financialInstitution ?? '',
      );
      if (comp != 0) return comp;
      return a.accountId.compareTo(b.accountId);
    });

    return list;
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