import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';
import '../../../../providers/pension/pension_transaction_provider.dart';
import '../../../../providers/pension/pension_transaction_type_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';

class MonthlyPensionDialog extends ConsumerStatefulWidget {
  final String yearMonth;

  const MonthlyPensionDialog({super.key, required this.yearMonth});

  @override
  ConsumerState<MonthlyPensionDialog> createState() => _MonthlyPensionDialogState();
}

class _MonthlyPensionDialogState extends ConsumerState<MonthlyPensionDialog> {
  late String _selectedYearMonth;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _itemAccountMap = {};
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
    final productsAsync = ref.watch(pensionProductNotifierProvider);
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final transactionsAsync = ref.watch(pensionTransactionNotifierProvider);
    final typesAsync = ref.watch(pensionTransactionTypeNotifierProvider);

    return AlertDialog(
      title: const Text('연금 월말 평가액 일괄 입력'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
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
                  onChanged: (val) {
                    _selectedYearMonth = val.trim();
                  },
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return '기준월을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  '계좌별 보유 상품 평가액 입력',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                productsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, stack) => Text('상품 목록 불러오기 실패: $err'),
                  data: (products) {
                    return accountsAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) => Text('계좌 로딩 실패: $err'),
                      data: (accounts) {
                        return transactionsAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (err, _) => Text('거래내역 로딩 실패: $err'),
                          data: (transactions) {
                            final types = typesAsync.value ?? [];
                            final accountNames = accountNamesAsync.value ?? [];
                            
                            // 거래구분별 sign 맵 생성 (PLUS / MINUS)
                            final signMap = {for (var t in types) t.id ?? '': t.amountSign};

                            // '활동' 상태인 연금 계좌 ID 추출
                            final activePensionAccountIds = accounts
                                .where((a) => a.accountType.toUpperCase() == '연금' && a.status == '활동')
                                .map((a) => a.id!)
                                .toSet();

                            final accountMap = {for (var a in accounts) a.id!: a};
                            final accountNameMap = {for (var an in accountNames) an.id: an};
                            final productMap = {for (var p in products) p.id!: p};

                            // 1. 계좌별로 상품별 순 원금 및 보유 여부 집계
                            // Map<accountId, Map<productId, principal>>
                            final Map<String, Map<String, double>> accountProductPrincipals = {};

                            for (var t in transactions) {
                              if (activePensionAccountIds.contains(t.accountId) &&
                                  t.productId != null &&
                                  t.productId!.isNotEmpty) {
                                final sign = signMap[t.transactionTypeId] ?? 'PLUS';
                                final signedAmount = (sign == 'MINUS') ? -t.amount : t.amount;

                                accountProductPrincipals
                                    .putIfAbsent(t.accountId, () => {})
                                    .update(t.productId!, (val) => val + signedAmount, ifAbsent: () => signedAmount);
                              }
                            }

                            if (accountProductPrincipals.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text('입력 가능한 활동 중인 연금 보유 상품이 없습니다.'),
                              );
                            }

                            // 2. 계좌 단위로 그룹화하여 UI 렌더링 구성
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: accountProductPrincipals.keys.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 20),
                              itemBuilder: (context, index) {
                                final accountId = accountProductPrincipals.keys.elementAt(index);
                                final productMapForAccount = accountProductPrincipals[accountId]!;

                                final account = accountMap[accountId];
                                if (account == null) return const SizedBox.shrink();

                                final institution = account.financialInstitution;
                                final accountNameObj = accountNameMap[account.accountNameId];
                                final accountNameDisplay = accountNameObj?.accountName ?? '계좌';

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 💡 계좌 타이틀 영역
                                      Row(
                                        children: [
                                          const Icon(Icons.account_balance_wallet, size: 18, color: Colors.indigo),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$institution - $accountNameDisplay',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      
                                      // 해당 계좌가 보유한 상품 리스트
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: productMapForAccount.keys.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                                        itemBuilder: (context, prodIndex) {
                                          final prodId = productMapForAccount.keys.elementAt(prodIndex);
                                          final principal = productMapForAccount[prodId] ?? 0.0;
                                          final product = productMap[prodId];

                                          if (product == null) return const SizedBox.shrink();

                                          final key = '${accountId}_$prodId';
                                          _itemAccountMap[key] = accountId;

                                          if (!_controllers.containsKey(key)) {
                                            _controllers[key] = TextEditingController();
                                          }

                                          return TextFormField(
                                            controller: _controllers[key],
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                              ThousandsSeparatorInputFormatter(),
                                            ],
                                            decoration: InputDecoration(
                                              labelText: product.productName,
                                              // 💡 상품별 원금 안내
                                              helperText: '투자 원금: ${principal.toWon()}',
                                              suffixText: '원',
                                              border: const OutlineInputBorder(),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 12,
                                              ),
                                            ),
                                          );
                                        },
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
          onPressed: _saveAllBalances,
          child: const Text('전체 저장'),
        ),
      ],
    );
  }

  Future<void> _saveAllBalances() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(
      monthlyPensionBalanceNotifierProvider(_selectedYearMonth).notifier,
    );

    for (var entry in _controllers.entries) {
      final key = entry.key; // "accountId_productId"
      final controller = entry.value;
      final accountId = _itemAccountMap[key];

      final parts = key.split('_');
      if (parts.length == 2 && accountId != null && controller.text.isNotEmpty) {
        final prodId = parts[1];
        final cleanText = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
        final balanceVal = double.tryParse(cleanText) ?? 0.0;

        final newBalanceItem = MonthlyPensionBalance(
          yearMonth: _selectedYearMonth,
          accountId: accountId,
          productId: prodId,
          balance: balanceVal,
        );
        await notifier.saveBalance(newBalanceItem);
      }
    }

    ref.invalidate(monthlyPensionBalanceNotifierProvider(_selectedYearMonth));
    ref.invalidate(allMonthlyPensionBalancesProvider);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}