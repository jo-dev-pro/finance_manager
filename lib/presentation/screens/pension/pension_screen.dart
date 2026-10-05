import 'dart:math';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../models/account/account.dart';
import '../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../providers/pension/pension_provider.dart';
import '../monthly_data/monthly_pension_balance_screen.dart';
import 'pension_transaction_screen.dart';

class PensionScreen extends ConsumerStatefulWidget {
  const PensionScreen({super.key});

  @override
  ConsumerState<PensionScreen> createState() => _PensionScreenState();
}

class _PensionScreenState extends ConsumerState<PensionScreen> {
  final TransformationController _transformationController =
      TransformationController();

  final List<Color> _chartColors = [
    Colors.indigo,
    Colors.teal,
    Colors.orange,
    Colors.deepPurple,
    Colors.blue,
    Colors.pink,
  ];

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
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('연금 자산 현황'),
        elevation: 0,
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MonthlyPensionBalanceScreen(),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('월말연금'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PensionTransactionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('거래내역'),
          ),
        ],
      ),
      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '기준월 정보를 불러오지 못했습니다:\n$err',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(availableYearMonthsProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 기준월 데이터가 없습니다.'));
          }

          final activeMonths = months;
          final activeCurrentMonth =
              (selectedMonth != null && activeMonths.contains(selectedMonth))
                  ? selectedMonth
                  : activeMonths.first;

          if (selectedMonth == null || !activeMonths.contains(selectedMonth)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(selectedYearMonthProvider.notifier)
                  .select(activeCurrentMonth);
            });
          }

          final lastMonth = _getLastYearMonth(activeCurrentMonth);
          final balancesAsync = ref.watch(
            monthlyPensionBalanceNotifierProvider(activeCurrentMonth),
          );
          final lastBalancesAsync = ref.watch(
            monthlyPensionBalanceNotifierProvider(lastMonth),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthSelectorHeader(
                context,
                activeMonths,
                activeCurrentMonth,
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      balancesAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (err, stack) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '계좌 정보를 불러오지 못했습니다:\n$err',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => ref.invalidate(
                                  pensionScreenDataProvider,
                                ),
                                child: const Text('다시 시도'),
                              ),
                            ],
                          ),
                        ),
                        data: (balances) {
                          final totalBalance = balances.fold<double>(
                            0.0,
                            (sum, item) => sum + item.evaluationAmount,
                          );

                          final lastTotalBalance = lastBalancesAsync.maybeWhen(
                            data: (lastBalances) => lastBalances.fold<double>(
                              0.0,
                              (sum, item) => sum + item.evaluationAmount,
                            ),
                            orElse: () => 0.0,
                          );

                          final diffFromLastMonth =
                              totalBalance - lastTotalBalance;

                          return _buildSummaryCard(
                            totalBalance: totalBalance,
                            diffFromLastMonth: diffFromLastMonth,
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        '계좌 목록',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      balancesAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, stack) =>
                            Center(child: Text('데이터 로드 실패: $err')),
                        data: (balances) {
                          if (balances.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text('등록된 연금 계좌/자산 내역이 없습니다.'),
                              ),
                            );
                          }

                          final accounts = accountsAsync.value ?? [];
                          final accountNames = accountNamesAsync.value ?? [];

                          final Map<String, List<MonthlyPensionBalance>>
                              accountGroups = {};
                          for (var item in balances) {
                            accountGroups
                                .putIfAbsent(item.accountId, () => [])
                                .add(item);
                          }

                          final accountIds = accountGroups.keys.toList();
                          final totalBalance = balances.fold<double>(
                            0.0,
                            (sum, item) => sum + item.evaluationAmount,
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAccountGrid(
                                accountIds,
                                accountGroups,
                                accounts,
                                accountNames,
                              ),
                              const SizedBox(height: 28),
                              const Text(
                                '계좌별 평가 비중',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildPortionSection(
                                accountIds,
                                accountGroups,
                                accounts,
                                accountNames,
                                totalBalance,
                              ),
                              const SizedBox(height: 28),
                              const Text(
                                '계좌별 월말 평가액 추이',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '💡 차트를 좌우로 드래그하거나 확대/축소(Pinch Zoom)하여 전기간 데이터를 확인하세요.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildZoomableChartSection(
                                accountIds,
                                activeMonths,
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
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
            onPressed: currentIndex < months.length - 1
                ? () {
                    ref
                        .read(selectedYearMonthProvider.notifier)
                        .select(months[currentIndex + 1]);
                  }
                : null,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentMonth,
              icon: const Icon(Icons.arrow_drop_down),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              items: months.map((String month) {
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
            onPressed: currentIndex > 0
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

  Widget _buildSummaryCard({
    required double totalBalance,
    required double diffFromLastMonth,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.shade600,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '연금 자산 전체 금액',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            totalBalance.toWon(),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
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
              diffFromLastMonth.toSignedPriceText(
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
        ],
      ),
    );
  }

  Widget _buildAccountGrid(
    List<String> accountIds,
    Map<String, List<MonthlyPensionBalance>> accountGroups,
    List<Account> accounts,
    List<dynamic> accountNames,
  ) {
    final accountNameMap = {for (var an in accountNames) an.id: an};

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: accountIds.length,
      itemBuilder: (context, index) {
        final accountId = accountIds[index];
        final items = accountGroups[accountId]!;
        final accountTotal = items.fold<double>(
          0.0,
          (sum, item) => sum + item.evaluationAmount,
        );

        final matchedAcc = accounts.firstWhereOrNull((a) => a.id == accountId);
        final matchedAccountName = matchedAcc != null
            ? accountNameMap[matchedAcc.accountNameId]
            : null;

        final institution = matchedAcc?.financialInstitution ??
            items.first.financialInstitution ??
            '기타';
        final accountName = matchedAccountName?.accountName ?? accountId;

        return _AccountCard(
          institution: institution,
          accountName: accountName,
          totalBalance: accountTotal,
          itemCount: items.length,
          onTap: () {
            _showProductDetailBottomSheet(
              context,
              institution: institution,
              accountName: accountName,
              products: items,
            );
          },
        );
      },
    );
  }

  Widget _buildPortionSection(
    List<String> accountIds,
    Map<String, List<MonthlyPensionBalance>> accountGroups,
    List<Account> accounts,
    List<dynamic> accountNames,
    double totalBalance,
  ) {
    final accountNameMap = {for (var an in accountNames) an.id: an};

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 16,
                child: Row(
                  children: accountIds.asMap().entries.map((entry) {
                    final index = entry.key;
                    final accId = entry.value;
                    final items = accountGroups[accId]!;
                    final accountTotal = items.fold<double>(
                      0.0,
                      (sum, item) => sum + item.evaluationAmount,
                    );
                    final ratio =
                        totalBalance > 0 ? accountTotal / totalBalance : 0.0;

                    return Expanded(
                      flex: max(1, (ratio * 1000).toInt()),
                      child: Container(
                        color: _chartColors[index % _chartColors.length],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: accountIds.asMap().entries.map((entry) {
                final index = entry.key;
                final accId = entry.value;
                final items = accountGroups[accId]!;
                final accountTotal = items.fold<double>(
                  0.0,
                  (sum, item) => sum + item.evaluationAmount,
                );
                final ratio = totalBalance > 0
                    ? (accountTotal / totalBalance) * 100
                    : 0.0;

                final matchedAcc =
                    accounts.firstWhereOrNull((a) => a.id == accId);
                final matchedAccountName = matchedAcc != null
                    ? accountNameMap[matchedAcc.accountNameId]
                    : null;

                final displayName = matchedAccountName?.accountName ?? accId;
                final labelText =
                    '${matchedAcc?.financialInstitution ?? items.first.financialInstitution ?? "기타"} - $displayName';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _chartColors[index % _chartColors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          labelText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${accountTotal.toWon()} ',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        '(${ratio.toPercent(fractionDigits: 1)})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomableChartSection(
    List<String> accountIds,
    List<String> months,
  ) {
    if (months.isEmpty) return const SizedBox.shrink();

    final sortedMonths = months.reversed.toList();

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: SizedBox(
          height: 280,
          child: ClipRect(
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 1.0,
              maxScale: 4.0,
              panEnabled: true,
              scaleEnabled: true,
              child: Container(
                width: max(
                  MediaQuery.of(context).size.width - 64,
                  sortedMonths.length * 40.0,
                ),
                padding: const EdgeInsets.only(right: 20, top: 10),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final int index = value.toInt();
                            if (index >= 0 && index < sortedMonths.length) {
                              final ym = sortedMonths[index];
                              final display =
                                  ym.length >= 7 ? ym.substring(2) : ym;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  display,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    lineBarsData: accountIds.asMap().entries.map((entry) {
                      final colorIdx = entry.key;
                      return LineChartBarData(
                        spots: sortedMonths.asMap().entries.map((mEntry) {
                          final idx = mEntry.key;
                          final baseVal = (colorIdx + 1) * 1000000.0;
                          final randomOffset = (idx * 50000);
                          return FlSpot(
                            idx.toDouble(),
                            baseVal + randomOffset,
                          );
                        }).toList(),
                        isCurved: true,
                        color: _chartColors[colorIdx % _chartColors.length],
                        barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showProductDetailBottomSheet(
    BuildContext context, {
    required String institution,
    required String accountName,
    required List<MonthlyPensionBalance> products,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    '[$institution] $accountName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '보유 레코드 (${products.length}개)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            accountName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          trailing: Text(
                            product.evaluationAmount.toWon(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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
        );
      },
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String institution;
  final String accountName;
  final double totalBalance;
  final int itemCount;
  final VoidCallback onTap;

  const _AccountCard({
    required this.institution,
    required this.accountName,
    required this.totalBalance,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    institution,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    accountName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalBalance.toWon(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '기록 $itemCount개',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}