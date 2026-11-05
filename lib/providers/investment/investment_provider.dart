import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/investment/investment.dart';

part 'investment_provider.g.dart';

@riverpod
class InvestmentNotifier extends _$InvestmentNotifier {
  @override
  Future<List<Investment>> build() async {
    return fetchInvestments();
  }

  Future<List<Investment>> fetchInvestments() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot =
        await firestore
            .collection(investmentDBName)
            .orderBy('created_at', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Investment.fromJson(data);
    }).toList();
  }

  Future<void> addInvestment(Investment investment) async {
    final firestore = ref.read(firestoreProvider);
    final data =
        investment.toJson()
          ..remove('id')
          ..removeWhere((key, value) => value == null);

    // 전달받은 createdAt이 있으면 사용하고, 없으면 현재 날짜(yyyy-MM-dd) 적용
    data['created_at'] =
        investment.createdAt ?? DateTime.now().toIso8601String().split('T')[0];

    await firestore.collection(investmentDBName).add(data);
    ref.invalidateSelf();
  }

  Future<void> updateInvestment(Investment investment) async {
    if (investment.id == null) return;
    final firestore = ref.read(firestoreProvider);

    final data = investment.toJson()..remove('id');
    
    if (investment.createdAt != null) {
      data['created_at'] = investment.createdAt;
    }

    await firestore
        .collection(investmentDBName)
        .doc(investment.id)
        .update(data);
    ref.invalidateSelf();
  }

  Future<void> deleteInvestment(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(investmentDBName).doc(id).delete();
    ref.invalidateSelf();
  }
}
