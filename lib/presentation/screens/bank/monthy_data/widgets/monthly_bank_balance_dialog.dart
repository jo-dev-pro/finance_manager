import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; 

import '../../../../../core/utils/number_formatter.dart';
import '../../../../../models/monthly_data/monthly_bank_balance.dart';
import '../../../../../models/account/account.dart';
import '../../../../../providers/account/account_name_provider.dart';
import '../../../../../providers/account/account_provider.dart';
import '../../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../../providers/monthly_data/monthly_bank_balance_provider.dart';

class MonthlyBankBalanceDialog extends ConsumerStatefulWidget {
  final String yearMonth;

  const MonthlyBankBalanceDialog({super.key, required this.yearMonth});

  @override
  ConsumerState<MonthlyBankBalanceDialog> createState() => _MonthlyBankBalanceDialogState();
}

class _MonthlyBankBalanceDialogState extends ConsumerState<MonthlyBankBalanceDialog> {
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

  // 📌 이전 달 연월 구하기 메서드 추가
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
    
    // 📌 현재 및 이전 달 잔액 프로바이더 감시
    final existingCurrentBalancesAsync = ref.watch(
      monthlyBankBalanceNotifierProvider(_selectedYearMonth),
    );
    final prevYearMonth = _getPreviousYearMonth(_selectedYearMonth);
    final existingPrevBalancesAsync = ref.watch(
      monthlyBankBalanceNotifierProvider(prevYearMonth),
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
                    '월말 잔액 일괄 입력',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                  labelText: '기준월 (YYYY-MM)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  isDense: true,
                ),
                onChanged: (val) {
                  setState(() {
                    _selectedYearMonth = val.trim();
                  });
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
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Text('계좌 목록 불러오기 실패: $err'),
                data: (accounts) {
                  final bankAccounts = accounts
                      .where(
                        (a) =>
                            a.accountType.toUpperCase() == '은행' &&
                            a.status == '활동',
                      )
                      .toList();

                  if (bankAccounts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('입력 가능한 활동 은행 계좌가 없습니다.'),
                    );
                  }

                  final accountNames = accountNamesAsync.value ?? [];
                  final currentBalances = existingCurrentBalancesAsync.value ?? [];
                  final prevBalances = existingPrevBalancesAsync.value ?? [];

                  // 📌 계좌별 잔액 맵 생성
                  final currentBalanceMap = {
                    for (var b in currentBalances) b.accountId: b.balance,
                  };
                  final prevBalanceMap = {
                    for (var b in prevBalances) b.accountId: b.balance,
                  };

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bankAccounts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final acc = bankAccounts[index];
                      final accId = acc.id ?? '';

                      final matchedName = accountNames.firstWhereOrNull(
                        (an) => an.id == acc.accountNameId,
                      );

                      final displayName = matchedName?.accountName ?? '계좌';

                      // 📌 컨트롤러 초기화 시 현재값 또는 지난달값 기본 세팅
                      if (!_controllers.containsKey(accId)) {
                        final valToSet = currentBalanceMap[accId] ?? prevBalanceMap[accId] ?? 0.0;
                        _controllers[accId] = TextEditingController(
                          text: valToSet > 0 ? valToSet.toCommaString() : '',
                        );
                      }

                      final accNumberDisplay = (acc.accountNumber != null &&
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
                          isDense: true,
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
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _saveAllBalances(accountsAsync.value ?? []),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('전체 저장', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAllBalances(List<dynamic> rawAccounts) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(
      monthlyBankBalanceNotifierProvider(_selectedYearMonth).notifier,
    );
    final accountNotifier = ref.read(accountNotifierProvider.notifier);
    final accountNames = ref.read(accountNameNotifierProvider).value ?? [];

    final bankAccounts = rawAccounts
        .where((a) => a is Account && a.accountType.toUpperCase() == '은행')
        .cast<Account>()
        .toList();

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

        final matchedName = accountNames.firstWhereOrNull(
          (an) => an.id.toString() == acc.accountNameId.toString(),
        );
        final productName = matchedName?.accountName ?? '';

        if (productName != '입출금' && balanceVal <= 0.0) {
          await accountNotifier.updateAccountStatus(accId, '비활동');
        }
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