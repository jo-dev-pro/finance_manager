import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/pension/pension_product.dart';

part 'pension_product_provider.g.dart';

@Riverpod(keepAlive: true)
class PensionProductNotifier extends _$PensionProductNotifier {
  @override
  Future<List<PensionProduct>> build() async {
    return fetchPensionProducts();
  }

  Future<List<PensionProduct>> fetchPensionProducts() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore.collection(pensionProductDBName).get();

    final products =
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return PensionProduct.fromJson(data);
        }).toList();

    // 💡 상품명(productName) 순으로 정렬
    products.sort((a, b) => a.productName.compareTo(b.productName));

    return products;
  }

  Future<void> addPensionProduct(PensionProduct product) async {
    final firestore = ref.read(firestoreProvider);

    // 1. 상품명 중복 검사
    final existingSnapshot = await firestore.collection(pensionProductDBName).get();
    for (var doc in existingSnapshot.docs) {
      final data = doc.data();
      if (data['product_name'] == product.productName || data['productName'] == product.productName) {
        throw Exception('이미 등록된 상품명(${product.productName})입니다.');
      }
    }

    final data = product.toJson()..remove('id');

    await firestore.collection(pensionProductDBName).add(data);
    ref.invalidateSelf();
  }

  Future<void> updatePensionProduct(PensionProduct product) async {
    if (product.id == null) return;
    final firestore = ref.read(firestoreProvider);
    
    // 1. 상품명 중복 검사
    final existingSnapshot = await firestore.collection(pensionProductDBName).get();
    for (var doc in existingSnapshot.docs) {
      if (doc.id == product.id) continue;
      final data = doc.data();
      if (data['product_name'] == product.productName || data['productName'] == product.productName) {
        throw Exception('이미 존재하는 상품명(${product.productName})입니다.');
      }
    }

    final data = product.toJson()..remove('id');

    await firestore.collection(pensionProductDBName).doc(product.id).update(data);
    ref.invalidateSelf();
  }

  Future<void> deletePensionProduct(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(pensionProductDBName).doc(id).delete();
    ref.invalidateSelf();
  }
}
