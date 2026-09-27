import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/account.dart';
import '../models/account_name.dart';
import 'account_provider.dart';
import 'account_name_provider.dart';
import 'monthly_bank_balance_provider.dart';

part 'bank_provider.g.dart';

class BankAccountItem {
  final Account account;
  final String productName;
  final double currentBalance;
  final double diffFromLastMonth;

  BankAccountItem({
    required this.account,
    required this.productName,
    required this.currentBalance,
    required this.diffFromLastMonth,
  });
}

@riverpod
Future<List<BankAccountItem>> bankScreenData(
  ref, {
  required String currentYearMonth,
  required String lastYearMonth,
}) async {
  final accounts = await ref.watch(accountNotifierProvider.future);
  final accountNames = await ref.watch(accountNameNotifierProvider.future);

  final currentBalances = await ref.watch(
    monthlyBankBalanceNotifierProvider(currentYearMonth).future,
  );
  final lastBalances = await ref.watch(
    monthlyBankBalanceNotifierProvider(lastYearMonth).future,
  );

  return accounts.map<BankAccountItem>((account) {
    // 1. where 결과 리스트 추출
    final matchedList = accountNames.where((an) => an.id == account.accountNameId);

    // 2. isEmpty 체크 후 안전하게 first 가져오기 (확장 메서드 미사용)
    final AccountName? matchedAccountName =
        matchedList.isNotEmpty ? matchedList.first : null;

    final displayName = matchedAccountName?.accountName ?? '이름 없는 계좌';

    final currentList = currentBalances.where((b) => b.accountId == account.id);
    final lastList = lastBalances.where((b) => b.accountId == account.id);

    final currentBalance =
        currentList.isNotEmpty ? currentList.first.balance : 0.0;
    final lastBalance = lastList.isNotEmpty ? lastList.first.balance : 0.0;
    final diffFromLastMonth = currentBalance - lastBalance;

    return BankAccountItem(
      account: account,
      productName: displayName,
      currentBalance: currentBalance,
      diffFromLastMonth: diffFromLastMonth,
    );
  }).toList();
}