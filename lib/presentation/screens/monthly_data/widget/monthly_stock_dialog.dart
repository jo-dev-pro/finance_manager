import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/yahoo_service.dart';
import '../../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../../models/stock/stock_item.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../../providers/stock/stock_holding_item_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';

class _GroupedStockItem {
  final String accountId;
  final String stockItemId;
  double principal;
  double totalPayout;
  double totalWithdrawal;
  String? purchaseDate;

  _GroupedStockItem({
    required this.accountId,
    required this.stockItemId,
    required this.principal,
    required this.totalPayout,
    required this.totalWithdrawal,
    this.purchaseDate,
  });
}

class MonthlyStockBalanceDialog extends ConsumerStatefulWidget {
  final String yearMonth;

  const MonthlyStockBalanceDialog({super.key, required this.yearMonth});

  @override
  ConsumerState<MonthlyStockBalanceDialog> createState() =>
      _MonthlyStockBalanceDialogState();
}

class _MonthlyStockBalanceDialogState
    extends ConsumerState<MonthlyStockBalanceDialog> {
  late String _selectedYearMonth;
  String? _selectedAccountId;

  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, TextEditingController> _addPrincipalControllers = {};
  final Map<String, TextEditingController> _addPayoutControllers = {};
  final Map<String, TextEditingController> _addWithdrawalControllers = {};

  final Map<String, bool> _isLoadingPriceMap = {};

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedYearMonth = widget.yearMonth;
  }

  @override
  void dispose() {
    for (var c in _quantityControllers.values) {
      c.dispose();
    }
    for (var c in _priceControllers.values) {
      c.dispose();
    }
    for (var c in _addPrincipalControllers.values) {
      c.dispose();
    }
    for (var c in _addPayoutControllers.values) {
      c.dispose();
    }
    for (var c in _addWithdrawalControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _getPreviousYearMonth(String ym) {
    try {
      final parts = ym.split('-');
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      DateTime lastMonthDate = DateTime(year, month - 1, 1);
      return DateFormat('yyyy-MM').format(lastMonthDate);
    } catch (_) {
      return ym;
    }
  }

  Future<void> _fetchYahooPriceForStock(
    String key,
    String stockItemId,
    List<StockItem> stockItems,
  ) async {
    print('🚀 _fetchYahooPriceForStock 함수 진입! stockItemId: $stockItemId, yearMonth: $_selectedYearMonth');
    final selectedStock = stockItems.firstWhere(
      (s) => s.id == stockItemId,
      orElse: () => throw Exception('종목을 찾을 수 없습니다.'),
    );

print('📌 찾은 종목명: ${selectedStock.itemName}, stockCode: ${selectedStock.stockCode}, yahooName: ${selectedStock.yahooName}');
    String ticker = selectedStock.stockCode;
    if (selectedStock.yahooName == 'KS') {
      ticker += '.KS';
    } else if (selectedStock.yahooName == 'KQ') {
      ticker += '.KQ';
    }

print('🎯 최종 티커(Ticker): $ticker');

    setState(() => _isLoadingPriceMap[key] = true);

    try {
          print('$ticker $_selectedYearMonth');
      final price = await YahooFinanceService.getMonthlyClosePrice(
        ticker,
        _selectedYearMonth,
      );
      if (price != null && _priceControllers.containsKey(key)) {
        setState(() {
          _priceControllers[key]!.text = price.toCommaString();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${selectedStock.itemName}의 $_selectedYearMonth 종가(${price.toCommaString()}원)를 불러왔습니다!',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('해당 월의 시세 데이터를 찾지 못했습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('시세 조회 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingPriceMap[key] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final holdingItemsAsync = ref.watch(stockHoldingItemNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);

    final existingCurrentBalancesAsync = ref.watch(
      monthlyStockBalanceNotifierProvider(_selectedYearMonth),
    );
    final prevYearMonth = _getPreviousYearMonth(_selectedYearMonth);
    final existingPrevBalancesAsync = ref.watch(
      monthlyStockBalanceNotifierProvider(prevYearMonth),
    );

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '월말 주식 평가액/수량 일괄 입력',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: _selectedYearMonth,
                decoration: const InputDecoration(
                  labelText: '기준월',
                  hintText: 'YYYY-MM',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _selectedYearMonth = val.trim();
                  });
                },
                validator:
                    (val) => val == null || val.isEmpty ? '기준월을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),

              accountsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('계좌 로딩 실패: $err'),
                data: (accounts) {
                  final accountNames = accountNamesAsync.value ?? [];
                  final accountNameMap = {
                    for (var an in accountNames) an.id: an,
                  };

                  final stockAccounts =
                      accounts
                          .where(
                            (a) =>
                                a.accountType.trim() == '증권' &&
                                a.status == '활동',
                          )
                          .toList();

                  if (stockAccounts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        '등록된 주식 계좌가 없습니다. 계좌 관리에서 주식 계좌를 먼저 추가해 주세요.',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (_selectedAccountId == null ||
                      !stockAccounts.any((a) => a.id == _selectedAccountId)) {
                    _selectedAccountId = stockAccounts.first.id;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAccountId,
                        decoration: const InputDecoration(
                          labelText: '계좌 선택',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        items:
                            stockAccounts.map((acc) {
                              final institution = acc.financialInstitution;
                              final nameObj = accountNameMap[acc.accountNameId];
                              final nameDisplay = nameObj?.accountName ?? '계좌';
                              return DropdownMenuItem(
                                value: acc.id,
                                child: Text('$institution - $nameDisplay'),
                              );
                            }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedAccountId = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      holdingItemsAsync.when(
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error: (err, _) => Text('보유 종목 로딩 실패: $err'),
                        data: (holdingItems) {
                          final stockItems = stockItemsAsync.value ?? [];
                          final stockMap = {
                            for (var s in stockItems)
                              s.id!: '${s.itemName} (${s.stockCode})',
                          };

                          final Map<String, _GroupedStockItem> groupedMap = {};

                          final currentBalances =
                              existingCurrentBalancesAsync.value ?? [];
                          final prevBalances =
                              existingPrevBalancesAsync.value ?? [];

                          final prevBalanceMap = {
                            for (var b in prevBalances)
                              '${b.accountId}_${b.stockItemId}': b,
                          };

                          final matchedHoldings =
                              holdingItems
                                  .where(
                                    (hi) =>
                                        hi.accountId == _selectedAccountId &&
                                        hi.isActive,
                                  )
                                  .toList();

                          for (var hi in matchedHoldings) {
                            final stockId = hi.stockItemId;
                            final prevData =
                                prevBalanceMap['${hi.accountId}_$stockId'];
                            final basePrincipal = prevData?.principal ?? 0.0;
                            final basePayout = prevData?.totalPayout ?? 0.0;
                            final baseWithdrawal =
                                prevData?.totalWithdrawal ?? 0.0;

                            groupedMap[stockId] = _GroupedStockItem(
                              accountId: hi.accountId,
                              stockItemId: stockId,
                              principal: basePrincipal,
                              totalPayout: basePayout,
                              totalWithdrawal: baseWithdrawal,
                              purchaseDate: hi.initialPurchaseDate,
                            );
                          }

                          final groupedItems = groupedMap.values.toList();
                          final currentBalanceMap = {
                            for (var b in currentBalances)
                              '${b.accountId}_${b.stockItemId}': b,
                          };

                          if (groupedItems.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('해당 계좌에 등록된 보유 종목이 없습니다.'),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupedItems.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final groupItem = groupedItems[index];
                              final stockId = groupItem.stockItemId;
                              final stockName =
                                  stockMap[stockId] ?? '알 수 없는 종목';

                              final key = '${_selectedAccountId}_$stockId';
                              final currentData = currentBalanceMap[key];

                              if (!_quantityControllers.containsKey(key)) {
                                _quantityControllers[key] =
                                    TextEditingController(
                                      text:
                                          (currentData != null &&
                                                  currentData.quantity > 0)
                                              ? currentData.quantity.toString()
                                              : '',
                                    );
                                _priceControllers[key] = TextEditingController(
                                  text:
                                      (currentData != null &&
                                              currentData.currentPrice > 0)
                                          ? currentData.currentPrice
                                              .toCommaString()
                                          : '',
                                );
                                _addPrincipalControllers[key] =
                                    TextEditingController();
                                _addPayoutControllers[key] =
                                    TextEditingController();
                                _addWithdrawalControllers[key] =
                                    TextEditingController();
                              }

                              final isLoading =
                                  _isLoadingPriceMap[key] ?? false;

                              // 실시간 산출 평가액 계산
                              final qty =
                                  double.tryParse(
                                    _quantityControllers[key]!.text
                                        .replaceAll(',', '')
                                        .trim(),
                                  ) ??
                                  0.0;
                              final price =
                                  double.tryParse(
                                    _priceControllers[key]!.text
                                        .replaceAll(',', '')
                                        .trim(),
                                  ) ??
                                  0.0;
                              final calcBalance = qty * price;

                              return Card(
                                elevation: 1.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              stockName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: isLoading ? null : () {
    print('👉 시세조회 버튼 클릭됨! key: $key, stockId: $stockId');
    _fetchYahooPriceForStock(key, stockId, stockItems);
  },
                                            icon:
                                                isLoading
                                                    ? const SizedBox(
                                                      width: 12,
                                                      height: 12,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    )
                                                    : const Icon(
                                                      Icons.cloud_download,
                                                      size: 14,
                                                    ),
                                            label: const Text(
                                              '시세조회',
                                              style: TextStyle(fontSize: 11),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              minimumSize: Size.zero,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '누적원금: ${groupItem.principal.toWon()} | 수령액: ${groupItem.totalPayout.toWon()} | 인출금: ${groupItem.totalWithdrawal.toWon()}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const Divider(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _quantityControllers[key],
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              decoration: const InputDecoration(
                                                labelText: '보유 수량',
                                                suffixText: '주',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: TextFormField(
                                              controller:
                                                  _priceControllers[key],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                ThousandsSeparatorInputFormatter(),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: '주당 현재가',
                                                suffixText: '원',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '산출 평가액: ${calcBalance.toWon()}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.indigo.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _addPrincipalControllers[key],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                ThousandsSeparatorInputFormatter(),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: '추가 매수액',
                                                hintText: '0',
                                                suffixText: '원',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _addPayoutControllers[key],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                ThousandsSeparatorInputFormatter(),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: '배당금',
                                                hintText: '0',
                                                suffixText: '원',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _addWithdrawalControllers[key],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                ThousandsSeparatorInputFormatter(),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: '인출액',
                                                hintText: '0',
                                                suffixText: '원',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveBalances,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('저장하기', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBalances() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedAccountId == null) return;

    final notifier = ref.read(
      monthlyStockBalanceNotifierProvider(_selectedYearMonth).notifier,
    );

    final holdingItems = ref.read(stockHoldingItemNotifierProvider).value ?? [];

    final Map<String, _GroupedStockItem> groupedMap = {};

    final prevYearMonth = _getPreviousYearMonth(_selectedYearMonth);
    final prevBalances =
        ref.read(monthlyStockBalanceNotifierProvider(prevYearMonth)).value ??
        [];
    final prevBalanceMap = {
      for (var b in prevBalances) '${b.accountId}_${b.stockItemId}': b,
    };

    final matchedHoldings =
        holdingItems
            .where((hi) => hi.accountId == _selectedAccountId && hi.isActive)
            .toList();

    for (var hi in matchedHoldings) {
      final stockId = hi.stockItemId;
      final prevData = prevBalanceMap['${hi.accountId}_$stockId'];
      final basePrincipal = prevData?.principal ?? 0.0;
      final basePayout = prevData?.totalPayout ?? 0.0;
      final baseWithdrawal = prevData?.totalWithdrawal ?? 0.0;

      groupedMap[stockId] = _GroupedStockItem(
        accountId: hi.accountId,
        stockItemId: stockId,
        principal: basePrincipal,
        totalPayout: basePayout,
        totalWithdrawal: baseWithdrawal,
        purchaseDate: hi.initialPurchaseDate,
      );
    }

    final List<MonthlyStockBalance> itemsToSave = [];

    for (var entry in groupedMap.entries) {
      final stockId = entry.key;
      final groupItem = entry.value;
      final key = '${_selectedAccountId}_$stockId';

      final qtyCtrl = _quantityControllers[key];
      final priceCtrl = _priceControllers[key];
      final addPrinCtrl = _addPrincipalControllers[key];
      final addPayoutCtrl = _addPayoutControllers[key];
      final addWithdrawalCtrl = _addWithdrawalControllers[key];

      if (qtyCtrl != null &&
          qtyCtrl.text.isNotEmpty &&
          priceCtrl != null &&
          priceCtrl.text.isNotEmpty) {
        final qtyVal =
            double.tryParse(qtyCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
        final priceVal =
            double.tryParse(priceCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
        final balanceVal = qtyVal * priceVal;

        final addPrinVal =
            double.tryParse(
              addPrinCtrl?.text.replaceAll(RegExp(r'[^0-9]'), '') ?? '',
            ) ??
            0.0;
        final addPayoutVal =
            double.tryParse(
              addPayoutCtrl?.text.replaceAll(RegExp(r'[^0-9]'), '') ?? '',
            ) ??
            0.0;
        final addWithdrawalVal =
            double.tryParse(
              addWithdrawalCtrl?.text.replaceAll(RegExp(r'[^0-9]'), '') ?? '',
            ) ??
            0.0;

        final finalPrincipal = groupItem.principal + addPrinVal;
        final finalPayout = groupItem.totalPayout + addPayoutVal;
        final finalWithdrawal = groupItem.totalWithdrawal + addWithdrawalVal;

        itemsToSave.add(
          MonthlyStockBalance(
            yearMonth: _selectedYearMonth,
            accountId: _selectedAccountId!,
            stockItemId: stockId,
            quantity: qtyVal,
            currentPrice: priceVal,
            balance: balanceVal,
            principal: finalPrincipal,
            totalPayout: finalPayout,
            totalWithdrawal: finalWithdrawal,
            purchaseDate: groupItem.purchaseDate,
          ),
        );
      }
    }

    if (itemsToSave.isNotEmpty) {
      await notifier.saveBatchBalances(itemsToSave);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
