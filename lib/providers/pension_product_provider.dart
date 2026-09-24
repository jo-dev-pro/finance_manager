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
    final snapshot = await firestore
        .collection('pension_product')
        .orderBy('account_id', descending: false) // 👈 account_name -> account_id 로 변경
        .orderBy('product_name', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PensionProduct.fromJson(data);
    }).toList();
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

    await firestore
        .collection('pension_product')
        .doc(product.id)
        .update(data);
    ref.invalidateSelf();
  }

  Future<void> deletePensionProduct(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection('pension_product').doc(id).delete();
    ref.invalidateSelf();
  }
}

// 🌐 특정 계좌 ID로 연금상품 목록을 필터링하는 프로바이더
@riverpod
Future<List<PensionProduct>> pensionProductsByAccount(
  PensionProductsByAccountRef ref,
  String accountId, // 👈 accountName -> accountId
) async {
  if (accountId.isEmpty) return [];

  final allProducts = await ref.watch(pensionProductNotifierProvider.future);
  return allProducts.where((p) => p.accountId == accountId).toList(); // 👈 p.accountName -> p.accountId
}