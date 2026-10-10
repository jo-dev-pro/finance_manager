import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/pension/pension_transaction.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';
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
    final productsAsync = ref.watch(pensionProductNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('연금 거래내역')),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => showDialog(
              context: context,
              builder: (_) => const PensionTransactionDialog(),
            ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 1. 계좌 선택 상단 필터
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: accountsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => const SizedBox.shrink(),
              data: (accounts) {
                final pensionAccounts =
                    accounts
                        .where((a) => a.accountType.toUpperCase() == '연금')
                        .toList();
                final accountNames = accountNamesAsync.value ?? [];
                final accountNameMap = {for (var an in accountNames) an.id: an};

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

          // 2. 거래 내역 리스트 (계좌별 잔액 계산 포함)
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('오류 발생: $err')),
              data: (transactions) {
                // 선택된 계좌 필터링
                final filteredTx =
                    _selectedAccountId == null
                        ? transactions
                        : transactions
                            .where((t) => t.accountId == _selectedAccountId)
                            .toList();

                if (filteredTx.isEmpty) {
                  return const Center(child: Text('등록된 거래 내역이 없습니다.'));
                }

                final types = typesAsync.value ?? [];
                final accounts = accountsAsync.value ?? [];
                final accountNames = accountNamesAsync.value ?? [];
                final accountNameMap = {for (var an in accountNames) an.id: an};

                // 💡 계좌 ID -> 표시용 계좌명 맵 생성 (예: "신한 - 연금저축")
                final Map<String, String> accountDisplayMap = {
                  for (var acc in accounts)
                    acc.id!: '${acc.financialInstitution} - ${accountNameMap[acc.accountNameId]?.accountName ?? '계좌'}',
                };

                // 💡 1. 거래구분 ID -> 이름 맵핑
                final Map<String, String> typeNameMap = {
                  for (var t in types) t.id ?? '': t.typeName,
                };

                // 💡 2. 거래구분 ID -> amountSign ('PLUS' 또는 'MINUS') 맵핑
                final Map<String, String> signMap = {
                  for (var t in types) t.id ?? '': t.amountSign,
                };

                // 상품 목록 맵 생성 (productId -> productName)
                final products = productsAsync.value ?? [];
                final Map<String, String> productMap = {
                  for (var p in products) p.id!: p.productName,
                };

                // 날짜 + sortOrder 오름차순으로 전체 정렬
                final sortedAsc = List<PensionTransaction>.from(filteredTx)
                  ..sort((a, b) {
                    int dateCompare = a.transactionDate.compareTo(
                      b.transactionDate,
                    );
                    if (dateCompare != 0) return dateCompare;
                    return a.sortOrder.compareTo(b.sortOrder);
                  });

                // 💡 3. 계좌별(accountId) 독립 잔액 추적 맵 및 리스트 구성
                final Map<String, double> accountBalances = {};
                final List<_TransactionWithBalance> itemsWithBalance = [];

                for (final tx in sortedAsc) {
                  double currentBalance = accountBalances[tx.accountId] ?? 0.0;

                  final sign = signMap[tx.transactionTypeId] ?? 'PLUS';
                  final signedAmount =
                      (sign == 'MINUS') ? -tx.amount : tx.amount;

                  currentBalance += signedAmount;
                  accountBalances[tx.accountId] = currentBalance;

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

                    final typeName = typeNameMap[tx.transactionTypeId] ?? '기타';

                    final productName =
                        (tx.productId != null &&
                                productMap.containsKey(tx.productId))
                            ? productMap[tx.productId]!
                            : null;

                    // 💡 전체 계좌 보기일 때는 subtitle 맨 앞에 계좌명 추가
                    final List<String> subtitleParts = [];
                    if (_selectedAccountId == null) {
                      final accName = accountDisplayMap[tx.accountId] ?? '알 수 없는 계좌';
                      subtitleParts.add(accName);
                    }

                    if (productName != null) {
                      subtitleParts.add(productName);
                    }
                    subtitleParts.add(tx.transactionDate);
                    if (tx.memo != null && tx.memo!.isNotEmpty) {
                      subtitleParts.add(tx.memo!);
                    }
                    final subtitleText = subtitleParts.join(' • ');

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      onTap:
                          () => showDialog(
                            context: context,
                            builder:
                                (_) =>
                                    PensionTransactionDialog(transaction: tx),
                          ),
                      title: Text(
                        typeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        subtitleText,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          item.signedAmount.toSignedPriceText(
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
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