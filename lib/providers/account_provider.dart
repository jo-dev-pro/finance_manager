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
    final snapshot =
        await firestore
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
        // 1. 파일 확장자 및 MIME Type 구하기 (mime 패키지 사용 권장 또는 name 속성 활용)
        // XFile의 name 속성을 사용하면 웹에서도 정확한 파일명을 가져옵니다.
        final fileNameWithExt = imageFile.name;
        final fileExt =
            fileNameWithExt.contains('.')
                ? fileNameWithExt.split('.').last.toLowerCase()
                : 'png';

        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final storageRef = storage.ref().child('finance_logo/$fileName');

        // 2. MIME Type 설정 (image/jpeg, image/png 등)
        String contentType = 'image/png';
        if (fileExt == 'jpg' || fileExt == 'jpeg') {
          contentType = 'image/jpeg';
        } else if (fileExt == 'webp') {
          contentType = 'image/webp';
        }

        // 3. SettableMetadata를 포함하여 업로드
        await storageRef.putData(
          bytes,
          SettableMetadata(contentType: contentType),
        );
        logoUrl = await storageRef.getDownloadURL();
      }

      final updatedAccount = account.copyWith(logoUrl: logoUrl);
      final accountData =
          updatedAccount.toJson()
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

      // 새 이미지가 전달된 경우
      if (newImageFile != null) {
        // 1. 기존 이미지가 존재했다면 Storage에서 이전 이미지 삭제
        if (account.logoUrl != null && account.logoUrl!.isNotEmpty) {
          try {
            final oldStorageRef = storage.refFromURL(account.logoUrl!);
            await oldStorageRef.delete();
          } catch (e) {
            // 이전 파일이 이미 존재하지 않더라도 업데이트 진행이 멈추지 않도록 예외 처리
            print('이전 이미지 삭제 중 오류 발생 (무시 가능): $e');
          }
        }

        // 2. 새 이미지 업로드 준비
        final bytes = await newImageFile.readAsBytes();
        final fileNameWithExt = newImageFile.name;
        final fileExt =
            fileNameWithExt.contains('.')
                ? fileNameWithExt.split('.').last.toLowerCase()
                : 'png';

        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final storageRef = storage.ref().child('finance_logo/$fileName');

        // 3. MIME Type 설정
        String contentType = 'image/png';
        if (fileExt == 'jpg' || fileExt == 'jpeg') {
          contentType = 'image/jpeg';
        } else if (fileExt == 'webp') {
          contentType = 'image/webp';
        }

        // 4. 새 이미지 Storage 업로드
        await storageRef.putData(
          bytes,
          SettableMetadata(contentType: contentType),
        );

        // 5. 새 이미지 URL 획득
        logoUrl = await storageRef.getDownloadURL();
      }

      // 6. 변경된 logoUrl 적용 후 Map 변환
      final updatedAccount = account.copyWith(logoUrl: logoUrl);
      final accountData =
          updatedAccount.toJson()
            ..remove('id')
            ..removeWhere((key, value) => value == null);

      // 7. Firestore 문서 업데이트
      await firestore.collection('account').doc(account.id).update(accountData);

      return _fetchAccounts();
    });
  }

  // 4. 계좌 삭제
  Future<void> deleteAccount(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final firestore = ref.read(firestoreProvider);
      final storage = ref.read(firebaseStorageProvider);

      // 1. 삭제할 계좌 문서를 미리 가져와서 logoUrl 확인
      final docRef = firestore.collection('account').doc(id);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final String? logoUrl = data?['logo_url'] as String?;

        // 2. Storage에 저장된 이미지가 있는 경우 파일 삭제
        if (logoUrl != null && logoUrl.isNotEmpty) {
          try {
            // getReferenceFromUrl을 사용하면 URL 경로로 StorageReference를 바로 가져옵니다.
            final storageRef = storage.refFromURL(logoUrl);
            await storageRef.delete();
          } catch (e) {
            // 이미지가 Storage에서 이미 삭제되었거나 없는 경우 발생하는 에러 방지
            print('Storage 이미지 삭제 중 오류 발생 (무시 가능): $e');
          }
        }
      }

      // 3. Firestore 문서 삭제
      await docRef.delete();

      // 4. 최신 목록 재조회 및 반환
      return _fetchAccounts();
    });
  }
}
