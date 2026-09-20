import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/bank_provider.dart';
import 'monthly_bank_balance_screen.dart';

class BankScreen extends ConsumerWidget {
  const BankScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat('#,###', 'ko_KR');

    // 현재 기준 연월(YYYY-MM) 및 전월 계산
    final now = DateTime.now();
    final currentYearMonth = DateFormat('yyyy-MM').format(now);
    final lastYearMonth = DateFormat('yyyy-MM').format(DateTime(now.year, now.month - 1));

    // Supabase 데이터 조회를 위한 Provider 구독
    final bankDataAsync = ref.watch(
      bankScreenDataProvider(
        currentYearMonth: currentYearMonth,
        lastYearMonth: lastYearMonth,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('은행 자산 현황'),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MonthlyBankBalanceScreen()),
              );
            },
            icon: const Icon(Icons.calendar_month, size: 18),
            label: const Text('월말은행'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: bankDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('계좌 정보를 불러오지 못했습니다:\n$err', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(bankScreenDataProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (rawItems) {
          // 계좌구분(type)이 '은행' 또는 'BANK'인 항목만 필터링
          final items = rawItems.where((item) {
            final type = item.account.accountType.toUpperCase();
            return type == '은행';
          }).toList();

          // 은행 전체 총 금액 및 총 전월 대비 금액 계산 (필터링된 목록 기준)
          final double totalCurrentBalance = items.fold(0, (sum, i) => sum + i.currentBalance);
          final double totalDiffFromLastMonth = items.fold(0, (sum, i) => sum + i.diffFromLastMonth);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;

              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(bankScreenDataProvider),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상단 요약 박스 (전체 금액 & 전월대비)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isDesktop ? 28 : 20),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('은행 계좌 전체 금액', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 6),
                                Text(
                                  '${currencyFormatter.format(totalCurrentBalance)} 원',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isDesktop ? 32 : 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Text('전월 대비: ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    Text(
                                      '${totalDiffFromLastMonth >= 0 ? '+' : ''}${currencyFormatter.format(totalDiffFromLastMonth)} 원',
                                      style: TextStyle(
                                        color: totalDiffFromLastMonth >= 0 ? Colors.greenAccent : Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 하단 계좌별 리스트
                          const Text('계좌별 잔액', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),

                          if (items.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: Text('등록된 은행 계좌가 없습니다.')),
                            )
                          else if (isDesktop)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3.5,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, index) => _buildBankTile(items[index], currencyFormatter),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildBankTile(items[index], currencyFormatter),
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
    );
  }

  Widget _buildBankTile(BankAccountItem item, NumberFormat currencyFormatter) {
    final account = item.account;
    final diff = item.diffFromLastMonth;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          backgroundImage: account.logoUrl != null ? NetworkImage(account.logoUrl!) : null,
          child: account.logoUrl == null
              ? Icon(Icons.account_balance, color: Colors.blue.shade700)
              : null,
        ),
        title: Text(
          account.accountName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(account.financialInstitution),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${currencyFormatter.format(item.currentBalance)} 원',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              '전월대비 ${diff >= 0 ? '+' : ''}${currencyFormatter.format(diff)}',
              style: TextStyle(
                fontSize: 12,
                color: diff >= 0 ? Colors.red : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}