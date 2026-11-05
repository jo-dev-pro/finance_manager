// lib/responsive/features/bank/responsive_screens/bank_desktop.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router_path.dart';
import '../../../../providers/bank/bank_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../scaffold/widgets/common_desktop_container.dart';
import 'widgets/bank_common_widgets.dart';

class BankDesktopScreen extends ConsumerStatefulWidget {
  const BankDesktopScreen({super.key});

  @override
  ConsumerState<BankDesktopScreen> createState() => _BankDesktopScreenState();
}

class _BankDesktopScreenState extends ConsumerState<BankDesktopScreen> {
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
        title: const Text('은행 자산 현황 (데스크톱)'),
        elevation: 0,
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

          return DesktopContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildMonthSelectorHeader(context, ref, months, activeCurrentMonth),
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
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildTotalBankAssetCard(totalCurrentBalance, totalDiffFromLastMonth),
                              const SizedBox(height: 24),
                              const Text('계좌별 잔액', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              if (items.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(child: Text('등록된 은행 계좌/자산 내역이 없습니다.')),
                                )
                              else
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    mainAxisExtent: 140,
                                  ),
                                  itemCount: items.length,
                                  itemBuilder: (context, index) => buildBankTile(items[index]),
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
}