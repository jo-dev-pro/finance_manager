import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../../providers/pension/pension_account_product_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';

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

  // 상품별 입력 컨트롤러 (Key: "${accountId}_${productId}")
  final Map<String, TextEditingController> _balanceControllers = {}; // 당월 평가액
  final Map<String, TextEditingController> _addPrincipalControllers = {}; // 당월 추가 투자금
  final Map<String, TextEditingController> _addPayoutControllers = {}; // 당월 연금 수령액

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedYearMonth = widget.yearMonth;
  }

  @override
  void dispose() {
    for (var c in _balanceControllers.values) {
      c.dispose();
    }
    for (var c in _addPrincipalControllers.values) {
      c.dispose();
    }
    for (var c in _addPayoutControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // 이전 달 YYYY-MM 문자열 구하기
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
    final accountProductsAsync =
        ref.watch(pensionAccountProductNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);

    // 현재달 및 전달 평가 데이터 조회
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
                // 1. 기준월 선택
                TextFormField(
                  initialValue: _selectedYearMonth,
                  decoration: const InputDecoration(
                    labelText: '기준월',
                    hintText: 'YYYY-MM',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
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
                    final pensionAccounts = accounts
                        .where((a) =>
                            a.accountType.toUpperCase() == '연금' &&
                            a.status == '활동')
                        .toList();

                    if (pensionAccounts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('활동 중인 연금 계좌가 없습니다.'),
                      );
                    }

                    final accountNameMap = {
                      for (var an in accountNames) an.id: an
                    };

                    if (_selectedAccountId == null ||
                        !pensionAccounts
                            .any((a) => a.id == _selectedAccountId)) {
                      _selectedAccountId = pensionAccounts.first.id;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 계좌 선택 드롭다운
                        DropdownButtonFormField<String>(
                          value: _selectedAccountId,
                          decoration: const InputDecoration(
                            labelText: '계좌 선택',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
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

                            final matchedHoldingProducts = accountProducts
                                .where((ap) => ap.accountId == _selectedAccountId)
                                .toList();

                            if (matchedHoldingProducts.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text('해당 계좌에 매칭된 연금 상품이 없습니다.'),
                              );
                            }

                            final currentBalances =
                                existingCurrentBalancesAsync.value ?? [];
                            final prevBalances =
                                existingPrevBalancesAsync.value ?? [];

                            final currentBalanceMap = {
                              for (var b in currentBalances)
                                '${b.accountId}_${b.productId}': b
                            };
                            final prevBalanceMap = {
                              for (var b in prevBalances)
                                '${b.accountId}_${b.productId}': b
                            };

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: matchedHoldingProducts.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final holdingItem = matchedHoldingProducts[index];
                                final prodId = holdingItem.productId;
                                final productName =
                                    productMap[prodId] ?? '연금 상품';
                                final key = '${_selectedAccountId}_$prodId';

                                final currentData = currentBalanceMap[key];
                                final prevData = prevBalanceMap[key];

                                // 직전 달 누적액 (없으면 기본 매칭 정보 사용)
                                final prevPrincipal = prevData?.principal ?? holdingItem.principal;
                                final prevPayout = prevData?.totalPayout ?? holdingItem.totalPayout;

                                if (!_balanceControllers.containsKey(key)) {
                                  _balanceControllers[key] =
                                      TextEditingController(
                                    text: (currentData != null && currentData.balance > 0)
                                        ? currentData.balance.toCommaString()
                                        : '',
                                  );
                                  _addPrincipalControllers[key] =
                                      TextEditingController();
                                  _addPayoutControllers[key] =
                                      TextEditingController();
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
                                          '이전 누적원금: ${prevPrincipal.toWon()} | 이전 누적수령액: ${prevPayout.toWon()}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const Divider(height: 16),
                                        
                                        // 1. 당월 말 평가액 (필수)
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

                                        // 2. 당월 추가 매수액 & 당월 연금 수령액 (선택 입력)
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
                                            const SizedBox(width: 8),
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
        ref.read(pensionAccountProductNotifierProvider).value ?? [];
    final matchedHoldingProducts = accountProducts
        .where((ap) => ap.accountId == _selectedAccountId)
        .toList();

    // 직전 달 데이터 조회
    final prevYearMonth = _getPreviousYearMonth(_selectedYearMonth);
    final prevBalances = ref.read(
          monthlyPensionBalanceNotifierProvider(prevYearMonth),
        ).value ?? [];
    final prevBalanceMap = {
      for (var b in prevBalances) '${b.accountId}_${b.productId}': b
    };

    final List<MonthlyPensionBalance> itemsToSave = [];

    for (var holdingItem in matchedHoldingProducts) {
      final prodId = holdingItem.productId;
      final key = '${_selectedAccountId}_$prodId';
      
      final balCtrl = _balanceControllers[key];
      final addPrinCtrl = _addPrincipalControllers[key];
      final addPayoutCtrl = _addPayoutControllers[key];

      if (balCtrl != null && balCtrl.text.isNotEmpty) {
        final balVal = double.tryParse(balCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
        final addPrinVal = double.tryParse(addPrinCtrl?.text.replaceAll(RegExp(r'[^0-9]'), '') ?? '') ?? 0.0;
        final addPayoutVal = double.tryParse(addPayoutCtrl?.text.replaceAll(RegExp(r'[^0-9]'), '') ?? '') ?? 0.0;

        final prevData = prevBalanceMap[key];
        final prevPrincipal = prevData?.principal ?? holdingItem.principal;
        final prevPayout = prevData?.totalPayout ?? holdingItem.totalPayout;

        // 💡 [핵심] 직전 달 누적액 + 이번 달 새로 입력한 금액
        final finalPrincipal = prevPrincipal + addPrinVal;
        final finalPayout = prevPayout + addPayoutVal;

        if (balVal > 0 || finalPrincipal > 0) {
          itemsToSave.add(
            MonthlyPensionBalance(
              yearMonth: _selectedYearMonth,
              accountId: _selectedAccountId!,
              productId: prodId,
              balance: balVal,
              principal: finalPrincipal,   // 누적 합산된 원금 저장
              totalPayout: finalPayout,     // 누적 합산된 수령액 저장
              purchaseDate: holdingItem.purchaseDate,
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