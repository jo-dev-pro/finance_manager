import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    final snapshot = await firestore.collection('account').get();

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

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        final fileNameWithExt = imageFile.name;
        final fileExt = fileNameWithExt.contains('.')
            ? fileNameWithExt.split('.').last.toLowerCase()
            : 'png';

        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final storageRef = storage.ref().child('finance_logo/$fileName');

        String contentType = 'image/png';
        if (fileExt == 'jpg' || fileExt == 'jpeg') {
          contentType = 'image/jpeg';
        } else if (fileExt == 'webp') {
          contentType = 'image/webp';
        }

        await storageRef.putData(
          bytes,
          SettableMetadata(contentType: contentType),
        );
        logoUrl = await storageRef.getDownloadURL();
      }

      final updatedAccount = account.copyWith(logoUrl: logoUrl);
      final accountData = updatedAccount.toJson()..remove('id');

      await firestore.collection('account').add(accountData);
      return _fetchAccounts();
    });
  }

  // 3. 계좌 수정 (빈 문자열 "" 수정 정상 반영)
  Future<void> updateAccount(Account account, [XFile? newImageFile]) async {
    if (account.id == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      final storage = ref.read(firebaseStorageProvider);
      String? logoUrl = account.logoUrl;

      if (newImageFile != null) {
        if (account.logoUrl != null && account.logoUrl!.isNotEmpty) {
          try {
            final oldStorageRef = storage.refFromURL(account.logoUrl!);
            await oldStorageRef.delete();
          } catch (e) {
            print('이전 이미지 삭제 중 오류 발생 (무시 가능): $e');
          }
        }

        final bytes = await newImageFile.readAsBytes();
        final fileNameWithExt = newImageFile.name;
        final fileExt = fileNameWithExt.contains('.')
            ? fileNameWithExt.split('.').last.toLowerCase()
            : 'png';

        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final storageRef = storage.ref().child('finance_logo/$fileName');

        String contentType = 'image/png';
        if (fileExt == 'jpg' || fileExt == 'jpeg') {
          contentType = 'image/jpeg';
        } else if (fileExt == 'webp') {
          contentType = 'image/webp';
        }

        await storageRef.putData(
          bytes,
          SettableMetadata(contentType: contentType),
        );

        logoUrl = await storageRef.getDownloadURL();
      }

      final updatedAccount = account.copyWith(logoUrl: logoUrl);
      final accountData = updatedAccount.toJson()..remove('id');

      // SetOptions(merge: true)를 사용하거나 update로 전체 필드를 명시적으로 갱신
      await firestore.collection('account').doc(account.id).set(
            accountData,
            SetOptions(merge: true),
          );

      return _fetchAccounts();
    });
  }

  // 4. 계좌 삭제
  Future<void> deleteAccount(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      final storage = ref.read(firebaseStorageProvider);

      final docRef = firestore.collection('account').doc(id);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final String? logoUrl = data?['logo_url'] as String?;

        if (logoUrl != null && logoUrl.isNotEmpty) {
          try {
            final storageRef = storage.refFromURL(logoUrl);
            await storageRef.delete();
          } catch (e) {
            print('Storage 이미지 삭제 중 오류 발생 (무시 가능): $e');
          }
        }
      }

      await docRef.delete();
      return _fetchAccounts();
    });
  }
}