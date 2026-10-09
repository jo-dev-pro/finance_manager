import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/pension/pension_transaction.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/pension/pension_transaction_provider.dart';
import '../../../../providers/pension/pension_transaction_type_provider.dart';
import 'widget/pension_transaction_dialog.dart';

class PensionTransactionScreen extends ConsumerStatefulWidget {
  const PensionTransactionScreen({super.key});

  @override
  ConsumerState<PensionTransactionScreen> createState() =>
      _PensionTransactionScreenState();
}

class _PensionTransactionScreenState
    extends ConsumerState<PensionTransactionScreen> {
  String? _selectedAccountId; // 필터링용 계좌 ID (null일 경우 전체 조회)

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(pensionTransactionNotifierProvider);
    final typesAsync = ref.watch(pensionTransactionTypeNotifierProvider);
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('연금 거래내역'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const PensionTransactionDialog(),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 1. 계좌 선택 상단 필터
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: accountsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => const SizedBox.shrink(),
              data: (accounts) {
                final pensionAccounts = accounts
                    .where((a) => a.accountType.toUpperCase() == '연금')
                    .toList();
                final accountNames = accountNamesAsync.value ?? [];
                final accountNameMap = {
                  for (var an in accountNames) an.id: an,
                };

                return DropdownButtonFormField<String?>(
                  initialValue: _selectedAccountId,
                  decoration: const InputDecoration(
                    labelText: '계좌 필터',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('전체 계좌 보기'),
                    ),
                    ...pensionAccounts.map((acc) {
                      final matchedName = accountNameMap[acc.accountNameId];
                      final displayName = matchedName?.accountName ?? '계좌';
                      return DropdownMenuItem<String?>(
                        value: acc.id,
                        child: Text(
                          '${acc.financialInstitution} - $displayName',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedAccountId = val;
                    });
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),

          // 2. 거래 내역 리스트 (잔액 계산 포함)
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('오류 발생: $err')),
              data: (transactions) {
                // 선택된 계좌 필터링
                final filteredTx = _selectedAccountId == null
                    ? transactions
                    : transactions
                        .where((t) => t.accountId == _selectedAccountId)
                        .toList();

                if (filteredTx.isEmpty) {
                  return const Center(child: Text('등록된 거래 내역이 없습니다.'));
                }

                final types = typesAsync.value ?? [];
                final Map<String, String> signMap = {
                  for (var t in types) t.name: t.amountSign,
                };

                // 누적 잔액 계산을 위해 날짜/ID 기준 오름차순 정렬
                final sortedAsc = List<PensionTransaction>.from(filteredTx)
                  ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

                double currentBalance = 0.0;
                final List<_TransactionWithBalance> itemsWithBalance = [];

                for (final tx in sortedAsc) {
                  final sign = signMap[tx.transactionType] ?? '+';
                  final signedAmount = sign == '-' ? -tx.amount : tx.amount;
                  currentBalance += signedAmount;

                  itemsWithBalance.add(
                    _TransactionWithBalance(
                      transaction: tx,
                      signedAmount: signedAmount,
                      balance: currentBalance,
                    ),
                  );
                }

                // 최신순으로 화면에 표시하기 위해 역순 정렬
                final displayList = itemsWithBalance.reversed.toList();

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = displayList[index];
                    final tx = item.transaction;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => PensionTransactionDialog(transaction: tx),
                      ),
                      title: Text(
                        tx.transactionType,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        '${tx.transactionDate}${tx.memo != null && tx.memo!.isNotEmpty ? " • ${tx.memo}" : ""}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 부호 및 색상이 적용된 거래 금액 (+ / -)
                          item.signedAmount.toSignedPriceText(
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // 계산된 누적 잔액 표시
                          Text(
                            '잔액 ${item.balance.toWon()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionWithBalance {
  final PensionTransaction transaction;
  final double signedAmount;
  final double balance;

  _TransactionWithBalance({
    required this.transaction,
    required this.signedAmount,
    required this.balance,
  });
}