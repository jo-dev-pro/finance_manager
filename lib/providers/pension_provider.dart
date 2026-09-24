import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/account.dart';
import 'account_provider.dart';
import 'monthly_pension_balance_provider.dart';

part 'pension_provider.g.dart';

// 연금 메뉴에서 사용
class PensionAccountItem {
  final Account account;
  final double currentBalance;
  final double diffFromLastMonth;

  PensionAccountItem({
    required this.account,
    required this.currentBalance,
    required this.diffFromLastMonth,
  });
}

@riverpod
Future<List<PensionAccountItem>> pensionScreenData(
  PensionScreenDataRef ref, {
  required String currentYearMonth,
  required String lastYearMonth,
}) async {
  final accounts = await ref.watch(accountNotifierProvider.future);

  final currentBalances = await ref.watch(
      monthlyPensionBalanceNotifierProvider(currentYearMonth).future);
  final lastBalances = await ref.watch(
      monthlyPensionBalanceNotifierProvider(lastYearMonth).future);

  return accounts.map((account) {
    // 👈 b.accountName 대신 b.accountId 및 account.id 비교로 변경
    final currentTotal = currentBalances
        .where((b) => b.accountId == account.id)
        .fold<double>(0.0, (sum, b) => sum + b.evaluationAmount);

    final lastTotal = lastBalances
        .where((b) => b.accountId == account.id)
        .fold<double>(0.0, (sum, b) => sum + b.evaluationAmount);

    final diffFromLastMonth = currentTotal - lastTotal;

    return PensionAccountItem(
      account: account,
      currentBalance: currentTotal,
      diffFromLastMonth: diffFromLastMonth,
    );
  }).toList();
}