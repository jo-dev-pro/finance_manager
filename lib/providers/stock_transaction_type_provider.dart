import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/providers/firestore_provider.dart';

import '../models/stock_transaction_type.dart';

part 'stock_transaction_type_provider.g.dart';

@riverpod
class StockTransactionTypeNotifier extends _$StockTransactionTypeNotifier {
  @override
  Future<List<StockTransactionType>> build() async {
    return await fetchStockTransactionTypes();
  }

  // 종목 목록 조회
  Future<List<StockTransactionType>> fetchStockTransactionTypes() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore
        .collection('stock_transaction_type')
        .orderBy('typeName', descending: false) // ascending: true -> descending: false 변경
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return StockTransactionType.fromJson(data);
    }).toList();
  }

  // 종목 추가
  Future<void> addStockTransactionType(StockTransactionType item) async {
    final firestore = ref.read(firestoreProvider);
    final data = item.toJson()
      ..remove('id')
      ..removeWhere((key, value) => value == null);

    data['created_at'] = FieldValue.serverTimestamp();

    await firestore.collection('stock_transaction_type').add(data);
    ref.invalidateSelf();
  }

  // 종목 수정
  Future<void> updateStockTransactionType(StockTransactionType item) async {
    if (item.id == null) return;
    final firestore = ref.read(firestoreProvider);
    final data = item.toJson()..remove('id');

    await firestore
        .collection('stock_transaction_type')
        .doc(item.id)
        .update(data);
    ref.invalidateSelf();
  }

  // 종목 삭제
  Future<void> deleteStockTransactionType(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore
        .collection('stock_transaction_type')
        .doc(id)
        .delete();
    ref.invalidateSelf();
  }
}