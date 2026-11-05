// lib/responsive/features/investment/responsive_screens/investment_mobile.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../providers/investment/investment_provider.dart';

class InvestmentMobileScreen extends ConsumerWidget {
  const InvestmentMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentState = ref.watch(investmentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('투자 내역 관리 (모바일 - 조회 전용)'),
        // 모바일은 입력 기능이 없으므로 actions(추가 버튼)를 배치하지 않음
      ),
      body: investmentState.when(
        data: (investments) {
          final totalAmount = investments.fold<double>(
            0,
            (sum, item) => sum + item.amount,
          );

          return Column(
            children: [
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
                      '${totalAmount.toCommaString()} 원',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: investments.isEmpty
                    ? const Center(
                      child: Text(
                        '등록된 투자 내역이 없습니다.',
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
                                // 금액만 표시하고 수정/삭제 버튼은 제외
                                Text(
                                  '${item.amount.toCommaString()} 원',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blueAccent,
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다:\n$e')),
      ),
    );
  }
}