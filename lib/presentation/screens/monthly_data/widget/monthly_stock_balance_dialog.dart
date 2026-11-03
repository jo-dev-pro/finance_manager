import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/toss_direct_api_service.dart';
import '../../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../../models/monthly_data/monthly_stock_account_balance.dart';
import '../../../../models/stock/stock_item.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../../providers/stock/stock_holding_item_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';

class _GroupedStockItem {
  final String accountId;
  final String stockItemId;
  double principal;
  String? purchaseDate;

  _GroupedStockItem({
    required this.accountId,
    required this.stockItemId,
    required this.principal,
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

  // 종목별 입력 컨트롤러
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, TextEditingController> _addPrincipalControllers = {};
  final Map<String, TextEditingController> _payoutControllers = {};

  // 계좌 공통 입력 컨트롤러 (현금성 잔액, 당월 인출액)
  final TextEditingController _accountCashBalanceController =
      TextEditingController();
  final TextEditingController _accountMonthlyWithdrawalController =
      TextEditingController();

  final Map<String, bool> _isLoadingPriceMap = {};
  bool _isAllLoading = false;

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
    for (var c in _payoutControllers.values) {
      c.dispose();
    }
    _accountCashBalanceController.dispose();
    _accountMonthlyWithdrawalController.dispose();
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

  Future<void> _fetchPriceForStock(
    String key,
    String stockItemId,
    List<StockItem> stockItems,
  ) async {
    final selectedStock = stockItems.firstWhere(
      (s) => s.id == stockItemId,
      orElse: () => throw Exception('종목을 찾을 수 없습니다.'),
    );

    String symbol = selectedStock.stockCode.trim();
    setState(() => _isLoadingPriceMap[key] = true);

    try {
      final price = await TossDirectApiService.getMonthlyClosePrice(
        symbol,
        _selectedYearMonth,
      );
      if (price != null && _priceControllers.containsKey(key)) {
        setState(() {
          _priceControllers[key]!.text = price.toCommaString();
        });
      }
    } catch (e) {
      print('시세 조회 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoadingPriceMap[key] = false);
    }
  }

  Future<void> _fetchAllPrices(
    List<_GroupedStockItem> groupedItems,
    List<StockItem> stockItems,
  ) async {
    if (groupedItems.isEmpty) return;

    setState(() => _isAllLoading = true);

    await Future.wait(
      groupedItems.map((group) async {
        final key = '${group.accountId}_${group.stockItemId}';
        final stockId = group.stockItemId;

        try {
          final selectedStock = stockItems.firstWhere(
            (s) => s.id == stockId,
            orElse: () => throw Exception('종목을 찾을 수 없습니다.'),
          );

          String symbol = selectedStock.stockCode.trim();
          final price = await TossDirectApiService.getMonthlyClosePrice(
            symbol,
            _selectedYearMonth,
          );

          if (price != null && _priceControllers.containsKey(key)) {
            setState(() {
              _priceControllers[key]!.text = price.toCommaString();
            });
          }
        } catch (e) {
          print('종목($stockId) 일괄 조회 실패: $e');
        }
      }),
    );

    if (mounted) {
      setState(() => _isAllLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 종목의 시세 조회가 완료되었습니다!')),
      );
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

    // 계좌별 요약 데이터 (현재월 및 전월) 감시
    final currentAccountBalancesAsync = ref.watch(
      monthlyStockAccountBalanceNotifierProvider(_selectedYearMonth),
    );
    final prevAccountBalancesAsync = ref.watch(
      monthlyStockAccountBalanceNotifierProvider(prevYearMonth),
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

                  // 계좌 공통 필드 기본값 세팅 (현금성 잔액은 전월값 자동 상속 또는 현재값 반영)
                  final currentAccBalances = currentAccountBalancesAsync.value ?? [];
                  final prevAccBalances = prevAccountBalancesAsync.value ?? [];
                  
                  final currentAccData = currentAccBalances.firstWhereOrNull(
                    (b) => b.accountId == _selectedAccountId,
                  );
                  final prevAccData = prevAccBalances.firstWhereOrNull(
                    (b) => b.accountId == _selectedAccountId,
                  );

                  if (_accountCashBalanceController.text.isEmpty) {
                    final defaultCash = (currentAccData != null && currentAccData.cashBalance > 0)
                        ? currentAccData.cashBalance
                        : (prevAccData?.cashBalance ?? 0.0);
                    if (defaultCash > 0) {
                      _accountCashBalanceController.text = defaultCash.toCommaString();
                    }
                  }

                  if (_accountMonthlyWithdrawalController.text.isEmpty && currentAccData != null && currentAccData.monthlyWithdrawal > 0) {
                    _accountMonthlyWithdrawalController.text = currentAccData.monthlyWithdrawal.toCommaString();
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
                            // 계좌 변경 시 컨트롤러 초기화 후 다시 세팅되도록 비움
                            _accountCashBalanceController.clear();
                            _accountMonthlyWithdrawalController.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // 💡 [계좌 공통] 현금성 잔액 및 당월 인출액 카드
                      Card(
                        color: Colors.indigo.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.indigo.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.account_balance_wallet, size: 18, color: Colors.indigo.shade800),
                                  const SizedBox(width: 6),
                                  Text(
                                    '계좌 공통 현금 및 자금 관리',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.indigo.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _accountCashBalanceController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        ThousandsSeparatorInputFormatter(),
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: '계좌 현금성 잔액(예수금)',
                                        hintText: '0',
                                        suffixText: '원',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _accountMonthlyWithdrawalController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        ThousandsSeparatorInputFormatter(),
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: '당월 인출액',
                                        hintText: '0',
                                        suffixText: '원',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
                            groupedMap[stockId] = _GroupedStockItem(
                              accountId: hi.accountId,
                              stockItemId: stockId,
                              principal: prevData?.principal ?? 0.0,
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

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton.icon(
                                onPressed:
                                    _isAllLoading
                                        ? null
                                        : () => _fetchAllPrices(
                                          groupedItems,
                                          stockItems,
                                        ),
                                icon:
                                    _isAllLoading
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Icon(Icons.flash_on, size: 16),
                                label: Text(
                                  _isAllLoading
                                      ? '전체 시세 조회 중...'
                                      : '전체 종목 시세 일괄 조회',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              ListView.separated(
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
                                    final currentQty =
                                        (currentData != null && currentData.quantity > 0)
                                            ? currentData.quantity
                                            : (prevBalanceMap[key]?.quantity ?? 0.0);

                                    final currentPriceVal =
                                        (currentData != null && currentData.currentPrice > 0)
                                            ? currentData.currentPrice
                                            : (prevBalanceMap[key]?.currentPrice ?? 0.0);

                                    _quantityControllers[key] = TextEditingController(
                                      text: currentQty > 0 ? currentQty.toString() : '',
                                    );
                                    _priceControllers[key] = TextEditingController(
                                      text: currentPriceVal > 0
                                          ? currentPriceVal.toCommaString()
                                          : '',
                                    );
                                    _addPrincipalControllers[key] =
                                        TextEditingController();
                                    
                                    final currentPayout = currentData?.totalPayout ?? 0.0;
                                    _payoutControllers[key] = TextEditingController(
                                      text: currentPayout > 0 ? currentPayout.toCommaString() : '',
                                    );
                                  }

                                  final isLoading =
                                      _isLoadingPriceMap[key] ?? false;

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
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              OutlinedButton.icon(
                                                onPressed:
                                                    isLoading
                                                        ? null
                                                        : () =>
                                                            _fetchPriceForStock(
                                                              key,
                                                              stockId,
                                                              stockItems,
                                                            ),
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
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                  ),
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
                                            '누적 원금: ${groupItem.principal.toWon()}',
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
                                                      const TextInputType
                                                          .numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: '수량',
                                                        suffixText: '주',
                                                        border:
                                                            OutlineInputBorder(),
                                                        isDense: true,
                                                      ),
                                                  onChanged:
                                                      (_) => setState(() {}),
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
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: '주당 현재가',
                                                        suffixText: '원',
                                                        border:
                                                            OutlineInputBorder(),
                                                        isDense: true,
                                                      ),
                                                  onChanged:
                                                      (_) => setState(() {}),
                                                ),
                                              ),
                                            ],
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
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: '추가 매수액',
                                                        hintText: '0',
                                                        suffixText: '원',
                                                        border:
                                                            OutlineInputBorder(),
                                                        isDense: true,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _payoutControllers[key],
                                                  keyboardType: TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.digitsOnly,
                                                    ThousandsSeparatorInputFormatter(),
                                                  ],
                                                  decoration: const InputDecoration(
                                                    labelText: '당월 배당금',
                                                    hintText: '0',
                                                    suffixText: '원',
                                                    border: OutlineInputBorder(),
                                                    isDense: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '산출 평가액: ${calcBalance.toWon()}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.indigo.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
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

    final stockNotifier = ref.read(
      monthlyStockBalanceNotifierProvider(_selectedYearMonth).notifier,
    );
    final accountBalanceNotifier = ref.read(
      monthlyStockAccountBalanceNotifierProvider(_selectedYearMonth).notifier,
    );

    // 1. 전월 누적 인출액 계산을 위한 준비
    final prevYearMonth = _getPreviousYearMonth(_selectedYearMonth);
    final prevAccountBalances = ref.read(
          monthlyStockAccountBalanceNotifierProvider(prevYearMonth),
        ).value ?? [];
    
    final prevAccountBalance = prevAccountBalances.firstWhereOrNull(
      (b) => b.accountId == _selectedAccountId,
    );
    final prevTotalWithdrawal = prevAccountBalance?.totalWithdrawal ?? 0.0;

    // 2. 공통 입력 파싱 (현금성 잔액, 당월 인출액)
    final accountCashBalance = double.tryParse(
          _accountCashBalanceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0.0;
    final currentMonthlyWithdrawal = double.tryParse(
          _accountMonthlyWithdrawalController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0.0;

    // 3. 당월 누적 인출액 산출 (전월 누적 + 당월 인출액)
    final finalTotalWithdrawal = prevTotalWithdrawal + currentMonthlyWithdrawal;

    // 4. 계좌별 요약 테이블에 저장
    final accountBalanceItem = MonthlyStockAccountBalance(
      yearMonth: _selectedYearMonth,
      accountId: _selectedAccountId!,
      cashBalance: accountCashBalance,
      monthlyWithdrawal: currentMonthlyWithdrawal,
      totalWithdrawal: finalTotalWithdrawal,
    );
    await accountBalanceNotifier.saveBalance(accountBalanceItem);

    // 5. 종목별 데이터 저장 처리
    final holdingItems = ref.read(stockHoldingItemNotifierProvider).value ?? [];
    final Map<String, _GroupedStockItem> groupedMap = {};

    final prevBalances =
        ref.read(monthlyStockBalanceNotifierProvider(prevYearMonth)).value ?? [];
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
      groupedMap[stockId] = _GroupedStockItem(
        accountId: hi.accountId,
        stockItemId: stockId,
        principal: prevData?.principal ?? 0.0,
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
      final payoutCtrl = _payoutControllers[key];

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
        
        final payoutVal =
            double.tryParse(
              payoutCtrl?.text.replaceAll(RegExp(r'[^0-9]'), '') ?? '',
            ) ??
            0.0;

        final finalPrincipal = groupItem.principal + addPrinVal;

        itemsToSave.add(
          MonthlyStockBalance(
            yearMonth: _selectedYearMonth,
            accountId: _selectedAccountId!,
            stockItemId: stockId,
            quantity: qtyVal,
            currentPrice: priceVal,
            balance: balanceVal,
            principal: finalPrincipal,
            totalPayout: payoutVal,
            totalWithdrawal: 0.0, // 종목별 테이블에서는 인출액 분리 완료
            purchaseDate: groupItem.purchaseDate,
          ),
        );
      }
    }

    if (itemsToSave.isNotEmpty) {
      await stockNotifier.saveBatchBalances(itemsToSave);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}