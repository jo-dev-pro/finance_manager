import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/account/account.dart';

part 'account_provider.g.dart';

@Riverpod(keepAlive: true)
class AccountNotifier extends _$AccountNotifier {
  @override
  Future<List<Account>> build() async {
    return _fetchAccounts();
  }

  // 1. 전체 계좌 목록 조회
  Future<List<Account>> _fetchAccounts() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore.collection(accountDBName).get();

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

      await firestore.collection(accountDBName).add(accountData);
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

      await firestore.collection(accountDBName).doc(account.id).set(
            accountData,
            SetOptions(merge: true),
          );

      // 💡 계좌 정보 변경 시 하위 컬렉션(월말 잔액, 보유 항목 등)의 account_name 갱신 전파
      try {
        // 최신 계좌명(AccountName) 가져오기
        final accountNamesSnap = await firestore.collection(accountNameDBName).get();
        final nameMap = {
          for (var doc in accountNamesSnap.docs) doc.id: doc.data()['account_name'] ?? ''
        };
        final nameStr = nameMap[updatedAccount.accountNameId] ?? '';
        final newAccountNameDisplay = '[${updatedAccount.financialInstitution}] $nameStr';

        final collections = [
          monthlyBankBalanceDBName,
          monthlyPensionBalanceDBName,
          monthlyStockBalanceDBName,
          stockHoldingItemDBName,
          pensionHoldingProductDBName,
        ];

        for (final colName in collections) {
          final snapshot = await firestore
              .collection(colName)
              .where('account_id', isEqualTo: account.id)
              .get();

          if (snapshot.docs.isEmpty) continue;

          WriteBatch batch = firestore.batch();
          int count = 0;

          for (final doc in snapshot.docs) {
            batch.update(doc.reference, {'account_name': newAccountNameDisplay});
            count++;

            if (count % 400 == 0) {
              await batch.commit();
              batch = firestore.batch();
            }
          }
          await batch.commit();
        }
      } catch (e) {
        print('하위 계좌명 동기화 중 오류 발생: $e');
      }

      return _fetchAccounts();
    });
  }

  // 💡 4. 계좌 상태만 부분 업데이트 (비활동/활동 변경용)
  Future<void> updateAccountStatus(String accountId, String status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      
      await firestore.collection(accountDBName).doc(accountId).update({
        'status': status,
      });

      return _fetchAccounts();
    });
  }

  // 5. 계좌 삭제
  Future<void> deleteAccount(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      final storage = ref.read(firebaseStorageProvider);

      final docRef = firestore.collection(accountDBName).doc(id);
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