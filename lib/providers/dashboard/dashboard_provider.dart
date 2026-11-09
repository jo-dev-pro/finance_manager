import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../core/utils/number_formatter.dart';
import '../account/account_name_provider.dart';
import '../account/account_provider.dart';
import '../monthly_data/monthly_bank_balance_provider.dart';
import '../monthly_data/monthly_pension_account_balance_provider.dart';
import '../monthly_data/monthly_stock_account_balance_provider.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<List<String>> availableYearMonths(AvailableYearMonthsRef ref) async {
  final firestore = ref.watch(firestoreProvider);

  final bankSnap = await firestore.collection(monthlyBankBalanceDBName).get();
  final stockSnap = await firestore.collection(monthlyStockBalanceDBName).get();
  final pensionSnap =
      await firestore.collection(monthlyPensionBalanceDBName).get();
  final pensionAccountSnap =
      await firestore.collection(monthlyPensionAccountBalanceDBName).get();

  final Set<String> months = {};
  for (var doc in bankSnap.docs) {
    if (doc.data()['year_month'] != null) {
      months.add(doc.data()['year_month'] as String);
    }
  }
  for (var doc in stockSnap.docs) {
    if (doc.data()['year_month'] != null) {
      months.add(doc.data()['year_month'] as String);
    }
  }
  for (var doc in pensionSnap.docs) {
    if (doc.data()['year_month'] != null) {
      months.add(doc.data()['year_month'] as String);
    }
  }
  for (var doc in pensionAccountSnap.docs) {
    if (doc.data()['year_month'] != null) {
      months.add(doc.data()['year_month'] as String);
    }
  }

  final sortedList = months.toList()..sort((a, b) => b.compareTo(a));
  return sortedList;
}

@riverpod
class SelectedYearMonth extends _$SelectedYearMonth {
  @override
  String? build() {
    final monthsAsync = ref.watch(availableYearMonthsProvider);
    return monthsAsync.when(
      data: (months) => months.isNotEmpty ? months.first : null,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  void select(String yearMonth) {
    state = yearMonth;
  }
}

class DashboardSummary {
  final String yearMonth;
  final double totalInvested;
  final double bankBalance;
  final double stockBalance;
  final double pensionBalance;
  final double diffFromLastMonth;

  double get totalValuation => bankBalance + stockBalance;
  // double get totalValuation => bankBalance + stockBalance + pensionBalance;
  double get profitOrLoss => totalValuation - totalInvested;
  double get returnRate =>
      totalInvested > 0 ? (profitOrLoss / totalInvested) * 100 : 0.0;

  DashboardSummary({
    required this.yearMonth,
    required this.totalInvested,
    required this.bankBalance,
    required this.stockBalance,
    required this.pensionBalance,
    required this.diffFromLastMonth,
  });

  int get totalInvestedInt => totalInvested.round();
  int get bankBalanceInt => bankBalance.round();
  int get stockBalanceInt => stockBalance.round();
  int get pensionBalanceInt => pensionBalance.round();
  int get totalValuationInt => totalValuation.round();
  int get profitOrLossInt => profitOrLoss.round();

  String get totalInvestedWon => totalInvestedInt.toWon();
  String get bankBalanceWon => bankBalanceInt.toWon();
  String get stockBalanceWon => stockBalanceInt.toWon();
  String get pensionBalanceWon => pensionBalanceInt.toWon();
  String get totalValuationWon => totalValuationInt.toWon();
}

String _getLastYearMonth(String currentYearMonth) {
  try {
    final parts = currentYearMonth.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    DateTime lastMonthDate = DateTime(year, month - 1, 1);
    return DateFormat('yyyy-MM').format(lastMonthDate);
  } catch (_) {
    return currentYearMonth;
  }
}

// 💡 공통 자산 집계 헬퍼 함수 (환율 적용 및 balance 필드 정정)
Future _calculateStockAssets(
  Ref ref,
  String yearMonth,
) async {
  final firestore = ref.read(firestoreProvider);
  
  // 1. 계좌별 월말 데이터 (환율 및 현금성 잔액 포함) 조회
  final accountBalances = await ref.watch(
    monthlyStockAccountBalanceNotifierProvider(yearMonth).future,
  );
  
  // 계좌별 정보 맵핑 (환율 및 해외 계좌 여부 판별)
  final accountNames = await ref.watch(accountNameNotifierProvider.future);
  final accounts = await ref.watch(accountNotifierProvider.future);
  final accountMap = {for (var a in accounts) a.id!: a};
  final accountNameMap = {for (var an in accountNames) an.id: an};

  final Map<String, double> exchangeRateMap = {};
  final Set<String> overseasAccountIds = {};

  for (var ab in accountBalances) {
    final acc = accountMap[ab.accountId];
    final nameObj = acc != null ? accountNameMap[acc.accountNameId] : null;
    final accName = nameObj?.accountName ?? '';
    final inst = acc?.financialInstitution ?? '';
    
    // 해외 계좌 여부 판별
    final isOverseas = accName.contains('JO-해외') || inst.contains('JO-해외');
    if (isOverseas) {
      overseasAccountIds.add(ab.accountId);
      // 해외 계좌의 경우 저장된 환율 사용 (환율이 없거나 1 이하이면 기본 1300원 혹은 데이터 값 사용)
      exchangeRateMap[ab.accountId] = (ab.exchangeRate > 1.0) ? ab.exchangeRate : 1300.0; // 안전 장치
    } else {
      exchangeRateMap[ab.accountId] = 1.0; // 국내 계좌는 환율 1.0 고정
    }
  }
  
  // 계좌별 현금성 잔액 합산
  double cashTotal = 0;
  for (var ab in accountBalances) {
    final cash = ab.cashBalance;
    final isOverseas = overseasAccountIds.contains(ab.accountId);
    final rate = exchangeRateMap[ab.accountId] ?? 1.0;

    if (isOverseas) {
      // 해외 계좌 현금(달러) * 환율 = 원화 환산
      cashTotal += cash * rate;
    } else {
      cashTotal += cash; // 국내 계좌 현금
    }
  }

  // 2. 종목별 월말 평가액 (`balance` 필드) 조회
  final stockSnap =
      await firestore
          .collection(monthlyStockBalanceDBName)
          .where('year_month', isEqualTo: yearMonth)
          .get();

  double stockBalanceTotal = 0;
  for (var doc in stockSnap.docs) {
    final data = doc.data();
    final accountId = data['account_id'] as String? ?? '';
    final balance = ((data['balance'] ?? 0) as num).toDouble();
    final isOverseas = overseasAccountIds.contains(accountId);
    final rate = exchangeRateMap[accountId] ?? 1.0;

    if (isOverseas) {
      // 💡 해외 주식 평가액(달러)에 해당 월 환율을 곱해 원화로 환산
      stockBalanceTotal += balance * rate;
    } else {
      // 국내 주식 평가액은 원화 그대로 합산
      stockBalanceTotal += balance;
    }
  }

  return {
    'stockBalance': stockBalanceTotal + cashTotal,
  };
}

@Riverpod(keepAlive: true)
Future<DashboardSummary> dashboardSummary(DashboardSummaryRef ref) async {
  String? selectedMonth = ref.watch(selectedYearMonthProvider);

  if (selectedMonth == null) {
    final availableMonths = await ref.watch(availableYearMonthsProvider.future);
    if (availableMonths.isNotEmpty) {
      selectedMonth = availableMonths.first;
    } else {
      return DashboardSummary(
        yearMonth: '',
        totalInvested: 0,
        bankBalance: 0,
        stockBalance: 0,
        pensionBalance: 0,
        diffFromLastMonth: 0,
      );
    }
  }

  final firestore = ref.watch(firestoreProvider);

  // 1. 총 투자원금
  final investSnap = await firestore.collection(investmentDBName).get();
  final totalInvested = investSnap.docs.fold<double>(
    0,
    (sum, doc) => sum + ((doc.data()['amount'] ?? 0) as num).toDouble(),
  );

  // 2. 은행 총 잔액 (당월)
  final bankBalances = await ref.watch(
    monthlyBankBalanceNotifierProvider(selectedMonth).future,
  );
  final bankBalance = bankBalances.fold<double>(
    0.0,
    (sum, item) => sum + item.balance,
  );

  // 3. 증권 총 평가액 (당월 - 환율 반영 및 올바른 필드 연동)
  final stockAssets = await _calculateStockAssets(ref, selectedMonth);
  final stockBalance = stockAssets['stockBalance'] ?? 0.0;

  // 4. 연금 상품별 총 평가액 (당월)
  final pensionSnap =
      await firestore
          .collection(monthlyPensionBalanceDBName)
          .where('year_month', isEqualTo: selectedMonth)
          .get();
  final pensionProductBalance = pensionSnap.docs.fold<double>(
    0,
    (sum, doc) =>
        sum + ((doc.data()['balance'] ?? 0) as num).toDouble(),
  );

  // 5. 연금 계좌별 현금성 자산(예수금) 총액 합산 (당월)
  final pensionAccountBalances = await ref.watch(
    monthlyPensionAccountBalanceNotifierProvider(selectedMonth).future,
  );
  final pensionCashBalance = pensionAccountBalances.fold<double>(
    0.0,
    (sum, item) => sum + item.cashBalance,
  );

  final pensionBalance = pensionProductBalance + pensionCashBalance;
  final totalValuation = bankBalance + stockBalance + pensionBalance;

  // 6. 전월 총 자산 계산을 위한 전월 데이터 조회
  final lastMonth = _getLastYearMonth(selectedMonth);
  
  final lastBankBalances = await ref.watch(
    monthlyBankBalanceNotifierProvider(lastMonth).future,
  );
  final lastBankBalance = lastBankBalances.fold<double>(
    0.0,
    (sum, item) => sum + item.balance,
  );

  final lastStockAssets = await _calculateStockAssets(ref, lastMonth);
  final lastStockBalance = lastStockAssets['stockBalance'] ?? 0.0;

  final lastPensionSnap =
      await firestore
          .collection(monthlyPensionBalanceDBName)
          .where('year_month', isEqualTo: lastMonth)
          .get();
  final lastPensionProductBalance = lastPensionSnap.docs.fold<double>(
    0,
    (sum, doc) =>
        sum + ((doc.data()['balance'] ?? 0) as num).toDouble(),
  );

  final lastPensionAccountBalances = await ref.watch(
    monthlyPensionAccountBalanceNotifierProvider(lastMonth).future,
  );
  final lastPensionCashBalance = lastPensionAccountBalances.fold<double>(
    0.0,
    (sum, item) => sum + item.cashBalance,
  );

  final lastPensionBalance = lastPensionProductBalance + lastPensionCashBalance;
  final lastTotalValuation = lastBankBalance + lastStockBalance + lastPensionBalance;

  final diffFromLastMonth = totalValuation - lastTotalValuation;

  return DashboardSummary(
    yearMonth: selectedMonth,
    totalInvested: totalInvested,
    bankBalance: bankBalance,
    stockBalance: stockBalance,
    pensionBalance: pensionBalance,
    diffFromLastMonth: diffFromLastMonth,
  );
}