import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../core/utils/formatters.dart';
import '../../models/monthly_pension_balance.dart';
import '../../providers/account_provider.dart';
import '../../providers/monthly_pension_balance_provider.dart';

class MonthlyPensionBalanceScreen extends ConsumerStatefulWidget {
  const MonthlyPensionBalanceScreen({super.key});

  @override
  ConsumerState<MonthlyPensionBalanceScreen> createState() =>
      _MonthlyPensionBalanceScreenState();
}

class _MonthlyPensionBalanceScreenState
    extends ConsumerState<MonthlyPensionBalanceScreen> {
  String _selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  final _currencyFormatter = NumberFormat('#,###', 'ko_KR');

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(
      monthlyPensionBalanceNotifierProvider(_selectedYearMonth),
    );
    final accountsAsync = ref.watch(accountNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('연금 월말 잔액 관리 ($_selectedYearMonth)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectYearMonth(context),
          ),
        ],
      ),
      body: balanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
        data: (balances) {
          if (balances.isEmpty) {
            return const Center(child: Text('등록된 월말 연금 데이터가 없습니다.'));
          }

          final accounts = accountsAsync.value ?? [];

          // 총 연금 잔액 계산
          final double totalBalance = balances.fold(
            0.0,
            (sum, item) => sum + item.evaluationAmount,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 월말 총액 카드
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade600,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedYearMonth 월말 연금 합계',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_currencyFormatter.format(totalBalance)} 원',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 계좌별 월말 잔액 카드 리스트
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: balances.length,
                  itemBuilder: (context, index) {
                    final item = balances[index];
                   final matchedAccount = accounts.firstWhereOrNull((a) => a.id == item.accountId);

                    final displayAccountName = matchedAccount?.accountName ?? item.accountId;
                    final displayInstitution = matchedAccount?.financialInstitution ?? item.financialInstitution;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.indigo.shade50,
                                child: Icon(
                                  Icons.savings,
                                  color: Colors.indigo.shade700,
                                ),
                              ),
                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayAccountName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    if (displayInstitution != null && displayInstitution.isNotEmpty)
                                      Text(
                                        displayInstitution,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${_currencyFormatter.format(item.evaluationAmount)} 원',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () =>
                                            _showEditDialog(context, item, displayAccountName),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () =>
                                            _confirmDelete(context, item, displayAccountName),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('월말 잔액 추가 입력', style: TextStyle(fontSize: 16)),
            onPressed: () => _showAddBottomSheet(context),
          ),
        ),
      ),
    );
  }

  Future<void> _selectYearMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse('$_selectedYearMonth-01'),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedYearMonth = DateFormat('yyyy-MM').format(picked);
      });
    }
  }

  void _showEditDialog(BuildContext context, MonthlyPensionBalance item, String accountName) {
    final controller = TextEditingController(
      text: _currencyFormatter.format(item.evaluationAmount),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$accountName 금액 수정'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorInputFormatter(),
          ],
          decoration: const InputDecoration(
            labelText: '금액 (원)',
            suffixText: '원',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final cleanText = controller.text.replaceAll(
                RegExp(r'[^0-9]'),
                '',
              );
              final newBalance = double.tryParse(cleanText) ?? 0.0;

              final updatedItem = item.copyWith(evaluationAmount: newBalance);
              await ref
                  .read(
                    monthlyPensionBalanceNotifierProvider(
                      _selectedYearMonth,
                    ).notifier,
                  )
                  .saveBalance(updatedItem);

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MonthlyPensionBalance item, String accountName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text(
          '$accountName의 $_selectedYearMonth 월말 데이터를 삭제하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (item.id != null) {
                await ref
                    .read(
                      monthlyPensionBalanceNotifierProvider(
                        _selectedYearMonth,
                      ).notifier,
                    )
                    .deleteBalance(item.id!);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          _AddPensionBalanceForm(yearMonth: _selectedYearMonth),
    );
  }
}

class _AddPensionBalanceForm extends ConsumerStatefulWidget {
  final String yearMonth;
  const _AddPensionBalanceForm({required this.yearMonth});

  @override
  ConsumerState<_AddPensionBalanceForm> createState() =>
      _AddPensionBalanceFormState();
}

class _AddPensionBalanceFormState
    extends ConsumerState<_AddPensionBalanceForm> {
  final Map<String, TextEditingController> _controllers = {};

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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.yearMonth} 월말 연금 잔액 일괄 입력',
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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: accountsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('계좌 목록 오류: $err')),
              data: (accounts) {
                final activeAccounts = accounts.where((acc) {
                  final isPension = acc.accountType.toUpperCase() == '연금';
                  final isActive = acc.status == '활동';
                  return isPension && isActive;
                }).toList();

                if (activeAccounts.isEmpty) {
                  return const Center(child: Text('입력 가능한 연금 계좌가 없습니다.'));
                }

                return ListView.builder(
                  itemCount: activeAccounts.length,
                  itemBuilder: (context, index) {
                    final acc = activeAccounts[index];
                    final accId = acc.id ?? '';
                    _controllers.putIfAbsent(
                      accId,
                      () => TextEditingController(),
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  acc.accountName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  acc.financialInstitution,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _controllers[accId],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.end,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                ThousandsSeparatorInputFormatter(),
                              ],
                              decoration: const InputDecoration(
                                hintText: '0',
                                suffixText: '원',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final notifier = ref.read(
                monthlyPensionBalanceNotifierProvider(
                  widget.yearMonth,
                ).notifier,
              );

              final accounts = ref.read(accountNotifierProvider).value ?? [];

              for (var entry in _controllers.entries) {
                final accountId = entry.key;
                final rawText = entry.value.text;

                if (rawText.trim().isNotEmpty) {
                  final cleanText = rawText.replaceAll(RegExp(r'[^0-9]'), '');

                  if (cleanText.isNotEmpty) {
                    final balanceVal = double.tryParse(cleanText) ?? 0.0;
                    final targetAcc = accounts.firstWhere(
                      (a) => a.id == accountId,
                      orElse: () => null as dynamic,
                    );

                    final newBalanceItem = MonthlyPensionBalance(
                      yearMonth: widget.yearMonth,
                      financialInstitution: targetAcc.financialInstitution,
                      accountId: accountId, // 👈 accountName 대신 accountId 바인딩
                      evaluationAmount: balanceVal,
                    );

                    await notifier.saveBalance(newBalanceItem);
                  }
                }
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('일괄 저장', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}