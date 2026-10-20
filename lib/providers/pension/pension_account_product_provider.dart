import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../models/pension/pension_account_product.dart';

part 'pension_account_product_provider.g.dart';

// 연금 계좌에 보유된 상품 정보 db
// 컬렉션 이름은 프로젝트에 맞게 상수로 관리하시거나 문자열로 지정해 주세요.
const String pensionAccountProductDBName = 'pension_account_products';

@Riverpod(keepAlive: true)
class PensionAccountProductNotifier extends _$PensionAccountProductNotifier {
  @override
  Future<List<PensionAccountProduct>> build() async {
    return fetchPensionAccountProducts();
  }

  Future<List<PensionAccountProduct>> fetchPensionAccountProducts() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore.collection(pensionAccountProductDBName).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PensionAccountProduct.fromJson(data);
    }).toList();
  }

  Future<void> addPensionAccountProduct(PensionAccountProduct item) async {
    final firestore = ref.read(firestoreProvider);
    final data = item.toJson()..remove('id');

    await firestore.collection(pensionAccountProductDBName).add(data);
    ref.invalidateSelf();
  }

  Future<void> updatePensionAccountProduct(PensionAccountProduct item) async {
    if (item.id == null) return;
    final firestore = ref.read(firestoreProvider);
    final data = item.toJson()..remove('id');

    await firestore.collection(pensionAccountProductDBName).doc(item.id).update(data);
    ref.invalidateSelf();
  }

  Future<void> deletePensionAccountProduct(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(pensionAccountProductDBName).doc(id).delete();
    ref.invalidateSelf();
  }
}