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
        .orderBy('account_name', descending: false)
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