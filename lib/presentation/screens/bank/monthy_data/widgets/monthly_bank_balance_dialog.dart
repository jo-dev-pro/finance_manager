import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/number_formatter.dart';
import '../../../../../core/utils/responsive_extension.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../../../models/account/account.dart';
import '../../../../../models/monthly_data/monthly_bank_balance.dart';
import '../../../../../providers/account/account_name_provider.dart';
import '../../../../../providers/account/account_provider.dart';
import '../../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../../providers/monthly_data/monthly_bank_balance_provider.dart';

class MonthlyBankBalanceDialog extends ConsumerStatefulWidget {
  final String yearMonth;
  final MonthlyBankBalance? editItem;
  final String? accountNameText;

  const MonthlyBankBalanceDialog({
    super.key,
    required this.yearMonth,
    this.editItem,
    this.accountNameText,
  });

  @override
  ConsumerState<MonthlyBankBalanceDialog> createState() =>
      _MonthlyBankBalanceDialogState();
}

class _MonthlyBankBalanceDialogState
    extends ConsumerState<MonthlyBankBalanceDialog> {
  late String _selectedYearMonth;
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    _selectedYearMonth = widget.editItem?.yearMonth ?? widget.yearMonth;
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
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

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountProvider);
    final accountNamesAsync = ref.watch(accountNameProvider);

    final existingCurrentBalancesAsync = ref.watch(
      monthlyBankBalanceProvider(_selectedYearMonth),
    );
    final prevYearMonth = _getPreviousYearMonth(_selectedYearMonth);
    final existingPrevBalancesAsync = ref.watch(
      monthlyBankBalanceProvider(prevYearMonth),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 20, 20, context.bottomInset + 20),
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
                  Text(
                    _isEditing
                        ? '${widget.accountNameText ?? '은행계좌'} 월말내용 수정'
                        : '월말내용 등록',
                    style: const TextStyle(
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
                readOnly: _isEditing,
                decoration: const InputDecoration(
                  labelText: '기준월 (YYYY-MM)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  isDense: true,
                ),
                onChanged: (val) {
                  if (_isEditing) return;
                  setState(() {
                    _selectedYearMonth = val.trim();
                  });
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '기준월을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                _isEditing ? '수정할 월말 잔액' : '은행 계좌별 월말 잔액',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
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
                      _isEditing
                          ? accounts
                              .where((a) => a.id == widget.editItem!.accountId)
                              .toList()
                          : accounts
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
                  final currentBalances =
                      existingCurrentBalancesAsync.value ?? [];
                  final prevBalances = existingPrevBalancesAsync.value ?? [];

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
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final acc = bankAccounts[index];
                      final accId = acc.id ?? '';

                      final matchedName = accountNames.firstWhereOrNull(
                        (an) => an.id == acc.accountNameId,
                      );

                      final displayName = matchedName?.accountName ?? '계좌';

                      if (!_controllers.containsKey(accId)) {
                        final isTargetEdit =
                            _isEditing && widget.editItem!.accountId == accId;
                        final valToSet =
                            isTargetEdit
                                ? widget.editItem!.balance
                                : (currentBalanceMap[accId] ??
                                    prevBalanceMap[accId] ??
                                    0.0);
                        _controllers[accId] = TextEditingController(
                          text: valToSet > 0 ? valToSet.toCommaString() : '',
                        );
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
                  onPressed: () => _saveBalances(accountsAsync.value ?? []),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? '수정하기' : '전체 저장',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBalances(List<Account> accounts) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(
      monthlyBankBalanceProvider(_selectedYearMonth).notifier,
    );
    final accountNotifier = ref.read(accountProvider.notifier);
    final accountNames = ref.read(accountNameProvider).value ?? [];

    final targetAccounts =
        _isEditing
            ? accounts
                .where((a) => a.id == widget.editItem!.accountId)
                .toList()
            : accounts
                .where(
                  (a) =>
                      a.accountType.toUpperCase() == '은행' &&
                      a.status == '활동',
                )
                .toList();

    try {
      for (var acc in targetAccounts) {
        final accId = acc.id ?? '';
        final controller = _controllers[accId];

        if (controller != null && controller.text.isNotEmpty) {
          final cleanText = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
          final balanceVal = double.tryParse(cleanText) ?? 0.0;

          final isTargetEdit =
              _isEditing && widget.editItem!.accountId == accId;

          final balanceItem = MonthlyBankBalance(
            id: isTargetEdit ? widget.editItem!.id : null,
            yearMonth: _selectedYearMonth,
            accountId: accId,
            balance: balanceVal,
          );
          await notifier.saveBalance(balanceItem);

          final matchedName = accountNames.firstWhereOrNull(
            (an) => an.id.toString() == acc.accountNameId.toString(),
          );
          final productName = matchedName?.accountName ?? '';

          if (productName != '입출금' && balanceVal <= 0.0) {
            await accountNotifier.updateAccountStatus(accId, '비활동');
          }
        }
      }

      ref.invalidate(monthlyBankBalanceProvider(_selectedYearMonth));
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(availableYearMonthsProvider);

      if (!mounted) return;
      Navigator.pop(context);
      AppSnackBar.showInfo(
        context,
        _isEditing ? '월말 잔액이 수정되었습니다.' : '월말 잔액이 성공적으로 저장되었습니다.',
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, '저장 실패: $e');
    }
  }
}