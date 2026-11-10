import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router_path.dart';
import '../../../core/widgets/account_card.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../core/widgets/month_selector_header.dart';
import '../../../core/widgets/section_title.dart'; // 💡 공통 SectionTitle 적용
import '../../../core/widgets/summary_card.dart';
import '../../../providers/bank/bank_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../core/utils/number_formatter.dart';

class BankScreen extends ConsumerWidget {
  const BankScreen({super.key});

  String _getLastYearMonth(String currentYearMonth) {
    try {
      final parts = currentYearMonth.split('-');
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);

      DateTime date = DateTime(year, month, 1);
      DateTime lastMonthDate = DateTime(date.year, date.month - 1, 1);
      return DateFormat('yyyy-MM').format(lastMonthDate);
    } catch (_) {
      return currentYearMonth;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('은행 자산 현황'),
        elevation: 0,
        scrolledUnderElevation: 0,     // 스크롤 시 그림자/색상 변화 방지
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              context.push(
                AppRoutePath.monthlyBankBalance,
                extra: selectedMonth,
              );
            },
            icon: const Icon(Icons.calendar_month, size: 18),
            label: const Text('월말은행'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '기준월 정보를 불러오지 못했습니다:\n$err',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed:
                        () => ref.invalidate(availableYearMonthsProvider),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 기준월 데이터가 없습니다.'));
          }

          final String defaultTarget = months.first;
          final String activeCurrentMonth =
              (selectedMonth != null && months.contains(selectedMonth))
                  ? selectedMonth
                  : defaultTarget;

          if (selectedMonth == null || !months.contains(selectedMonth)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(selectedYearMonthProvider.notifier)
                  .select(activeCurrentMonth);
            });
          }

          final lastYearMonth = _getLastYearMonth(activeCurrentMonth);

          final bankDataAsync = ref.watch(
            bankScreenDataProvider(
              currentYearMonth: activeCurrentMonth,
              lastYearMonth: lastYearMonth,
            ),
          );

          return MainConstrainedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonthSelectorHeader(
                  months: months,
                  currentMonth: activeCurrentMonth,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bankDataAsync.when(
                          loading:
                              () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          error: (err, _) => Text('오류: $err'),
                          data: (rawItems) {
                            final items =
                                rawItems.where((item) {
                                  final type =
                                      item.account.accountType.toUpperCase();
                                  return type == '은행';
                                }).toList();

                            final double totalCurrentBalance = items.fold(
                              0,
                              (sum, i) => sum + i.currentBalance,
                            );
                            final double totalDiffFromLastMonth = items.fold(
                              0,
                              (sum, i) => sum + i.diffFromLastMonth,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SummaryCard(
                                  title: '은행 계좌 전체 금액',
                                  mainAmountText: totalCurrentBalance.toWon(),
                                  diffFromLastMonthWidget: Row(
                                    children: [
                                      const Text(
                                        '전월 대비: ',
                                        style: TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                      totalDiffFromLastMonth.toSignedPriceText(
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        positiveColor: const Color(0xFFFF8A80),
                                        negativeColor: const Color(0xFF82B1FF),
                                        zeroColor: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SectionTitle('계좌 목록', topSpacing: 24, bottomSpacing: 12),
                            
                                if (items.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 32,
                                    ),
                                    child: Center(
                                      child: Text('등록된 은행 계좌/자산 내역이 없습니다.'),
                                    ),
                                  )
                                else
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              MediaQuery.of(
                                                        context,
                                                      ).size.width >
                                                      900
                                                  ? 2
                                                  : 1,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          mainAxisExtent: 130,
                                        ),
                                    itemCount: items.length,
                                    itemBuilder:
                                        (context, index) =>
                                            _buildBankTile(items[index]),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBankTile(BankAccountItem item) {
    final account = item.account;
    final diff = item.diffFromLastMonth;
    final logoUrl = account.logoUrl;
    final institutionText = '${account.financialInstitution}${account.accountNumber != null && account.accountNumber!.isNotEmpty ? ' | ${account.accountNumber}' : ''}';

    return AccountCard(
      logoUrl: logoUrl,
      institution: institutionText,
      accountName: item.productName,
      totalBalance: item.currentBalance,
      diffFromLastMonth: diff,
    );
  }
}