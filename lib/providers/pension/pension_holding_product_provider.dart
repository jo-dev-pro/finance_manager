import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/pension/pension_holding_product.dart';

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

  Future<void> addPensionHoldingProduct(PensionHoldingProduct item) async {
    final firestore = ref.read(firestoreProvider);
    final data = item.toJson()..remove('id');

    await firestore.collection(pensionHoldingProductDBName).add(data);
    ref.invalidateSelf();
  }

  Future<void> updatePensionHoldingProduct(PensionHoldingProduct item) async {
    if (item.id == null) return;
    final firestore = ref.read(firestoreProvider);
    final data = item.toJson()..remove('id');

    await firestore.collection(pensionHoldingProductDBName).doc(item.id).update(data);
    ref.invalidateSelf();
  }

  Future<void> deletePensionHoldingProduct(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(pensionHoldingProductDBName).doc(id).delete();
    ref.invalidateSelf();
  }
}