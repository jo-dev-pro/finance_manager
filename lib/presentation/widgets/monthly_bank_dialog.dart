import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/number_formatter.dart';
import '../../models/monthly_bank_balance.dart';
import '../../providers/account_name_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/monthly_bank_balance_provider.dart';

class MonthlyBankDialog extends ConsumerStatefulWidget {
  final String yearMonth;

  const MonthlyBankDialog({super.key, required this.yearMonth});

  @override
  ConsumerState<MonthlyBankDialog> createState() => _MonthlyBankDialogState();
}

class _MonthlyBankDialogState extends ConsumerState<MonthlyBankDialog> {
  late String _selectedYearMonth;
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

    return AlertDialog(
      title: const Text('월말 잔액 일괄 입력'),
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
                  '은행 계좌별 월말 잔액',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 10),
                accountsAsync.when(
                  loading:
                      () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  error: (err, stack) => Text('계좌 목록 불러오기 실패: $err'),
                  data: (accounts) {
                    final bankAccounts =
                        accounts
                            .where((a) => a.accountType.toUpperCase() == '은행')
                            .toList();

                    if (bankAccounts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('등록된 은행 계좌가 없습니다.'),
                      );
                    }

                    final accountNames = accountNamesAsync.value ?? [];

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bankAccounts.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final acc = bankAccounts[index];
                        final accId = acc.id ?? '';

                        // accountNameId 로 계좌명 매핑
                        final matchedName = accountNames.firstWhereOrNull(
                          (an) => an.id == acc.accountNameId,
                        );

                        // FIX: acc.accountName 참조 제거
                        final displayName = matchedName?.accountName ?? '계좌';

                        if (!_controllers.containsKey(accId)) {
                          _controllers[accId] = TextEditingController();
                        }
                        
                        final accNumberDisplay =
                            (acc.accountNumber != null &&
                                    acc.accountNumber!.isNotEmpty)
                                ? ' (${acc.accountNumber})'
                                : '';

                        return TextFormField(
                          controller: _controllers[accId],
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ThousandsSeparatorInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            labelText:
                                '${acc.financialInstitution} - $displayName$accNumberDisplay',
                            suffixText: '원',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
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
          onPressed: () => _saveAllBalances(accountsAsync.value ?? []),
          child: const Text('전체 저장'),
        ),
      ],
    );
  }

  Future<void> _saveAllBalances(List accounts) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(
      monthlyBankBalanceNotifierProvider(_selectedYearMonth).notifier,
    );

    final bankAccounts =
        accounts.where((a) => a.accountType.toUpperCase() == '은행').toList();

    for (var acc in bankAccounts) {
      final accId = acc.id ?? '';
      final controller = _controllers[accId];

      if (controller != null && controller.text.isNotEmpty) {
        final cleanText = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
        final balanceVal = double.tryParse(cleanText) ?? 0.0;

        final newBalanceItem = MonthlyBankBalance(
          yearMonth: _selectedYearMonth,
          accountId: accId,
          balance: balanceVal,
        );

        await notifier.saveBalance(newBalanceItem);
      }
    }

    ref.invalidate(monthlyBankBalanceNotifierProvider(_selectedYearMonth));
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(availableYearMonthsProvider);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
