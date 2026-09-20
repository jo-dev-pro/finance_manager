import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/providers/firestore_provider.dart';
import '../models/monthly_bank_balance.dart';

part 'monthly_bank_balance_provider.g.dart';

@riverpod
class MonthlyBankBalanceNotifier extends _$MonthlyBankBalanceNotifier {
  @override
  Future<List<MonthlyBankBalance>> build(String yearMonth) async {
    return fetchBalances(yearMonth);
  }

  Future<List<MonthlyBankBalance>> fetchBalances(String yearMonth) async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore
        .collection('monthly_bank_balance')
        .where('year_month', isEqualTo: yearMonth)
        // .orderBy('financial_institution', descending: false)
        // .orderBy('account_name', descending: false)
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
  }

  Future<void> deleteBalance(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection('monthly_bank_balance').doc(id).delete();
    ref.invalidateSelf();
  }
}