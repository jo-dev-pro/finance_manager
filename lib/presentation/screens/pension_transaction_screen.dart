import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../providers/account_provider.dart';
import '../../providers/pension_product_provider.dart';
import '../../providers/pension_transaction_provider.dart';
import '../widgets/pension_transaction_form_dialog.dart';

class PensionTransactionScreen extends ConsumerWidget {
  const PensionTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(pensionTransactionNotifierProvider);
    final accountsAsync = ref.watch(accountNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);
    final currencyFormatter = NumberFormat('#,##0', 'ko_KR');

    return Scaffold(
      appBar: AppBar(title: const Text('연금 거래내역 관리')),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류 발생: $err')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('등록된 거래 내역이 없습니다.'));
          }

          final accounts = accountsAsync.value ?? [];
          final products = productsAsync.value ?? [];

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = transactions[index];
              final isIncome =
                  item.transactionType == '입금' || item.transactionType == '매수';

              final matchedAccount = accounts.firstWhereOrNull(
                (a) => a.id == item.accountId,
              );
              final matchedProduct = products.firstWhereOrNull(
                (p) => p.id == item.productId,
              );

              final accountName = matchedAccount?.accountName ?? item.accountId;
              final institution =
                  matchedAccount?.financialInstitution ??
                  item.financialInstitution ??
                  '금융사 미지정';
              final productName = matchedProduct?.productName ?? '상품 미지정';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 4,
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isIncome ? Colors.blue.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.transactionType,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isIncome
                                  ? Colors.blue.shade700
                                  : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      accountName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$institution | $productName',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      if (item.memo != null && item.memo!.isNotEmpty)
                        Text(
                          '메모: ${item.memo}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        item.transactionDate,
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                trailing: Text(
                  '${currencyFormatter.format(item.amount)} 원',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.blue : Colors.red,
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => PensionTransactionFormDialog(transaction: item),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const PensionTransactionFormDialog(),
          );
        },
      ),
    );
  }
}
