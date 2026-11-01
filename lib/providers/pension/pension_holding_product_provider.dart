import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/pension/pension_holding_product.dart';
import '../account/account_provider.dart';
import '../account/account_name_provider.dart';
import 'pension_product_provider.dart';

part 'pension_holding_product_provider.g.dart';

@Riverpod(keepAlive: true)
class PensionHoldingProductNotifier extends _$PensionHoldingProductNotifier {
  @override
  Future<List<PensionHoldingProduct>> build() async {
    return fetchPensionHoldingProducts();
  }

  Future<List<PensionHoldingProduct>> fetchPensionHoldingProducts() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore.collection(pensionHoldingProductDBName).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PensionHoldingProduct.fromJson(data);
    }).toList();
  }

  Future<PensionHoldingProduct> _enrichNames(PensionHoldingProduct item) async {
    String? resolvedAccountName = item.accountName;
    String? resolvedProductName = item.productName;

    try {
      final accounts = await ref.read(accountNotifierProvider.future);
      final accountNames = await ref.read(accountNameNotifierProvider.future);
      final products = await ref.read(pensionProductNotifierProvider.future);

      if (resolvedAccountName == null || resolvedAccountName.isEmpty) {
        final matchedAcc = accounts.firstWhereOrNull((a) => a.id == item.accountId);
        final matchedNameObj = accountNames.firstWhereOrNull((an) => an.id == matchedAcc?.accountNameId);
        if (matchedNameObj != null) {
          final inst = matchedAcc?.financialInstitution ?? '';
          resolvedAccountName = '[$inst] ${matchedNameObj.accountName}';
        }
      }

      if (resolvedProductName == null || resolvedProductName.isEmpty) {
        if (item.productId == '_CASH_ASSET_PRODUCT_ID_') {
          resolvedProductName = '💵 계좌 공통 현금성 자산 (예수금)';
        } else {
          final matchedProd = products.firstWhereOrNull((p) => p.id == item.productId);
          if (matchedProd != null) {
            resolvedProductName = matchedProd.productName;
          }
        }
      }
    } catch (_) {}

    return item.copyWith(
      accountName: resolvedAccountName,
      productName: resolvedProductName,
    );
  }

  Future<void> addPensionHoldingProduct(PensionHoldingProduct item) async {
    final firestore = ref.read(firestoreProvider);
    final targetItem = await _enrichNames(item);
    final data = targetItem.toJson()..remove('id');

    await firestore.collection(pensionHoldingProductDBName).add(data);
    ref.invalidateSelf();
  }

  Future<void> updatePensionHoldingProduct(PensionHoldingProduct item) async {
    if (item.id == null) return;
    final firestore = ref.read(firestoreProvider);
    final targetItem = await _enrichNames(item);
    final data = targetItem.toJson()..remove('id');

    await firestore.collection(pensionHoldingProductDBName).doc(item.id).update(data);
    ref.invalidateSelf();
  }

  Future<void> deletePensionHoldingProduct(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(pensionHoldingProductDBName).doc(id).delete();
    ref.invalidateSelf();
  }
}