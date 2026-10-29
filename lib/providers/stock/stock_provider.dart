import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/account/account.dart';
import '../account/account_provider.dart';
import '../monthly_data/monthly_stock_balance_provider.dart';

part 'stock_provider.g.dart';

class StockAccountItem {
  final Account account;
  final double currentBalance;
  final double diffFromLastMonth;

  StockAccountItem({
    required this.account,
    required this.currentBalance,
    required this.diffFromLastMonth,
  });
}

@Riverpod(keepAlive: true)
Future<List<StockAccountItem>> stockScreenData(
  StockScreenDataRef ref, {
  required String currentYearMonth,
  required String lastYearMonth,
}) async {
  // 1. 전체 계좌 목록 불러오기
  final accounts = await ref.watch(accountNotifierProvider.future);

  // 2. 현재 월과 직전 월의 주식 월말 잔액 데이터 불러오기
  final currentBalances = await ref.watch(
      monthlyStockBalanceNotifierProvider(currentYearMonth).future);
  final lastBalances = await ref.watch(
      monthlyStockBalanceNotifierProvider(lastYearMonth).future);

  // 3. 주식 유형 계좌('주식')만 필터링하거나 전체 계좌에 대해 매핑
  // (필요에 따라 .where((account) => account.accountType == '주식') 등으로 필터링 가능)
  return accounts.map((account) {
    // 해당 계좌의 당월 주식 평가액 총합
    final currentTotal = currentBalances
        .where((b) => b.accountId == account.id)
        .fold<double>(0.0, (sum, b) => sum + b.balance);

    // 해당 계좌의 직전 월 주식 평가액 총합
    final lastTotal = lastBalances
        .where((b) => b.accountId == account.id)
        .fold<double>(0.0, (sum, b) => sum + b.balance);

    final diffFromLastMonth = currentTotal - lastTotal;

    return StockAccountItem(
      account: account,
      currentBalance: currentTotal,
      diffFromLastMonth: diffFromLastMonth,
    );
  }).toList();
}