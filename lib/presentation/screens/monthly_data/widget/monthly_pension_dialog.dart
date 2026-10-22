import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../../providers/pension/pension_holding_product_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';

class _GroupedPensionItem {
  final String accountId;
  final String productId;
  double principal;
  double totalPayout;
  double totalWithdrawal; // 💡 누적 중도 인출금 추가
  String? purchaseDate;

  _GroupedPensionItem({
    required this.accountId,
    required this.productId,
    required this.principal,
    required this.totalPayout,
    required this.totalWithdrawal,
    this.purchaseDate,
  });
}

class MonthlyPensionDialog extends ConsumerStatefulWidget {
  final String yearMonth;

  const MonthlyPensionDialog({super.key, required this.yearMonth});

  @override
  ConsumerState<MonthlyPensionDialog> createState() =>
      _MonthlyPensionDialogState();
}

class _MonthlyPensionDialogState extends ConsumerState<MonthlyPensionDialog> {
  late String _selectedYearMonth;
  String? _selectedAccountId;

  final Map<String, TextEditingController> _balanceControllers = {};
  final Map<String, TextEditingController> _addPrincipalControllers = {};
  final Map<String, TextEditingController> _addPayoutControllers = {};
  final Map<String, TextEditingController> _addWithdrawalControllers = {}; // 💡 인출금 컨트롤러

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedYearMonth = widget.yearMonth;
  }

  @override
  void dispose() {
    for (var c in _balanceControllers.values) { c.dispose(); }
    for (var c in _addPrincipalControllers.values) { c.dispose(); }
    for (var c in _addPayoutControllers.values) { c.dispose(); }
    for (var c in _addWithdrawalControllers.values) { c.dispose(); }
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

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final accountProductsAsync = ref.watch(pensionHoldingProductNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);

    final existingCurrentBalancesAsync = ref.watch(
      monthlyPensionBalanceNotifierProvider(_selectedYearMonth),
    );
    final prevYearMonth = _getPreviousYearMonth(_selectedYearMonth);
    final existingPrevBalancesAsync = ref.watch(
      monthlyPensionBalanceNotifierProvider(prevYearMonth),
    );

    return AlertDialog(
      title: const Text('월말 연금 자산/지급액 입력'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                
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
                  validator: (val) =>
                      val == null || val.isEmpty ? '기준월을 입력해주세요.' : null,
                ),
                const SizedBox(height: 16),

                accountsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('계좌 로딩 실패: $err'),
                  data: (accounts) {
                    final accountNames = accountNamesAsync.value ?? [];
                    final accountNameMap = {
                      for (var an in accountNames) an.id: an
                    };

                    final pensionAccounts = accounts
                        .where((a) =>
                            a.accountType.toUpperCase() == '연금' &&
                            a.status == '활동')
                        .toList()
                      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                    if (pensionAccounts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('활동 중인 연금 계좌가 없습니다.'),
                      );
                    }

                    if (_selectedAccountId == null ||
                        !pensionAccounts
                            .any((a) => a.id == _selectedAccountId)) {
                      _selectedAccountId = pensionAccounts.first.id;
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
                          items: pensionAccounts.map((acc) {
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

                        accountProductsAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (err, _) => Text('보유 상품 로딩 실패: $err'),
                          data: (accountProducts) {
                            final products = productsAsync.value ?? [];
                            final productMap = {
                              for (var p in products) p.id!: p.productName
                            };

                            final Map<String, _GroupedPensionItem> groupedMap = {};
                            
                            final matchedHoldingProducts = accountProducts
                                .where((ap) => ap.accountId == _selectedAccountId)
                                .toList();

                            final currentBalances =
                                existingCurrentBalancesAsync.value ?? [];
                            final prevBalances =
                                existingPrevBalancesAsync.value ?? [];

                            final prevBalanceMap = {
                              for (var b in prevBalances)
                                '${b.accountId}_${b.productId}': b
                            };

                            for (var ap in matchedHoldingProducts) {
                              final prodId = ap.productId;
                              final prevData = prevBalanceMap['${ap.accountId}_$prodId'];
                              final basePrincipal = prevData?.principal ?? ap.principal;
                              final basePayout = prevData?.totalPayout ?? ap.totalPayout;
                              final baseWithdrawal = prevData?.totalWithdrawal ?? 0.0;

                              if (groupedMap.containsKey(prodId)) {
                                groupedMap[prodId]!.principal += basePrincipal;
                                groupedMap[prodId]!.totalPayout += basePayout;
                                groupedMap[prodId]!.totalWithdrawal += baseWithdrawal;
                              } else {
                                groupedMap[prodId] = _GroupedPensionItem(
                                  accountId: ap.accountId,
                                  productId: prodId,
                                  principal: basePrincipal,
                                  totalPayout: basePayout,
                                  totalWithdrawal: baseWithdrawal,
                                  purchaseDate: ap.purchaseDate,
                                );
                              }
                            }

                            final groupedItems = groupedMap.values.toList();

                            if (groupedItems.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text('해당 계좌에 매칭된 연금 상품이 없습니다.'),
                              );
                            }

                            final currentBalanceMap = {
                              for (var b in currentBalances)
                                '${b.accountId}_${b.productId}': b
                            };

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: groupedItems.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final groupItem = groupedItems[index];
                                final prodId = groupItem.productId;
                                final productName =
                                    productMap[prodId] ?? '연금 상품';
                                final key = '${_selectedAccountId}_$prodId';

                                final currentData = currentBalanceMap[key];

                                if (!_balanceControllers.containsKey(key)) {
                                  _balanceControllers[key] =
                                      TextEditingController(
                                    text: (currentData != null && currentData.balance > 0)
                                        ? currentData.balance.toCommaString()
                                        : '',
                                  );
                                  _addPrincipalControllers[key] = TextEditingController();
                                  _addPayoutControllers[key] = TextEditingController();
                                  _addWithdrawalControllers[key] = TextEditingController();
                                }

                                return Card(
                                  elevation: 0.5,
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
                                        Text(
                                          productName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
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
                                        
                                        TextFormField(
                                          controller: _balanceControllers[key],
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            ThousandsSeparatorInputFormatter(),
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: '당월 말 평가액',
                                            suffixText: '원',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                        ),
                                        const SizedBox(height: 10),

                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: _addPrincipalControllers[key],
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.digitsOnly,
                                                  ThousandsSeparatorInputFormatter(),
                                                ],
                                                decoration: const InputDecoration(
                                                  labelText: '당월 추가 투자금',
                                                  hintText: '없으면 0',
                                                  suffixText: '원',
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _addPayoutControllers[key],
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.digitsOnly,
                                                  ThousandsSeparatorInputFormatter(),
                                                ],
                                                decoration: const InputDecoration(
                                                  labelText: '당월 수령 연금액',
                                                  hintText: '없으면 0',
                                                  suffixText: '원',
                                                  border: OutlineInputBorder(),
                                                  isDense: true,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _addWithdrawalControllers[key],
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.digitsOnly,
                                                  ThousandsSeparatorInputFormatter(),
                                                ],
                                                decoration: const InputDecoration(
                                                  labelText: '당월 중도 인출금',
                                                  hintText: '없으면 0',
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
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveBalances,
          child: const Text('저장'),
        ),
      ],
    );
  }

  Future<void> _saveBalances() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedAccountId == null) return;

    final notifier = ref.read(
      monthlyPensionBalanceNotifierProvider(_selectedYearMonth).notifier,
    );

    final accountProducts =
        ref.read(pensionHoldingProductNotifierProvider).value ?? [];
    
    final Map<String, _GroupedPensionItem> groupedMap = {};
    final matchedHoldingProducts = accountProducts
        .where((ap) => ap.accountId == _selectedAccountId)
        .toList();

    final prevYearMonth = _getPreviousYearMonth(_selectedYearMonth);
    final prevBalances = ref.read(
          monthlyPensionBalanceNotifierProvider(prevYearMonth),
        ).value ?? [];
    final prevBalanceMap = {
      for (var b in prevBalances) '${b.accountId}_${b.productId}': b
    };

    for (var ap in matchedHoldingProducts) {
      final prodId = ap.productId;
      final prevData = prevBalanceMap['${ap.accountId}_$prodId'];
      final basePrincipal = prevData?.principal ?? ap.principal;
      final basePayout = prevData?.totalPayout ?? ap.totalPayout;
      final baseWithdrawal = prevData?.totalWithdrawal ?? 0.0;

      if (groupedMap.containsKey(prodId)) {
        groupedMap[prodId]!.principal += basePrincipal;
        groupedMap[prodId]!.totalPayout += basePayout;
        groupedMap[prodId]!.totalWithdrawal += baseWithdrawal;
      } else {
        groupedMap[prodId] = _GroupedPensionItem(
          accountId: ap.accountId,
          productId: prodId,
          principal: basePrincipal,
          totalPayout: basePayout,
          totalWithdrawal: baseWithdrawal,
          purchaseDate: ap.purchaseDate,
        );
      }
    }

    final List<MonthlyPensionBalance> itemsToSave = [];

    for (var entry in groupedMap.entries) {
      final prodId = entry.key;
      final groupItem = entry.value;
      final key = '${_selectedAccountId}_$prodId';
      
      final balCtrl = _balanceControllers[key];
      final addPrinCtrl = _addPrincipalControllers[key];
      final addPayoutCtrl = _addPayoutControllers[key];
      final addWithdrawalCtrl = _addWithdrawalControllers[key];

      if (balCtrl != null && balCtrl.text.isNotEmpty) {
        final balVal = double.tryParse(balCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
        final addPrinVal = double.tryParse(addPrinCtrl?.text.replaceAll(RegExp(r'[^0-9]'), '') ?? '') ?? 0.0;
        final addPayoutVal = double.tryParse(addPayoutCtrl?.text.replaceAll(RegExp(r'[^0-9]'), '') ?? '') ?? 0.0;
        final addWithdrawalVal = double.tryParse(addWithdrawalCtrl?.text.replaceAll(RegExp(r'[^0-9]'), '') ?? '') ?? 0.0;

        final finalPrincipal = groupItem.principal + addPrinVal;
        final finalPayout = groupItem.totalPayout + addPayoutVal;
        final finalWithdrawal = groupItem.totalWithdrawal + addWithdrawalVal;

        if (balVal > 0 || finalPrincipal > 0) {
          itemsToSave.add(
            MonthlyPensionBalance(
              yearMonth: _selectedYearMonth,
              accountId: _selectedAccountId!,
              productId: prodId,
              balance: balVal,
              principal: finalPrincipal,
              totalPayout: finalPayout,
              totalWithdrawal: finalWithdrawal, // 💡 최종 누적 인출금 저장
              purchaseDate: groupItem.purchaseDate,
            ),
          );
        }
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