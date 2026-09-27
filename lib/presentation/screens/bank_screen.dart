import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_router_path.dart';
import '../../providers/bank_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../core/utils/number_formatter.dart';

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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthSelectorHeader(
                context,
                ref,
                months,
                activeCurrentMonth,
              ),

              Expanded(
                child: bankDataAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (err, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '계좌 정보를 불러오지 못했습니다:\n$err',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed:
                                  () => ref.invalidate(bankScreenDataProvider),
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      ),
                  data: (rawItems) {
                    final items =
                        rawItems.where((item) {
                          final type = item.account.accountType.toUpperCase();
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

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 900;

                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(availableYearMonthsProvider);
                            ref.invalidate(bankScreenDataProvider);
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1200,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo.shade600,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '은행 계좌 전체 금액',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            totalCurrentBalance.toWon(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.18),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  '전월 대비',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              totalDiffFromLastMonth
                                                  .toSignedPriceText(
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    positiveColor: const Color(
                                                      0xFFFF8A80,
                                                    ),
                                                    negativeColor: const Color(
                                                      0xFF82B1FF,
                                                    ),
                                                    zeroColor: Colors.white,
                                                  ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    const Text(
                                      '계좌별 잔액',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    if (items.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 32,
                                        ),
                                        child: Center(
                                          child: Text('등록된 은행 계좌/자산 내역이 없습니다.'),
                                        ),
                                      )
                                    else if (isDesktop)
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              childAspectRatio: 3.5,
                                              crossAxisSpacing: 12,
                                              mainAxisSpacing: 12,
                                            ),
                                        itemCount: items.length,
                                        itemBuilder:
                                            (context, index) =>
                                                _buildBankTile(items[index]),
                                      )
                                    else
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: items.length,
                                        itemBuilder:
                                            (context, index) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: _buildBankTile(
                                                items[index],
                                              ),
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildMonthSelectorHeader(
    BuildContext context,
    WidgetRef ref,
    List<String> months,
    String currentMonth,
  ) {
    final currentIndex = months.indexOf(currentMonth);

    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                currentIndex < months.length - 1
                    ? () {
                      ref
                          .read(selectedYearMonthProvider.notifier)
                          .select(months[currentIndex + 1]);
                    }
                    : null,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:
                  months.contains(currentMonth) ? currentMonth : months.first,
              icon: const Icon(Icons.arrow_drop_down),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              items:
                  months.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(
                        month,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newMonth) {
                if (newMonth != null) {
                  ref.read(selectedYearMonthProvider.notifier).select(newMonth);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                currentIndex > 0
                    ? () {
                      ref
                          .read(selectedYearMonthProvider.notifier)
                          .select(months[currentIndex - 1]);
                    }
                    : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBankTile(BankAccountItem item) {
    final account = item.account;
    final diff = item.diffFromLastMonth;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage:
              account.logoUrl != null ? NetworkImage(account.logoUrl!) : null,
          child:
              account.logoUrl == null
                  ? Icon(Icons.account_balance, color: Colors.blue.shade700)
                  : null,
        ),
        title: Text(
          item.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(account.financialInstitution),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.currentBalance.toWon(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '전월대비 ',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                diff.toSignedPriceText(
                  style: const TextStyle(fontSize: 12),
                  positiveColor: Colors.red,
                  negativeColor: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}