import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../models/account/account.dart';
import '../../models/account/account_name.dart';
import '../../models/pension/pension_product.dart';
import '../../models/monthly_data/monthly_pension_balance.dart';
import '../account/account_provider.dart';
import '../account/account_name_provider.dart';
import '../pension/pension_product_provider.dart';

part 'monthly_pension_balance_provider.g.dart';

class MonthlyPensionBalanceWithDetail {
  final MonthlyPensionBalance balanceItem;
  final Account? account;
  final AccountName? accountName;
  final PensionProduct? product;

  MonthlyPensionBalanceWithDetail({
    required this.balanceItem,
    this.account,
    this.accountName,
    this.product,
  });

  String get accountNameDisplay => accountName?.accountName ?? '알 수 없는 계좌';
  String get financialInstitution => account?.financialInstitution ?? '';
  String get productName => product?.productName ?? '알 수 없는 상품';
}

// 💡 함수형 대신 클래스 기반 프로바이더로 변경하여 Ref 클래스 충돌 및 생성 오류 원천 방지
@riverpod
class AllMonthlyPensionBalances extends _$AllMonthlyPensionBalances {
  @override
  Future<List<MonthlyPensionBalanceWithDetail>> build() async {
    return fetchAllBalances();
  }

 Future<List<MonthlyPensionBalanceWithDetail>> fetchAllBalances() async {
    final firestore = ref.watch(firestoreProvider);
    
    // 💡 데이터들을 안전하게 각각 가져오기 (에러 방지 및 예외 처리)
    List<Account> accounts = [];
    List<AccountName> accountNames = [];
    List<PensionProduct> products = [];

    try {
      accounts = await ref.watch(accountNotifierProvider.future);
    } catch (_) {}

    try {
      accountNames = await ref.watch(accountNameNotifierProvider.future);
    } catch (_) {}

    try {
      products = await ref.watch(pensionProductNotifierProvider.future);
    } catch (_) {}

    final snapshot = await firestore.collection(monthlyPensionBalanceDBName).get();

    final balances = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MonthlyPensionBalance.fromJson(data);
    }).toList();

    // 계좌 및 계좌 이름 맵 준비
    final accountMap = {for (var a in accounts) a.id!: a};
    final accountNameMap = {for (var an in accountNames) an.id: an};
    
    // 💡 상품 ID 매핑을 위한 맵 생성 (공백 제거 등 안전 처리)
    final productMap = {
      for (var p in products) 
        if (p.id != null) p.id!.trim(): p
    };

    // 정렬 로직 (기준월 최신순 -> 계좌명순)
    balances.sort((a, b) {
      int monthCompare = b.yearMonth.compareTo(a.yearMonth);
      if (monthCompare != 0) return monthCompare;

      final accA = accountMap[a.accountId];
      final accB = accountMap[b.accountId];
      
      final nameA = '${accA?.financialInstitution ?? ''}_${accountNameMap[accA?.accountNameId]?.accountName ?? ''}';
      final nameB = '${accB?.financialInstitution ?? ''}_${accountNameMap[accB?.accountNameId]?.accountName ?? ''}';

      return nameA.compareTo(nameB);
    });

    return balances.map((b) {
      final matchedAccount = accountMap[b.accountId];
      final matchedAccountName = matchedAccount != null ? accountNameMap[matchedAccount.accountNameId] : null;
      
      // 💡 맵을 통해 상품 안전하게 찾기 (공백 제거 비교)
      final cleanProductId = b.productId.trim();
      final matchedProduct = productMap[cleanProductId];

      return MonthlyPensionBalanceWithDetail(
        balanceItem: b,
        account: matchedAccount,
        accountName: matchedAccountName,
        product: matchedProduct, // 💡 매칭된 상품 객체 전달
      );
    }).toList();
  }
}

@Riverpod(keepAlive: true)
class MonthlyPensionBalanceNotifier extends _$MonthlyPensionBalanceNotifier {
  @override
  Future<List<MonthlyPensionBalance>> build(String yearMonth) async {
    return fetchBalances(yearMonth);
  }

  Future<List<MonthlyPensionBalance>> fetchBalances(String yearMonth) async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore
        .collection(monthlyPensionBalanceDBName)
        .where('year_month', isEqualTo: yearMonth)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MonthlyPensionBalance.fromJson(data);
    }).toList();
  }

  Future<void> saveBalance(MonthlyPensionBalance balance) async {
    final firestore = ref.read(firestoreProvider);
    final data = balance.toJson()..remove('id');

    if (balance.id == null) {
      await firestore.collection(monthlyPensionBalanceDBName).add(data);
    } else {
      await firestore
          .collection(monthlyPensionBalanceDBName)
          .doc(balance.id)
          .update(data);
    }
    ref.invalidateSelf();
    ref.invalidate(allMonthlyPensionBalancesProvider);
  }

  Future<void> deleteBalance(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection(monthlyPensionBalanceDBName).doc(id).delete();
    ref.invalidateSelf();
    ref.invalidate(allMonthlyPensionBalancesProvider);
  }
}