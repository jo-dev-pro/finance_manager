import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  // 상품별 평가액 컨트롤러 (Key: "${accountId}_${productId}")
  final Map<String, TextEditingController> _balanceControllers = {};
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final accountProductsAsync =
        ref.watch(pensionAccountProductNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);
    final existingBalancesAsync = ref.watch(
      monthlyPensionBalanceNotifierProvider(_selectedYearMonth),
    );

    return AlertDialog(
      title: const Text('연금 월말 평가액 입력'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 기준월 입력창
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

                // 2. 계좌 및 보유 상품 목록
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
                          initialValue: _selectedAccountId,
                          decoration: const InputDecoration(
                            labelText: '입력할 계좌 선택',
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
                        const SizedBox(height: 20),

                        // 선택된 계좌의 등록된 상품들만 조회하여 렌더링
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

                            // 현재 선택된 계좌에 매칭된 보유 상품만 필터링
                            final matchedHoldingProducts = accountProducts
                                .where((ap) => ap.accountId == _selectedAccountId)
                                .toList();

                            if (matchedHoldingProducts.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text('해당 계좌에 매칭된 연금 상품이 없습니다.'),
                              );
                            }

                            final existingBalances =
                                existingBalancesAsync.value ?? [];
                            final balanceMap = {
                              for (var b in existingBalances)
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

                                if (!_balanceControllers.containsKey(key)) {
                                  final existing = balanceMap[key];
                                  final initialVal = existing?.balance ?? 0.0;
                                  _balanceControllers[key] =
                                      TextEditingController(
                                    text: initialVal > 0
                                        ? initialVal.toCommaString()
                                        : '',
                                  );
                                }

                                return Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                productName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '원금: ${holdingItem.principal.toWon()}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 4,
                                          child: TextFormField(
                                            controller: _balanceControllers[key],
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              ThousandsSeparatorInputFormatter(),
                                            ],
                                            decoration: const InputDecoration(
                                              labelText: '월말 평가액',
                                              suffixText: '원',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                          ),
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

    final List<MonthlyPensionBalance> itemsToSave = [];

    for (var holdingItem in matchedHoldingProducts) {
      final prodId = holdingItem.productId;
      final key = '${_selectedAccountId}_$prodId';
      final controller = _balanceControllers[key];

      if (controller != null && controller.text.isNotEmpty) {
        final balanceText =
            controller.text.replaceAll(RegExp(r'[^0-9]'), '').trim();
        final balanceVal = double.tryParse(balanceText) ?? 0.0;

        if (balanceVal > 0) {
          itemsToSave.add(
            MonthlyPensionBalance(
              yearMonth: _selectedYearMonth,
              accountId: _selectedAccountId!,
              productId: prodId,
              balance: balanceVal,
              principal: holdingItem.principal, // 매칭 정보의 원금 자동 연동
              purchaseDate: holdingItem.purchaseDate, // 매칭 정보의 최초 매수일 자동 연동
            ),
          );
        }
      }
    }

    //5개의 상품 데이터를 메모리 상에서 하나의 Batch(장바구니 같은 개념)에 차곡차곡 담습니다
    if (itemsToSave.isNotEmpty) {
      // 배치 처리 저장
      await notifier.saveBatchBalances(itemsToSave);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}