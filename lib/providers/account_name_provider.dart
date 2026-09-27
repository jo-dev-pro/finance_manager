import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/providers/firestore_provider.dart';
import '../models/account_name.dart';

part 'account_name_provider.g.dart';

@riverpod
class AccountNameNotifier extends _$AccountNameNotifier {
  @override
  Future<List<AccountName>> build() async {
    return fetchAccountNames();
  }

  // 목록 조회
  Future<List<AccountName>> fetchAccountNames() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore.collection('account_name').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Document ID 매핑
      return AccountName.fromJson(data);
    }).toList();
  }

  // 추가 및 수정
  Future<void> saveAccountName(AccountName name) async {
    final firestore = ref.read(firestoreProvider);
    final data = name.toJson()..remove('id');

    if (name.id == null || name.id!.isEmpty) {
      // 신규 등록
      await firestore.collection('account_name').add(data);
    } else {
      // 수정
      await firestore
          .collection('account_name')
          .doc(name.id)
          .update(data);
    }

    // 상태 갱신
    ref.invalidateSelf();
  }

  // 삭제
  Future<void> deleteAccountName(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection('account_name').doc(id).delete();

    // 상태 갱신
    ref.invalidateSelf();
  }
}