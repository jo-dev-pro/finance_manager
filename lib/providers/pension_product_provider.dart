import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/providers/firestore_provider.dart';
import '../models/pension_product.dart';

part 'pension_product_provider.g.dart';

@riverpod
class PensionProductNotifier extends _$PensionProductNotifier {
  @override
  Future<List<PensionProduct>> build() async {
    return fetchPensionProducts();
  }

  Future<List<PensionProduct>> fetchPensionProducts() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore.collection('pension_product').get();

    final products = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PensionProduct.fromJson(data);
    }).toList();

    // accountId -> productName 순으로 정렬
    products.sort((a, b) {
      int compareAccountId = a.accountId.compareTo(b.accountId);
      if (compareAccountId != 0) return compareAccountId;
      return a.productName.compareTo(b.productName);
    });

    return products;
  }

  Future<void> addPensionProduct(PensionProduct product) async {
    final firestore = ref.read(firestoreProvider);
    final data = product.toJson()..remove('id');

    await firestore.collection('pension_product').add(data);
    ref.invalidateSelf();
  }

  Future<void> updatePensionProduct(PensionProduct product) async {
    if (product.id == null) return;
    final firestore = ref.read(firestoreProvider);
    final data = product.toJson()..remove('id');

    await firestore.collection('pension_product').doc(product.id).update(data);
    ref.invalidateSelf();
  }

  Future<void> deletePensionProduct(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection('pension_product').doc(id).delete();
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<PensionProduct>> pensionProductsByAccount(
  PensionProductsByAccountRef ref,
  String accountId,
) async {
  if (accountId.isEmpty) return [];

  final allProducts = await ref.watch(pensionProductNotifierProvider.future);
  return allProducts.where((p) => p.accountId == accountId).toList();
}