import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/providers/firestore_provider.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<List<String>> availableYearMonths(AvailableYearMonthsRef ref) async {
  final firestore = ref.watch(firestoreProvider);

  final bankSnap = await firestore.collection('monthly_bank_balance').get();
  final stockSnap = await firestore.collection('monthly_stock_balance').get();
  final pensionSnap = await firestore.collection('monthly_pension_balance').get();

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

  final sortedList = months.toList()..sort((a, b) => b.compareTo(a));
  return sortedList;
}

@riverpod
class SelectedYearMonth extends _$SelectedYearMonth {
  @override
  String? build() => null;

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
}

@riverpod
Future<DashboardSummary> dashboardSummary(DashboardSummaryRef ref) async {
  final selectedMonth = ref.watch(selectedYearMonthProvider);
  if (selectedMonth == null) {
    return DashboardSummary(
      yearMonth: '',
      totalInvested: 0,
      bankBalance: 0,
      stockBalance: 0,
      pensionBalance: 0,
    );
  }

  final firestore = ref.watch(firestoreProvider);

  // 1. 총 투자원금
  final investSnap = await firestore.collection('investment').get();
  final totalInvested = investSnap.docs.fold<double>(
    0,
    (sum, doc) => sum + ((doc.data()['amount'] ?? 0) as num).toDouble(),
  );

  // 2. 은행 총 잔액
  final bankSnap = await firestore
      .collection('monthly_bank_balance')
      .where('year_month', isEqualTo: selectedMonth)
      .get();
  final bankBalance = bankSnap.docs.fold<double>(
    0,
    (sum, doc) => sum + ((doc.data()['balance'] ?? 0) as num).toDouble(),
  );

  // 3. 증권 총 평가액
  final stockSnap = await firestore
      .collection('monthly_stock_balance')
      .where('year_month', isEqualTo: selectedMonth)
      .get();
  final stockBalance = stockSnap.docs.fold<double>(
    0,
    (sum, doc) =>
        sum + ((doc.data()['evaluation_amount'] ?? 0) as num).toDouble(),
  );

  // 4. 연금 총 평가액
  final pensionSnap = await firestore
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