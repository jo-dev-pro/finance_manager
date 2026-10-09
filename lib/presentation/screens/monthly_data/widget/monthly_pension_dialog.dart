import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/account/account.dart';
import '../../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../../models/pension/pension_product.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';
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
  // Key 구조: "${accountId}_${productId ?? 'cash'}"
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedYearMonth = widget.yearMonth;
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);

    return AlertDialog(
      title: const Text('월말 연금 잔액 일괄 입력'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _selectedYearMonth,
                  decoration: const InputDecoration(
                    labelText: '기준월 (YYYY-MM)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onChanged: (val) => _selectedYearMonth = val.trim(),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return '기준월을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  '계좌 및 상품별 월말 평가금액',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 10),

                accountsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, stack) => Text('계좌 목록 불러오기 실패: $err'),
                  data: (accounts) {
                    // 연금 계좌만 필터링
                    final pensionAccounts = accounts
                        .where((a) => a.accountType.toUpperCase() == '연금')
                        .toList();

                    if (pensionAccounts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('등록된 연금 계좌가 없습니다.'),
                      );
                    }

                    final accountNames = accountNamesAsync.value ?? [];
                    final products = productsAsync.value ?? [];

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pensionAccounts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final acc = pensionAccounts[index];
                        final accId = acc.id ?? '';

                        final matchedName = accountNames.firstWhereOrNull(
                          (an) => an.id == acc.accountNameId,
                        );
                        final displayName = matchedName?.accountName ?? '계좌';

                        // 💡 1. 현금성 자산(상품 미지정)용 컨트롤러
                        final cashKey = '${accId}_cash';
                        if (!_controllers.containsKey(cashKey)) {
                          _controllers[cashKey] = TextEditingController();
                        }

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 계좌 헤더
                              Text(
                                '${acc.financialInstitution} - $displayName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // 현금/예금 잔액 입력
                              TextFormField(
                                controller: _controllers[cashKey],
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  ThousandsSeparatorInputFormatter(),
                                ],
                                decoration: const InputDecoration(
                                  labelText: '현금성 자산 / 예수금',
                                  suffixText: '원',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // 💡 2. 등록된 상품들 입력 폼
                              ...products.map((prod) {
                                final prodId = prod.id ?? '';
                                final prodKey = '${accId}_$prodId';

                                if (!_controllers.containsKey(prodKey)) {
                                  _controllers[prodKey] =
                                      TextEditingController();
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextFormField(
                                    controller: _controllers[prodKey],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      ThousandsSeparatorInputFormatter(),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: prod.productName,
                                      suffixText: '원',
                                      isDense: true,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
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
          onPressed: () => _saveAllBalances(
            accountsAsync.value ?? [],
            productsAsync.value ?? [],
          ),
          child: const Text('전체 저장'),
        ),
      ],
    );
  }

  Future<void> _saveAllBalances(
    List<Account> accounts,
    List<PensionProduct> products,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(
      monthlyPensionBalanceNotifierProvider(_selectedYearMonth).notifier,
    );

    final pensionAccounts = accounts
        .where((a) => a.accountType.toUpperCase() == '연금')
        .toList();

    for (var acc in pensionAccounts) {
      final accId = acc.id ?? '';

      // 1. 현금성 자산 저장 (productId = null)
      final cashKey = '${accId}_cash';
      final cashController = _controllers[cashKey];
      if (cashController != null && cashController.text.isNotEmpty) {
        final cleanText =
            cashController.text.replaceAll(RegExp(r'[^0-9]'), '');
        final balanceVal = double.tryParse(cleanText) ?? 0.0;

        final newBalanceItem = MonthlyPensionBalance(
          yearMonth: _selectedYearMonth,
          financialInstitution: acc.financialInstitution,
          accountId: accId,
          productId: null,
          evaluationAmount: balanceVal,
        );
        await notifier.saveBalance(newBalanceItem);
      }

      // 2. 계좌 내 보유 상품별 평가금액 저장
      for (var prod in products) {
        final prodId = prod.id ?? '';
        final prodKey = '${accId}_$prodId';
        final prodController = _controllers[prodKey];

        if (prodController != null && prodController.text.isNotEmpty) {
          final cleanText =
              prodController.text.replaceAll(RegExp(r'[^0-9]'), '');
          final balanceVal = double.tryParse(cleanText) ?? 0.0;

          final newBalanceItem = MonthlyPensionBalance(
            yearMonth: _selectedYearMonth,
            financialInstitution: acc.financialInstitution,
            accountId: accId,
            productId: prodId,
            evaluationAmount: balanceVal,
          );
          await notifier.saveBalance(newBalanceItem);
        }
      }
    }

    ref.invalidate(monthlyPensionBalanceNotifierProvider(_selectedYearMonth));
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(availableYearMonthsProvider);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}