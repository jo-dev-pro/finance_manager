import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/account.dart';
import '../models/monthly_bank_balance.dart';
import 'account_provider.dart';
import 'monthly_bank_balance_provider.dart';

part 'bank_provider.g.dart';

// 은행 메뉴에서 사용
class BankAccountItem {
  final Account account;
  final double currentBalance;
  final double diffFromLastMonth;

  BankAccountItem({
    required this.account,
    required this.currentBalance,
    required this.diffFromLastMonth,
  });
}

@riverpod
Future<List<BankAccountItem>> bankScreenData(
  BankScreenDataRef ref, {
  required String currentYearMonth,
  required String lastYearMonth,
}) async {
  final accounts = await ref.watch(accountNotifierProvider.future);

  final currentBalances = await ref.watch(
      monthlyBankBalanceNotifierProvider(currentYearMonth).future);
  final lastBalances = await ref.watch(
      monthlyBankBalanceNotifierProvider(lastYearMonth).future);

  return accounts.map((account) {
    final current = currentBalances.firstWhere(
      (b) => b.accountName == account.accountName,
      orElse: () => const MonthlyBankBalance(
        yearMonth: '',
        financialInstitution: '',
        accountName: '',
        balance: 0,
      ),
    );

    final last = lastBalances.firstWhere(
      (b) => b.accountName == account.accountName,
      orElse: () => const MonthlyBankBalance(
        yearMonth: '',
        financialInstitution: '',
        accountName: '',
        balance: 0,
      ),
    );

    final currentBalance = current.balance;
    final diffFromLastMonth = currentBalance - last.balance;

    return BankAccountItem(
      account: account,
      currentBalance: currentBalance,
      diffFromLastMonth: diffFromLastMonth,
    );
  }).toList();
}