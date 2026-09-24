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

// 🌐 특정 계좌 ID(accountId) 기준 거래 내역 필터링
@riverpod
Future<List<PensionTransaction>> pensionTransactionsByAccount(
  PensionTransactionsByAccountRef ref,
  String accountId,
) async {
  if (accountId.isEmpty) return [];

  final allTransactions =
      await ref.watch(pensionTransactionNotifierProvider.future);
  return allTransactions.where((t) => t.accountId == accountId).toList();
}

// 🌐 특정 상품 ID(productId) 기준 거래 내역 필터링 (필요 시 활용)
@riverpod
Future<List<PensionTransaction>> pensionTransactionsByProduct(
  PensionTransactionsByProductRef ref,
  String productId,
) async {
  if (productId.isEmpty) return [];

  final allTransactions =
      await ref.watch(pensionTransactionNotifierProvider.future);
  return allTransactions.where((t) => t.productId == productId).toList();
}