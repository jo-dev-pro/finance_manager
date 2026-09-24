import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/providers/firestore_provider.dart';
import '../models/pension_transaction.dart';

part 'pension_transaction_provider.g.dart';

@riverpod
class PensionTransactionNotifier extends _$PensionTransactionNotifier {
  @override
  Future<List<PensionTransaction>> build() async {
    return _fetchTransactions();
  }

  Future<List<PensionTransaction>> _fetchTransactions() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore
        .collection('pension_transaction')
        .orderBy('transaction_date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PensionTransaction.fromJson(data);
    }).toList();
  }

  Future<void> addTransaction(PensionTransaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      final data = transaction.toJson()..remove('id');

      await firestore.collection('pension_transaction').add(data);
      return _fetchTransactions();
    });
  }

  Future<void> updateTransaction(PensionTransaction transaction) async {
    if (transaction.id == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      final data = transaction.toJson()..remove('id');

      await firestore
          .collection('pension_transaction')
          .doc(transaction.id)
          .update(data);
      return _fetchTransactions();
    });
  }

  Future<void> deleteTransaction(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      await firestore.collection('pension_transaction').doc(id).delete();
      return _fetchTransactions();
    });
  }
}