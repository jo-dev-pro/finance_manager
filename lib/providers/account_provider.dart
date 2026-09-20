import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/providers/firestore_provider.dart';
import '../models/account.dart';

part 'account_provider.g.dart';

@riverpod
class AccountNotifier extends _$AccountNotifier {
  @override
  Future<List<Account>> build() async {
    return _fetchAccounts();
  }

  // 1. 전체 계좌 목록 조회
  Future<List<Account>> _fetchAccounts() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore
        .collection('account')
        // .orderBy('created_at')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Document ID 매핑
      return Account.fromJson(data);
    }).toList();
  }

  // 2. 계좌 추가 (이미지 업로드 포함)
  Future<void> addAccount(Account account, XFile? imageFile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      final storage = ref.read(firebaseStorageProvider);
      String? logoUrl;

      // 이미지 Firebase Storage 업로드
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        final fileExt = imageFile.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final storageRef = storage.ref().child('finance_logo/$fileName');

        await storageRef.putData(bytes);
        logoUrl = await storageRef.getDownloadURL();
      }

      final updatedAccount = account.copyWith(logoUrl: logoUrl);
      final accountData = updatedAccount.toJson()
        ..remove('id')
        ..removeWhere((key, value) => value == null);

      accountData['created_at'] = FieldValue.serverTimestamp();

      await firestore.collection('account').add(accountData);
      return _fetchAccounts();
    });
  }

  // 3. 계좌 수정
  Future<void> updateAccount(Account account, [XFile? newImageFile]) async {
    if (account.id == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      final storage = ref.read(firebaseStorageProvider);
      String? logoUrl = account.logoUrl;

      if (newImageFile != null) {
        final bytes = await newImageFile.readAsBytes();
        final fileExt = newImageFile.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final storageRef = storage.ref().child('finance_logo/$fileName');

        await storageRef.putData(bytes);
        logoUrl = await storageRef.getDownloadURL();
      }

      final updatedAccount = account.copyWith(logoUrl: logoUrl);
      final accountData = updatedAccount.toJson()
        ..remove('id')
        ..removeWhere((key, value) => value == null);

      await firestore
          .collection('account')
          .doc(account.id)
          .update(accountData);

      return _fetchAccounts();
    });
  }

  // 4. 계좌 삭제
  Future<void> deleteAccount(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      await firestore.collection('account').doc(id).delete();
      return _fetchAccounts();
    });
  }
}