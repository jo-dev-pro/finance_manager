import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router_path.dart';
import '../../../../providers/bank/bank_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../core/utils/number_formatter.dart';
import 'widgets/bank_common_widgets.dart';

class BankMobileScreen extends ConsumerStatefulWidget {
  const BankMobileScreen({super.key});

  @override
  ConsumerState<BankMobileScreen> createState() => _BankMobileScreenState();
}

class _BankMobileScreenState extends ConsumerState<BankMobileScreen> {
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
  Widget build(BuildContext context) {
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('은행 자산 현황'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.push(
                AppRoutePath.monthlyBankBalance,
                extra: selectedMonth,
              );
            },
            icon: const Icon(Icons.calendar_month, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('기준월 정보를 불러오지 못했습니다: $err')),
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
              ref.read(selectedYearMonthProvider.notifier).select(activeCurrentMonth);
            });
          }

          final lastYearMonth = _getLastYearMonth(activeCurrentMonth);
          final bankDataAsync = ref.watch(
            bankScreenDataProvider(
              currentYearMonth: activeCurrentMonth,
              lastYearMonth: lastYearMonth,
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 월 선택 헤더
              Container(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: months.indexOf(activeCurrentMonth) < months.length - 1
                          ? () => ref.read(selectedYearMonthProvider.notifier).select(months[months.indexOf(activeCurrentMonth) + 1])
                          : null,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: months.contains(activeCurrentMonth) ? activeCurrentMonth : months.first,
                        items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (val) {
                          if (val != null) ref.read(selectedYearMonthProvider.notifier).select(val);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: months.indexOf(activeCurrentMonth) > 0
                          ? () => ref.read(selectedYearMonthProvider.notifier).select(months[months.indexOf(activeCurrentMonth) - 1])
                          : null,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: bankDataAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('계좌 정보를 불러오지 못했습니다: $err')),
                  data: (rawItems) {
                    final items = rawItems.where((item) {
                      return item.account.accountType.toUpperCase() == '은행';
                    }).toList();

                    final double totalCurrentBalance = items.fold(0, (sum, i) => sum + i.currentBalance);
                    final double totalDiffFromLastMonth = items.fold(0, (sum, i) => sum + i.diffFromLastMonth);

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(availableYearMonthsProvider);
                        ref.invalidate(bankScreenDataProvider);
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 총 은행 자산 요약 카드
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade600,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('은행 계좌 전체 금액', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text(totalCurrentBalance.toWon(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Text('전월 대비', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      const SizedBox(width: 8),
                                      totalDiffFromLastMonth.toSignedPriceText(
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        positiveColor: const Color(0xFFFF8A80),
                                        negativeColor: const Color(0xFF82B1FF),
                                        zeroColor: Colors.white,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text('계좌별 잔액', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            if (items.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Center(child: Text('등록된 은행 계좌/자산 내역이 없습니다.')),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: SizedBox(
                                      height: 130,
                                      child: buildBankTile(items[index]),
                                    ),
                                  );
                                },
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
      ),
    );
  }
}