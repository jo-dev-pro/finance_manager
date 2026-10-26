import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart'; // 컬렉션 이름 정의 파일
import '../../models/stock/stock_holding_item.dart';

part 'stock_holding_item_provider.g.dart';

@Riverpod(keepAlive: true)
class StockHoldingItemNotifier extends _$StockHoldingItemNotifier {
  @override
  Future<List<StockHoldingItem>> build() async {
    return fetchStockHoldingItems();
  }

  Future<List<StockHoldingItem>> fetchStockHoldingItems() async {
    final firestore = ref.read(firestoreProvider);
    // 💡 컬렉션명은 프로젝트 환경에 맞춰 지정하세요 (예: 'stock_holding_items')
    final snapshot = await firestore.collection(stockHoldingItemDBName).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return StockHoldingItem.fromJson(data);
    }).toList();
  }

  Future<void> addStockHoldingItem(StockHoldingItem item) async {
    final firestore = ref.read(firestoreProvider);
    final data = item.toJson()..remove('id');

    await firestore.collection(stockHoldingItemDBName).add(data);
    ref.invalidateSelf();
  }

  Future<void> updateStockHoldingItem(StockHoldingItem item) async {
    if (item.id == null) return;
    final firestore = ref.read(firestoreProvider);
    final data = item.toJson()..remove('id');

    await firestore.collection(stockHoldingItemDBName).doc(item.id).update(data);
    ref.invalidateSelf();
  }

  Future<void> deleteStockHoldingItem(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(stockHoldingItemDBName).doc(id).delete();
    ref.invalidateSelf();
  }
}