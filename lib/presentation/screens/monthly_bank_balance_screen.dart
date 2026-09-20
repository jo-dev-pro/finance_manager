import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../models/monthly_bank_balance.dart';
import '../../providers/account_provider.dart';
import '../../providers/monthly_bank_balance_provider.dart';

class MonthlyBankBalanceScreen extends ConsumerStatefulWidget {
  const MonthlyBankBalanceScreen({super.key});

  @override
  ConsumerState<MonthlyBankBalanceScreen> createState() =>
      _MonthlyBankBalanceScreenState();
}

class _MonthlyBankBalanceScreenState
    extends ConsumerState<MonthlyBankBalanceScreen> {
  String _selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  final _currencyFormatter = NumberFormat('#,###', 'ko_KR');

  @override
  Widget build(BuildContext context) {
    final balanceAsync =
        ref.watch(monthlyBankBalanceNotifierProvider(_selectedYearMonth));

    return Scaffold(
      appBar: AppBar(
        title: Text('월말 잔액 관리 ($_selectedYearMonth)'),
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
            return const Center(child: Text('등록된 월말 잔액 데이터가 없습니다.'));
          }

          // 총 잔액 계산
          final double totalBalance =
              balances.fold(0.0, (sum, item) => sum + item.balance);

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
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedYearMonth 월말 합계',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                              // 계좌 아이콘
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade50,
                                child: Icon(
                                  Icons.account_balance,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // 계좌명 및 금융기관
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.accountName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.financialInstitution,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 금액 및 수정/삭제 버튼
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${_currencyFormatter.format(item.balance)} 원',
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
                                        icon: const Icon(Icons.edit,
                                            size: 20, color: Colors.grey),
                                        onPressed: () =>
                                            _showEditDialog(context, item),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                        icon: const Icon(Icons.delete,
                                            size: 20, color: Colors.redAccent),
                                        onPressed: () =>
                                            _confirmDelete(context, item),
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

  // 연월 선택 피커
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

  // 잔액 수정 팝업 (세 자리 콤마 적용)
  void _showEditDialog(BuildContext context, MonthlyBankBalance item) {
    // 초기값에도 세 자리 콤마 적용
    final controller = TextEditingController(
      text: _currencyFormatter.format(item.balance),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${item.accountName} 금액 수정'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorInputFormatter(), // 공통 포맷터 적용
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
              // 콤마 제거 후 double로 정확히 파싱
              final cleanText =
                  controller.text.replaceAll(RegExp(r'[^0-9]'), '');
              final newBalance = double.tryParse(cleanText) ?? 0.0;

              final updatedItem = item.copyWith(balance: newBalance);
              await ref
                  .read(monthlyBankBalanceNotifierProvider(_selectedYearMonth)
                      .notifier)
                  .saveBalance(updatedItem);

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  // 삭제 확인 팝업
  void _confirmDelete(BuildContext context, MonthlyBankBalance item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content:
            Text('${item.accountName}의 $_selectedYearMonth 월말 데이터를 삭제하시겠습니까?'),
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
                    .read(monthlyBankBalanceNotifierProvider(_selectedYearMonth)
                        .notifier)
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

  // 추가 입력 바텀시트
  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddBalanceForm(yearMonth: _selectedYearMonth),
    );
  }
}

// 신규 입력용 BottomSheet 위젯
class _AddBalanceForm extends ConsumerStatefulWidget {
  final String yearMonth;
  const _AddBalanceForm({required this.yearMonth});

  @override
  ConsumerState<_AddBalanceForm> createState() => _AddBalanceFormState();
}

class _AddBalanceFormState extends ConsumerState<_AddBalanceForm> {
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
                '${widget.yearMonth} 월말 잔액 일괄 입력',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                // 살아있는(활성화된) 은행 계좌만 필터링
                final activeAccounts = accounts.where((acc) {
                  final isBank = acc.accountType.toUpperCase() == '은행';
                  final isActive = acc.status == '활동';
                  return isBank && isActive;
                }).toList();

                if (activeAccounts.isEmpty) {
                  return const Center(child: Text('입력 가능한 은행 계좌가 없습니다.'));
                }

                return ListView.builder(
                  itemCount: activeAccounts.length,
                  itemBuilder: (context, index) {
                    final acc = activeAccounts[index];
                    _controllers.putIfAbsent(
                      acc.accountName,
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
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  acc.financialInstitution,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _controllers[acc.accountName],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.end,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                ThousandsSeparatorInputFormatter(), // 공통 포맷터 적용
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
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final notifier = ref.read(
                monthlyBankBalanceNotifierProvider(widget.yearMonth).notifier,
              );

              final accounts = ref.read(accountNotifierProvider).value ?? [];

              for (var entry in _controllers.entries) {
                final rawText = entry.value.text;

                if (rawText.trim().isNotEmpty) {
                  final cleanText = rawText.replaceAll(RegExp(r'[^0-9]'), '');

                  if (cleanText.isNotEmpty) {
                    final balanceVal = double.tryParse(cleanText) ?? 0.0;
                    final targetAcc = accounts.firstWhere(
                      (a) => a.accountName == entry.key,
                    );

                    final newBalanceItem = MonthlyBankBalance(
                      yearMonth: widget.yearMonth,
                      financialInstitution: targetAcc.financialInstitution,
                      accountName: targetAcc.accountName,
                      balance: balanceVal,
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