import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/account/account.dart';
import '../../models/account/account_name.dart';
import '../account/account_provider.dart';
import '../account/account_name_provider.dart';
import '../monthly_data/monthly_bank_balance_provider.dart';

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

  final bankAccounts = accounts.where((account) {
    // 1. 기본 조건: accountType이 '은행'인 계좌
    if (account.accountType.toUpperCase() != '은행') return false;

    // 2. 계좌구분명(account_name) 매핑
    final matchedList = accountNames.where(
      (an) => an.id.toString() == account.accountNameId.toString(),
    );
    final matchedAccountName =
        matchedList.isNotEmpty ? matchedList.first : null;
    final productName = matchedAccountName?.accountName ?? '';

    // 💡 [핵심 조건]
    // A. 계좌구분이 '입출금'인 경우 무조건 리스트에 표시
    if (productName == '입출금') return true;

    // B. 입출금이 아닌 경우:
    // - 현재 '활동' 상태이거나
    // - 선택한 달(currentYearMonth) 또는 전월(lastYearMonth)에 잔액 기록이 있는 경우 표시
    final hasCurrentBalance = currentBalances.any(
      (b) => b.accountId.toString() == account.id.toString(),
    );
    final hasLastBalance = lastBalances.any(
      (b) => b.accountId.toString() == account.id.toString(),
    );

    return account.status == '활동' || hasCurrentBalance || hasLastBalance;
  }).toList();

  // 3. BankAccountItem 리스트 생성 및 반환
  return bankAccounts.map<BankAccountItem>((account) {
    final matchedList = accountNames.where(
      (an) => an.id.toString() == account.accountNameId.toString(),
    );
    final matchedAccountName =
        matchedList.isNotEmpty ? matchedList.first : null;
    final displayName = matchedAccountName?.accountName ?? '이름 없는 계좌';

    final currentList = currentBalances.where(
      (b) => b.accountId.toString() == account.id.toString(),
    );
    final lastList = lastBalances.where(
      (b) => b.accountId.toString() == account.id.toString(),
    );

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