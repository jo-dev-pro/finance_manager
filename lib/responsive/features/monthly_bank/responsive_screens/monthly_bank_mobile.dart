import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_bank_balance_provider.dart';

class MonthlyBankMobileScreen extends ConsumerWidget {
  final String? initialYearMonth;

  const MonthlyBankMobileScreen({super.key, this.initialYearMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final targetMonth = selectedMonth ?? initialYearMonth;

    return Scaffold(
      appBar: AppBar(title: const Text('월말 잔액 관리 (조회 전용)')),
      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('기준월 정보를 불러올 수 없습니다: $err')),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 월말 잔액 데이터가 없습니다.'));
          }

          final activeCurrentMonth = (targetMonth != null && months.contains(targetMonth))
              ? targetMonth
              : months.first;

          if (selectedMonth == null || !months.contains(selectedMonth)) {
            Future.microtask(() {
              ref.read(selectedYearMonthProvider.notifier).select(activeCurrentMonth);
            });
          }

          final balancesAsync = ref.watch(
            monthlyBankBalanceNotifierProvider(activeCurrentMonth),
          );
          final accountsAsync = ref.watch(accountNotifierProvider);
          final accountNamesAsync = ref.watch(accountNameNotifierProvider);

          return Column(
            children: [
              _buildMonthSelectorHeader(context, ref, months, activeCurrentMonth),
              Expanded(
                child: balancesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(child: Text('$activeCurrentMonth에 등록된 월말 은행 데이터가 없습니다.'));
                    }

                    final accounts = accountsAsync.value ?? [];
                    final accountNames = accountNamesAsync.value ?? [];

                    final accountMap = {for (var a in accounts) a.id!: a};
                    final accountNameMap = {for (var an in accountNames) an.id: an};

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(
                          monthlyBankBalanceNotifierProvider(activeCurrentMonth),
                        );
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final balanceItem = items[index];

                          final matchedAccount = accountMap[balanceItem.accountId];
                          final institution = matchedAccount?.financialInstitution ?? '기타 금융기관';
                          final nameObj = matchedAccount != null
                              ? accountNameMap[matchedAccount.accountNameId]
                              : null;
                          final accountName = nameObj?.accountName ?? '일반계좌';
                          final String? logoUrl = matchedAccount?.logoUrl;
                          final String? accountNumber = matchedAccount?.accountNumber;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              elevation: 1.5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey.shade100,
                                      backgroundImage: logoUrl != null && logoUrl.isNotEmpty
                                          ? NetworkImage(logoUrl)
                                          : null,
                                      child: (logoUrl == null || logoUrl.isEmpty)
                                          ? Icon(Icons.account_balance, color: Colors.blue.shade700)
                                          : null,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  accountName,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  balanceItem.yearMonth,
                                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$institution${accountNumber != null && accountNumber.isNotEmpty ? ' | $accountNumber' : ''}',
                                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // 모바일에서는 수정/삭제 버튼 배제 (조회 전용)
                                    Text(
                                      balanceItem.balance.toWon(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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

  Widget _buildMonthSelectorHeader(BuildContext context, WidgetRef ref, List<String> months, String currentMonth) {
    final currentIndex = months.indexOf(currentMonth);
    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: (currentIndex >= 0 && currentIndex < months.length - 1)
                ? () => ref.read(selectedYearMonthProvider.notifier).select(months[currentIndex + 1])
                : null,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: months.contains(currentMonth) ? currentMonth : months.first,
              items: months.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
              onChanged: (val) {
                if (val != null) ref.read(selectedYearMonthProvider.notifier).select(val);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentIndex > 0
                ? () => ref.read(selectedYearMonthProvider.notifier).select(months[currentIndex - 1])
                : null,
          ),
        ],
      ),
    );
  }
}