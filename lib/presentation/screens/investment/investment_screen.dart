import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/app_dialog.dart'; // 💡 공통 삭제 다이얼로그
import '../../../core/widgets/app_snackbar.dart'; // 💡 공통 스낵바
import '../../../core/widgets/edit_delete_button.dart';
import '../../../core/widgets/jtext.dart';
import '../../../core/widgets/main_appbar.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../core/widgets/summary_card.dart';
import '../../../models/investment/investment.dart';
import '../../../providers/investment/investment_provider.dart';
import 'widgets/investment_dialog.dart';

class InvestmentScreen extends ConsumerWidget {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentState = ref.watch(investmentNotifierProvider);

    return Scaffold(
      appBar: MainAppBar(
        titleText: '투자금 관리',
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showDialog(context),
            label: const Text('등록'),
          ),
        ],
      ),

      body: investmentState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다:\n$e')),
        data: (investments) {
          final totalAmount = investments.fold<double>(
            0,
            (sum, item) => sum + item.amount,
          );


          return MainConstrainedBox(
            child: Column(
              children: [
                const SizedBox(height: 16),
                SummaryCard(
                  title: '총 투자금액',
                  mainAmountText: totalAmount.toWon(),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child:
                      investments.isEmpty
                          ? const Center(
                            child: Text(
                              '등록된 투자 내역이 없습니다.\n상단의 등록 버튼을 눌러 추가해 보세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: investments.length,
                            itemBuilder: (context, index) {
                              final item = investments[index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
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
                                      SizedBox(height: 8),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          JText(
                                            item.amount.toWon(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          EditDeleteButtons(
                                            onEdit:
                                                () => _showDialog(
                                                  context,
                                                  investment:
                                                      item, // 💡 수정 모드 호출
                                                ),
                                            onDelete:
                                                () => _confirmDelete(
                                                  context,
                                                  ref,
                                                  item,
                                                ),
                                          ),
                                        ],
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
      ),
    );
  }

  // 💡 추가와 수정을 하나로 통합한 공통 다이얼로그 호출 함수
  void _showDialog(BuildContext context, {Investment? investment}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => InvestmentDialog(initialData: investment),
    );
  }

  // 💡 공통 삭제 다이얼로그 + 스낵바 + mounted 가드 적용
  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Investment investment,
  ) {
    if (investment.id == null) return;

    AppDialog.showDeleteConfirm(
      context,
      title: '삭제 확인',
      content: '\'${investment.description}\' 내역을 삭제하시겠습니까?',
      onDelete: () async {
        try {
          await ref
              .read(investmentNotifierProvider.notifier)
              .deleteInvestment(investment.id!);

          if (!context.mounted) return;
          AppSnackBar.showInfo(context, '투자 내역이 삭제되었습니다.');
        } catch (e) {
          if (!context.mounted) return;
          AppSnackBar.showError(context, '삭제 실패: $e');
        }
      },
    );
  }
}
