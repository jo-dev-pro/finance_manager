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
import '../../../providers/pension/pension_product_provider.dart';
import '../../../providers/pension/pension_provider.dart';
import '../../../providers/pension/pension_transaction_provider.dart';
import '../../../providers/pension/pension_transaction_type_provider.dart';
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
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
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
                                        () => ref.invalidate(
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
                            (sum, item) => sum + item.balance,
                          );

                          final lastTotalBalance = lastBalancesAsync.maybeWhen(
                            data:
                                (lastBalances) => lastBalances.fold<double>(
                                  0.0,
                                  (sum, item) => sum + item.balance,
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
                        loading:
                            () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        error:
                            (err, stack) =>
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
                            (sum, item) => sum + item.balance,
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
                                '계좌별 월말 수익률 추이 (%)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '💡 차트를 좌우로 드래그하거나 확대/축소하여 전기간 수익률 추이를 확인하세요.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildZoomableReturnRateChartSection(
                                accountIds,
                                activeMonths,
                                accounts,
                                accountNames,
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
              value: currentMonth,
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
    final accountMap = {for (var a in accounts) a.id!: a};

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4, // 💡 카드 높이를 줄여서 공백을 없애고 컴팩트하게 조정
      ),
      itemCount: accountIds.length,
      itemBuilder: (context, index) {
        final accountId = accountIds[index];
        final items = accountGroups[accountId]!;
        final accountTotal = items.fold<double>(
          0.0,
          (sum, item) => sum + item.balance,
        );

        final matchedAcc = accountMap[accountId];
        final matchedAccountName = matchedAcc != null
            ? accountNameMap[matchedAcc.accountNameId]
            : null;

        final institution = matchedAcc?.financialInstitution ?? '기타';
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
    final accountMap = {for (var a in accounts) a.id!: a};

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
                  children:
                      accountIds.asMap().entries.map((entry) {
                        final index = entry.key;
                        final accId = entry.value;
                        final items = accountGroups[accId]!;
                        final accountTotal = items.fold<double>(
                          0.0,
                          (sum, item) => sum + item.balance,
                        );
                        final ratio =
                            totalBalance > 0
                                ? accountTotal / totalBalance
                                : 0.0;

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
              children:
                  accountIds.asMap().entries.map((entry) {
                    final index = entry.key;
                    final accId = entry.value;
                    final items = accountGroups[accId]!;
                    final accountTotal = items.fold<double>(
                      0.0,
                      (sum, item) => sum + item.balance,
                    );
                    final ratio =
                        totalBalance > 0
                            ? (accountTotal / totalBalance) * 100
                            : 0.0;

                    final matchedAcc = accountMap[accId];
                    final matchedAccountName =
                        matchedAcc != null
                            ? accountNameMap[matchedAcc.accountNameId]
                            : null;

                    final displayName =
                        matchedAccountName?.accountName ?? accId;
                    final labelText =
                        '${matchedAcc?.financialInstitution ?? "기타"} - $displayName';

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

  // 💡 계좌별 월말 '수익률' 추이 차트 섹션
  Widget _buildZoomableReturnRateChartSection(
    List<String> accountIds,
    List<String> months,
    List<Account> accounts,
    List<dynamic> accountNames,
  ) {
    if (months.isEmpty) return const SizedBox.shrink();

    final sortedMonths = months.reversed.toList(); // 과거 -> 최신 순 정렬
    final accountMap = {for (var a in accounts) a.id!: a};
    final accountNameMap = {for (var an in accountNames) an.id: an};

    // 거래내역을 통해 계좌별 현재 순 원금 집계 (또는 월별 추이 계산 기반 마련)
    final transactionsAsync = ref.watch(pensionTransactionNotifierProvider);
    final typesAsync = ref.watch(pensionTransactionTypeNotifierProvider);
    final transactions = transactionsAsync.value ?? [];
    final types = typesAsync.value ?? [];
    final signMap = {for (var t in types) t.id ?? '': t.amountSign};

    // 계좌별 총 투입 원금 계산 (매수/입금 - 연금지급/인출)
    final Map<String, double> accountPrincipals = {};
    for (var t in transactions) {
      if (t.accountId.isNotEmpty) {
        final sign = signMap[t.transactionTypeId] ?? 'PLUS';
        final signedAmount = (sign == 'MINUS') ? -t.amount : t.amount;
        accountPrincipals.update(
          t.accountId,
          (val) => val + signedAmount,
          ifAbsent: () => signedAmount,
        );
      }
    }

    // 전체 월별 평가액 데이터 가져오기
    final allBalancesAsync = ref.watch(allMonthlyPensionBalancesProvider);
    final allBalances = allBalancesAsync.value ?? [];

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: SizedBox(
          height: 300,
          child: ClipRect(
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.symmetric(horizontal: 40),
              minScale: 1.0,
              maxScale: 4.0,
              panEnabled: true,
              scaleEnabled: true,
              child: Container(
                // 💡 월 간격을 넉넉히 주어 글씨가 겹치지 않도록 너비 확장
                width: max(
                  MediaQuery.of(context).size.width - 64,
                  sortedMonths.length * 60.0,
                ),
                padding: const EdgeInsets.only(right: 30, top: 10, left: 10),
                child: LineChart(
                  LineChartData(
                    // 💡 터치 시 툴팁 설정 (배경색과 가독성 개선, 화면 밖 넘침 방지)
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => Colors.grey.shade900,
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final accId = accountIds[spot.barIndex];
                            final acc = accountMap[accId];
                            final accNameObj = acc != null ? accountNameMap[acc.accountNameId] : null;
                            final name = accNameObj?.accountName ?? '계좌';
                            
                            return LineTooltipItem(
                              '$name\n수익률: ${spot.y.toStringAsFixed(1)}%',
                              const TextStyle(
                                color: Colors.white, // 💡 밝은 흰색 텍스트로 가독성 확보
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
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
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            );
                          },
                        ),
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
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  ym, // YYYY-MM 형태로 명확히 표시
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
                    lineBarsData:
                        accountIds.asMap().entries.map((entry) {
                          final colorIdx = entry.key;
                          final accId = entry.value;
                          final principal = accountPrincipals[accId] ?? 1.0; // 0 나누기 방지

                          // 해당 계좌의 월별 수익률 스팟 계산
                          final spots = sortedMonths.asMap().entries.map((mEntry) {
                            final idx = mEntry.key;
                            final ym = mEntry.value;

                            // 해당 월의 해당 계좌 평가액 총합 계산
                            final monthItems = allBalances.where(
                              (b) => b.balanceItem.yearMonth == ym && b.balanceItem.accountId == accId,
                            );
                            final monthBalance = monthItems.fold<double>(
                              0.0,
                              (sum, item) => sum + item.balanceItem.balance,
                            );

                            // 수익률(%) 산출: ((평가액 - 원금) / 원금) * 100
                            final profit = monthBalance - principal;
                            final returnRate = principal > 0 ? (profit / principal) * 100 : 0.0;

                            return FlSpot(idx.toDouble(), returnRate);
                          }).toList();

                          return LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: _chartColors[colorIdx % _chartColors.length],
                            barWidth: 2.5,
                            dotData: const FlDotData(show: true),
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
        return Consumer(
          builder: (context, ref, child) {
            final productsAsync = ref.watch(pensionProductNotifierProvider);
            final productMap = productsAsync.maybeWhen(
              data: (list) => {for (var p in list) p.id!: p.productName},
              orElse: () => <String, String>{},
            );

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
                        '보유 상품 (${products.length}개)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const Divider(height: 24),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: products.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final balanceItem = products[index];
                            final productName =
                                productMap[balanceItem.productId] ?? '연금 상품';

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              trailing: Text(
                                balanceItem.balance.toWon(),
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
      },
    );
  }
}

// 💡 공백을 줄이고 깔끔하게 개선된 계좌 카드 위젯
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
      elevation: 1.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 상단: 금융기관 및 계좌명
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    institution,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    accountName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              // 하단: 총 평가액 및 보유상품 개수
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalBalance.toWon(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '보유상품 $itemCount개', // 💡 기록 -> 보유상품으로 변경
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 14,
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