import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/investment.dart';
import '../../providers/investment_provider.dart';
import '../widgets/investment_dialog.dart';

class InvestmentScreen extends ConsumerWidget {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentState = ref.watch(investmentNotifierProvider);
    final currencyFormatter = NumberFormat('#,###', 'ko_KR');
    final dateFormatter = DateFormat('yyyy.MM.dd');

    return Scaffold(
      appBar: AppBar(title: const Text('투자 내역 관리')),
      body: investmentState.when(
        data: (investments) {
          final totalAmount = investments.fold<double>(
            0,
            (sum, item) => sum + item.amount,
          );

          return Column(
            children: [
              // 상단 요약 카드 (총 투자금)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '총 투자금액',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${currencyFormatter.format(totalAmount)} 원',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),

              // 내역 리스트 (카드 형태)
              Expanded(
                child: investments.isEmpty
                    ? const Center(
                        child: Text(
                          '등록된 투자 내역이 없습니다.\n하단의 + 버튼을 눌러 추가해 보세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: investments.length,
                        itemBuilder: (context, index) {
                          final item = investments[index];
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  // 투자 정보 (설명, 날짜)
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
                                        if (item.createdAt != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            dateFormatter
                                                .format(item.createdAt!),
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // 투자 금액
                                  Text(
                                    '${currencyFormatter.format(item.amount)} 원',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // 수정 & 삭제 버튼
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 20),
                                    color: Colors.grey.shade700,
                                    onPressed: () =>
                                        _showEditDialog(context, item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 20),
                                    color: Colors.red.shade400,
                                    onPressed: () =>
                                        _confirmDelete(context, ref, item),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text('데이터를 불러오는 중 오류가 발생했습니다:\n$e'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const InvestmentDialog(),
    );
  }

  void _showEditDialog(BuildContext context, Investment investment) {
    showDialog(
      context: context,
      builder: (_) => InvestmentDialog(initialData: investment),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Investment investment,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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