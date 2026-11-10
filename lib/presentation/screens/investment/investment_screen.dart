import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/edit_delete_button.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../core/widgets/summary_card.dart';
import '../../../models/investment/investment.dart';
import '../../../providers/investment/investment_provider.dart';
import 'widget/investment_dialog.dart';

class InvestmentScreen extends ConsumerWidget {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentState = ref.watch(investmentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('투자 내역 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 25),
            color: Colors.grey.shade700,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showAddDialog(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: investmentState.when(
        data: (investments) {
          final totalAmount = investments.fold<double>(
            0,
            (sum, item) => sum + item.amount,
          );

          return MainConstrainedBox(
            child: Column(
              children: [
                SummaryCard(
                  title: '총 투자금액',
                  mainAmountText: totalAmount.toWon(),
                  margin: const EdgeInsets.all(16),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child:
                      investments.isEmpty
                          ? const Center(
                            child: Text(
                              '등록된 투자 내역이 없습니다.\n하단의 + 버튼을 눌러 추가해 보세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: investments.length,
                            itemBuilder: (context, index) {
                              final item = investments[index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.description,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (item.createdAt != null &&
                                                item.createdAt!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                item.createdAt!,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${item.amount.toCommaString()} 원',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      EditDeleteButtons(
                                        onEdit:
                                            () =>
                                                _showEditDialog(context, item),
                                        onDelete:
                                            () => _confirmDelete(
                                              context,
                                              ref,
                                              item,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다:\n$e')),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const InvestmentDialog(),
    );
  }

  void _showEditDialog(BuildContext context, Investment investment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => InvestmentDialog(initialData: investment),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Investment investment,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('삭제 확인'),
            content: Text('\'${investment.description}\' 내역을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (investment.id != null) {
                    ref
                        .read(investmentNotifierProvider.notifier)
                        .deleteInvestment(investment.id!);
                  }
                  Navigator.of(ctx).pop();
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
