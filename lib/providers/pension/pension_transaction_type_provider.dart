import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/pension/pension_transaction_type.dart';

part 'pension_transaction_type_provider.g.dart';

@Riverpod(keepAlive: true)
class PensionTransactionTypeNotifier extends _$PensionTransactionTypeNotifier {
  @override
  Future<List<PensionTransactionType>> build() async {
    return _fetchPensionTransactionTypes();
  }

  // 1. 전체 거래구분 목록 조회 (displayOrder 오름차순)
  Future<List<PensionTransactionType>> _fetchPensionTransactionTypes() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot =
        await firestore
            .collection(pensionTransactionTypeDBName)
            .orderBy('displayOrder', descending: false)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Document ID 매핑
      return PensionTransactionType.fromJson(data);
    }).toList();
  }

  // 2. 거래구분 추가
  Future<void> addPensionTransactionType(PensionTransactionType type) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      final typeData = type.toJson()..remove('id');

      await firestore.collection(pensionTransactionTypeDBName).add(typeData);
      return _fetchPensionTransactionTypes();
    });
  }

  // 3. 거래구분 수정
  Future<void> updatePensionTransactionType(PensionTransactionType type) async {
    if (type.id == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      final typeData = type.toJson()..remove('id');

      await firestore
          .collection(pensionTransactionTypeDBName)
          .doc(type.id)
          .set(typeData, SetOptions(merge: true));

      return _fetchPensionTransactionTypes();
    });
  }

  // 4. 거래구분 삭제
  Future<void> deletePensionTransactionType(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);

      await firestore.collection(pensionTransactionTypeDBName).doc(id).delete();
      return _fetchPensionTransactionTypes();
    });
  }
}
