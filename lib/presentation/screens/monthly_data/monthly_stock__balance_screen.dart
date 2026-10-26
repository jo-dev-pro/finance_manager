import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../providers/stock/stock_item_provider.dart';
import 'widget/monthly_stock_dialog.dart';

class MonthlyStockBalanceScreen extends ConsumerStatefulWidget {
  const MonthlyStockBalanceScreen({super.key});

  @override
  ConsumerState<MonthlyStockBalanceScreen> createState() =>
      _MonthlyStockBalanceScreenState();
}

class _MonthlyStockBalanceScreenState
    extends ConsumerState<MonthlyStockBalanceScreen> {
  late String _selectedYearMonth;

  @override
  void initState() {
    super.initState();
    _selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  }

  // 월 선택 피커 다이얼로그
  Future<void> _selectYearMonth() async {
    final now = DateTime.now();
    int selectedYear = int.parse(_selectedYearMonth.split('-')[0]);
    int selectedMonth = int.parse(_selectedYearMonth.split('-')[1]);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('조회 월 선택'),
          content: SizedBox(
            width: 300,
            height: 200,
            child: YearMonthPicker(
              initialYear: selectedYear,
              initialMonth: selectedMonth,
              onChanged: (year, month) {
                selectedYear = year;
                selectedMonth = month;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedYearMonth =
                      '$selectedYear-${selectedMonth.toString().padLeft(2, '0')}';
                });
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final balancesAsync =
        ref.watch(monthlyStockBalanceNotifierProvider(_selectedYearMonth));
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('$_selectedYearMonth 주식 월말 내역'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectYearMonth,
            tooltip: '기준월 변경',
          ),
        ],
      ),
      body: balancesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터 로딩 실패: $err')),
        data: (balances) {
          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final stockItems = stockItemsAsync.value ?? [];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final stockItemMap = {for (var s in stockItems) s.id!: s};

          // 총 합계 계산
          double totalBalance = 0;
          double totalPrincipal = 0;
          for (var b in balances) {
            totalBalance += b.balance;
            totalPrincipal += b.principal;
          }
          final totalProfit = totalBalance - totalPrincipal;

          return Column(
            children: [
              // 💡 상단 요약 바
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.indigo.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                        '총 평가액', '${totalBalance.toCommaString()} 원'),
                    _buildSummaryItem(
                        '투자 원금', '${totalPrincipal.toCommaString()} 원'),
                    _buildSummaryItem(
                      '평가 손익',
                      '${totalProfit >= 0 ? '+' : ''}${totalProfit.toCommaString()} 원',
                      color: totalProfit >= 0 ? Colors.red : Colors.blue,
                    ),
                  ],
                ),
              ),

              // 💡 월말 내역 리스트
              Expanded(
                child: balances.isEmpty
                    ? Center(
                        child: Text(
                          '$_selectedYearMonth에 등록된 주식 월말 내역이 없습니다.\n우측 하단 버튼을 눌러 추가해 주세요.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: balances.length,
                        itemBuilder: (context, index) {
                          final item = balances[index];
                          final account = accountMap[item.accountId];
                          final accountName = account != null
                              ? accountNameMap[account.accountNameId]
                              : null;
                          final stock = stockItemMap[item.stockItemId];

                          final accName =
                              '${account?.financialInstitution ?? ''} (${accountName?.accountName ?? ''})';
                          final stockName =
                              stock?.name ?? '알 수 없는 종목 (${stock?.symbolCode ?? ''})';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(stockName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '$accName\n수량: ${item.quantity.toCommaString()}주 | 단가: ${item.currentPrice.toCommaString()}원',
                              ),
                              isThreeLine: true,
                              trailing: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${item.balance.toCommaString()} 원',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.returnRate >= 0 ? '+' : ''}${item.returnRate.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: item.returnRate >= 0
                                          ? Colors.red
                                          : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // 수정 다이얼로그 호출
                                showDialog(
                                  context: context,
                                  builder: (_) => MonthlyStockBalanceDialog(
                                    yearMonth: _selectedYearMonth,
                                    initialData: item,
                                  ),
                                );
                              },
                              onLongPress: () async {
                                // 삭제 확인
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('내역 삭제'),
                                    content: const Text(
                                        '이 월말 평가 내역을 삭제하시겠습니까?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('취소')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('삭제',
                                              style: TextStyle(
                                                  color: Colors.red))),
                                    ],
                                  ),
                                );

                                if (confirm == true && item.id != null) {
                                  await ref
                                      .read(monthlyStockBalanceNotifierProvider(
                                              _selectedYearMonth)
                                          .notifier)
                                      .deleteBalance(item.id!);
                                }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) =>
                MonthlyStockBalanceDialog(yearMonth: _selectedYearMonth),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

// 간단한 연도/월 선택용 보조 위젯 예시
class YearMonthPicker extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final Function(int year, int month) onChanged;

  const YearMonthPicker({
    super.key,
    required this.initialYear,
    required this.initialMonth,
    required this.onChanged,
  });

  @override
  State<YearMonthPicker> createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<YearMonthPicker> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _year--;
                  widget.onChanged(_year, _month);
                });
              },
            ),
            Text('$_year년',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _year++;
                  widget.onChanged(_year, _month);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(12, (index) {
            final m = index + 1;
            final isSelected = m == _month;
            return ChoiceChip(
              label: Text('$m월'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _month = m;
                    widget.onChanged(_year, _month);
                  });
                }
              },
            );
          }),
        ),
      ],
    );
  }
}