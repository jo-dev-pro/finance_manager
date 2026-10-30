import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/stock/stock_item.dart';

part 'stock_item_provider.g.dart';

@Riverpod(keepAlive: true)
class StockItemNotifier extends _$StockItemNotifier {
  @override
  Future<List<StockItem>> build() async {
    return await fetchStockItems();
  }

  // 종목 목록 조회
  Future<List<StockItem>> fetchStockItems() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot =
        await firestore
            .collection(stockItemDBName)
            .orderBy(
              'itemName',
              descending: false,
            ) // ascending: true -> descending: false 변경
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

    // 1. 중복 검사 (종목명 또는 종목코드 중복 확인)
    final existingSnapshot = await firestore.collection(stockItemDBName).get();
    for (var doc in existingSnapshot.docs) {
      final data = doc.data();
      if (data['itemName'] == item.itemName) {
        throw Exception('이미 등록된 종목명(${item.itemName})입니다.');
      }
      if (data['stockCode'] == item.stockCode) {
        throw Exception('이미 등록된 종목코드(${item.stockCode})입니다.');
      }
    }

    final data = item.toJson()..remove('id');

    // otherName 빈 문자열 처리 (null 안전성 추가)
    final otherNameVal = item.otherName ?? '';
    data['otherName'] = otherNameVal.trim().isEmpty ? '' : otherNameVal.trim();

    await firestore.collection(stockItemDBName).add(data);
    ref.invalidateSelf();
  }

  // 종목 수정
  Future<void> updateStockItem(StockItem item) async {
    if (item.id == null) return;
    final firestore = ref.read(firestoreProvider);

    // 1. 수정 시 타 문서와의 중복 검사 (자기 자신 제외)
    final existingSnapshot = await firestore.collection(stockItemDBName).get();
    for (var doc in existingSnapshot.docs) {
      if (doc.id == item.id) continue;
      final data = doc.data();
      if (data['itemName'] == item.itemName) {
        throw Exception('이미 존재하는 종목명(${item.itemName})입니다.');
      }
      if (data['stockCode'] == item.stockCode) {
        throw Exception('이미 존재하는 종목코드(${item.stockCode})입니다.');
      }
    }

    final data = item.toJson()..remove('id');

    await firestore.collection(stockItemDBName).doc(item.id).update(data);
    ref.invalidateSelf();
  }

  // 종목 삭제
  Future<void> deleteStockItem(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(stockItemDBName).doc(id).delete();
    ref.invalidateSelf();
  }
}
