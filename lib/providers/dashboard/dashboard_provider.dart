import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/firestore_provider.dart';
import '../../core/utils/collection_name.dart';
import '../../core/utils/number_formatter.dart';
import '../monthly_data/monthly_bank_balance_provider.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<List<String>> availableYearMonths(AvailableYearMonthsRef ref) async {
  final firestore = ref.watch(firestoreProvider);

  final bankSnap = await firestore.collection(monthlyBankBalanceDBName).get();
  final stockSnap = await firestore.collection(monthlyStockBalanceDBName).get();
  final pensionSnap =
      await firestore.collection(monthlyPensionBalanceDBName).get();

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

  // 내림차순 정렬 (가장 최신 월이 Index 0)
  final sortedList = months.toList()..sort((a, b) => b.compareTo(a));
  return sortedList;
}

@riverpod
class SelectedYearMonth extends _$SelectedYearMonth {
  @override
  String? build() {
    // availableYearMonthsProvider의 상태를 관찰하여 최신 월(index 0)을 기본값으로 설정
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

  double get totalValuation => bankBalance + stockBalance + pensionBalance;
  double get profitOrLoss => totalValuation - totalInvested;
  double get returnRate =>
      totalInvested > 0 ? (profitOrLoss / totalInvested) * 100 : 0.0;

  DashboardSummary({
    required this.yearMonth,
    required this.totalInvested,
    required this.bankBalance,
    required this.stockBalance,
    required this.pensionBalance,
  });

  // ------------------------------------------------------------
  // NumberFormatter 확장 메서드 활용 Getter
  // ------------------------------------------------------------

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

  String get totalInvestedKoreanWon => totalInvestedInt.toKoreanWon();
  String get bankBalanceKoreanWon => bankBalanceInt.toKoreanWon();
  String get stockBalanceKoreanWon => stockBalanceInt.toKoreanWon();
  String get pensionBalanceKoreanWon => pensionBalanceInt.toKoreanWon();
  String get totalValuationKoreanWon => totalValuationInt.toKoreanWon();

  String get profitOrLossFormatted =>
      '${profitOrLossInt.toSignedCommaString()}원';

  String get returnRateFormatted =>
      '${returnRate > 0 ? '+' : ''}${returnRate.toStringAsFixed(2)}%';

  Widget buildProfitOrLossText({TextStyle? style}) {
    return profitOrLossInt.toSignedPriceText(style: style);
  }
}

@Riverpod(keepAlive: true)
Future<DashboardSummary> dashboardSummary(DashboardSummaryRef ref) async {
  String? selectedMonth = ref.watch(selectedYearMonthProvider);

  // 만약 선택된 월이 없으면 availableYearMonths에서 최신 월을 가져옴
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
      );
    }
  }

  final firestore = ref.watch(firestoreProvider);

  // 1. 총 투자원금
  final investSnap = await firestore.collection('investment').get();
  final totalInvested = investSnap.docs.fold<double>(
    0,
    (sum, doc) => sum + ((doc.data()['amount'] ?? 0) as num).toDouble(),
  );

  // 2. 은행 총 잔액
  final bankBalances = await ref.watch(
    monthlyBankBalanceNotifierProvider(selectedMonth).future,
  );
  final bankBalance = bankBalances.fold<double>(
    0.0,
    (sum, item) => sum + item.balance,
  );

  // 3. 증권 총 평가액
  final stockSnap =
      await firestore
          .collection('monthly_stock_balance')
          .where('year_month', isEqualTo: selectedMonth)
          .get();
  final stockBalance = stockSnap.docs.fold<double>(
    0,
    (sum, doc) =>
        sum + ((doc.data()['evaluation_amount'] ?? 0) as num).toDouble(),
  );

  // 4. 연금 총 평가액
  final pensionSnap =
      await firestore
          .collection('monthly_pension_balance')
          .where('year_month', isEqualTo: selectedMonth)
          .get();
  final pensionBalance = pensionSnap.docs.fold<double>(
    0,
    (sum, doc) =>
        sum + ((doc.data()['evaluation_amount'] ?? 0) as num).toDouble(),
  );

  return DashboardSummary(
    yearMonth: selectedMonth,
    totalInvested: totalInvested,
    bankBalance: bankBalance,
    stockBalance: stockBalance,
    pensionBalance: pensionBalance,
  );
}
