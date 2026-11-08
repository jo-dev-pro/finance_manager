import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router_path.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../core/widgets/month_selector_header.dart';
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
                // 💡 공통 위젯 호출
                MonthSelectorHeader(
                  months: months,
                  currentMonth: activeCurrentMonth,
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
                                    () =>
                                        ref.invalidate(bankScreenDataProvider),
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
                                                color: Colors.white.withValues(
                                                  alpha: 0.18,
                                                ),
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
                                                    fontWeight: FontWeight.bold,
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
                                      fontSize: 20,
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
                                            mainAxisExtent:
                                                140, // 💡 중요: 카드 세로 높이를 140px로 고정하여 세로 공간 축소
                                          ),
                                      itemCount: items.length,
                                      itemBuilder:
                                          (context, index) =>
                                              _buildBankTile(items[index]),
                                    ),
                                ],
                              ),
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
              items:
                  months.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(month),
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
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 1. 로고 아바타
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage:
                  account.logoUrl != null
                      ? NetworkImage(account.logoUrl!)
                      : null,
              child:
                  account.logoUrl == null
                      ? Icon(Icons.account_balance, color: Colors.blue.shade700)
                      : null,
            ),
            const SizedBox(width: 12),

            // 2. 텍스트 영역 (계좌명, 금융기관 | 계좌번호)
            // 💡 Expanded와 overflow 처리를 통해 좁은 화면에서도 세로로 길어지지 않게 방지
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${account.financialInstitution}${account.accountNumber != null && account.accountNumber!.isNotEmpty ? ' | ${account.accountNumber}' : ''}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 3. 금액 및 전월 대비 영역 (오른쪽 고정)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.currentBalance.toWon(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '전월대비 ',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    diff.toSignedPriceText(
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
