import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/stock/stock_holding_item.dart';
import '../account/account_provider.dart';
import '../account/account_name_provider.dart';
import 'stock_item_provider.dart';

part 'stock_holding_item_provider.g.dart';

@Riverpod(keepAlive: true)
class StockHoldingItemNotifier extends _$StockHoldingItemNotifier {
  @override
  Future<List<StockHoldingItem>> build() async {
    return fetchStockHoldingItems();
  }

  Future<List<StockHoldingItem>> fetchStockHoldingItems() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore.collection(stockHoldingItemDBName).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return StockHoldingItem.fromJson(data);
    }).toList();
  }

  Future<StockHoldingItem> _enrichNames(StockHoldingItem item) async {
    String? resolvedAccountName = item.accountName;
    String? resolvedStockName = item.stockItemName;

    try {
      final accounts = await ref.read(accountNotifierProvider.future);
      final accountNames = await ref.read(accountNameNotifierProvider.future);
      final stockItems = await ref.read(stockItemNotifierProvider.future);

      if (resolvedAccountName == null || resolvedAccountName.isEmpty) {
        final matchedAcc = accounts.firstWhereOrNull((a) => a.id == item.accountId);
        final matchedNameObj = accountNames.firstWhereOrNull((an) => an.id == matchedAcc?.accountNameId);
        if (matchedNameObj != null) {
          final inst = matchedAcc?.financialInstitution ?? '';
          resolvedAccountName = '[$inst] ${matchedNameObj.accountName}';
        }
      }

      if (resolvedStockName == null || resolvedStockName.isEmpty) {
        final matchedStock = stockItems.firstWhereOrNull((s) => s.id == item.stockItemId);
        if (matchedStock != null) {
          resolvedStockName = '${matchedStock.itemName} (${matchedStock.stockCode})';
        }
      }
    } catch (_) {}

    return item.copyWith(
      accountName: resolvedAccountName,
      stockItemName: resolvedStockName,
    );
  }

  Future<void> addStockHoldingItem(StockHoldingItem item) async {
    final firestore = ref.read(firestoreProvider);
    final targetItem = await _enrichNames(item);
    final data = targetItem.toJson()..remove('id');

    await firestore.collection(stockHoldingItemDBName).add(data);
    ref.invalidateSelf();
  }

  Future<void> updateStockHoldingItem(StockHoldingItem item) async {
    if (item.id == null) return;
    final firestore = ref.read(firestoreProvider);
    final targetItem = await _enrichNames(item);
    final data = targetItem.toJson()..remove('id');

    await firestore.collection(stockHoldingItemDBName).doc(item.id).update(data);
    ref.invalidateSelf();
  }

  Future<void> deleteStockHoldingItem(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(stockHoldingItemDBName).doc(id).delete();
    ref.invalidateSelf();
  }
}