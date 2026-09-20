import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/providers/firestore_provider.dart';
import '../models/stock_item.dart';

part 'stock_item_provider.g.dart';

@riverpod
class StockItemNotifier extends _$StockItemNotifier {
  @override
  Future<List<StockItem>> build() async {
    return await fetchStockItems();
  }

  // 종목 목록 조회
  Future<List<StockItem>> fetchStockItems() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore
        .collection('stock_item')
        .orderBy('name', descending: false) // ascending: true -> descending: false 변경
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return StockItem.fromJson(data);
    }).toList();
  }

  // 종목 추가
  Future<void> addStockItem(StockItem item) async {
    final firestore = ref.read(firestoreProvider);
    final data = item.toJson()
      ..remove('id')
      ..removeWhere((key, value) => value == null);

    data['created_at'] = FieldValue.serverTimestamp();

    await firestore.collection('stock_item').add(data);
    ref.invalidateSelf();
  }

  // 종목 수정
  Future<void> updateStockItem(StockItem item) async {
    if (item.id == null) return;
    final firestore = ref.read(firestoreProvider);
    final data = item.toJson()..remove('id');

    await firestore
        .collection('stock_item')
        .doc(item.id)
        .update(data);
    ref.invalidateSelf();
  }

  // 종목 삭제
  Future<void> deleteStockItem(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore
        .collection('stock_item')
        .doc(id)
        .delete();
    ref.invalidateSelf();
  }
}