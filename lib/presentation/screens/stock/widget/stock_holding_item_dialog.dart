import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/stock/stock_holding_item.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/stock/stock_holding_item_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';

class StockHoldingItemDialog extends ConsumerStatefulWidget {
  final StockHoldingItem? initialData;

  const StockHoldingItemDialog({super.key, this.initialData});

  @override
  ConsumerState<StockHoldingItemDialog> createState() =>
      _StockHoldingItemDialogState();
}

class _StockHoldingItemDialogState
    extends ConsumerState<StockHoldingItemDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedAccountId;
  String? _selectedStockItemId;
  late TextEditingController _principalController;
  late TextEditingController _dateController;
  bool _isTerminated = false;

  bool _isSubmitting = false;
  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.initialData?.accountId;
    _selectedStockItemId = widget.initialData?.stockItemId;

    _principalController = TextEditingController(
      text: widget.initialData != null && widget.initialData!.principal > 0
          ? widget.initialData!.principal.toCommaString()
          : '',
    );
    _dateController = TextEditingController(
      text: widget.initialData?.purchaseDate ?? '',
    );
    _isTerminated = widget.initialData?.isTerminated ?? false;
  }

  @override
  void dispose() {
    _principalController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null || _selectedStockItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계좌와 종목을 모두 선택해 주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final cleanPrincipal = _principalController.text
          .replaceAll(RegExp(r'[^0-9]'), '')
          .trim();
      final principalVal = double.tryParse(cleanPrincipal) ?? 0.0;
      final dateText = _dateController.text.trim();

      final item = StockHoldingItem(
        id: widget.initialData?.id,
        accountId: _selectedAccountId!,
        stockItemId: _selectedStockItemId!,
        principal: principalVal,
        purchaseDate: dateText.isNotEmpty ? dateText : null,
        isTerminated: _isTerminated,
      );

      final notifier = ref.read(stockHoldingItemNotifierProvider.notifier);
      if (_isEditing) {
        await notifier.updateStockHoldingItem(item);
      } else {
        await notifier.addStockHoldingItem(item);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);
    final holdingItemsAsync = ref.watch(stockHoldingItemNotifierProvider);

    final existingList = holdingItemsAsync.value ?? [];
    final bool isAlreadyExists = existingList.any((item) =>
        item.accountId == _selectedAccountId &&
        item.stockItemId == _selectedStockItemId &&
        (!_isEditing || item.id != widget.initialData?.id));

    return AlertDialog(
      title: Text(_isEditing ? '계좌별 보유종목 수정' : '계좌별 종목 등록'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 안내 가이드 박스
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: const Text(
                    '💡 안내: 이 화면에서는 종목의 [초기 투자 원금]과 [최초 매수일]을 등록합니다.\n'
                    '매월 발생하는 평가액 및 수량 변동은 [월말 주식 평가액 입력]에서 관리해 주세요!',
                    style: TextStyle(fontSize: 12, color: Colors.indigoAccent),
                  ),
                ),
                const SizedBox(height: 16),

                // 1. 주식 계좌 선택
                accountsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('계좌 로딩 실패: $err'),
                  data: (accounts) {
                    final accountNames = accountNamesAsync.value ?? [];
                    // 주식 계좌 필터링 (계좌 타입이 '주식'인 항목 중심, 필요시 조건 조정 가능)
                    final stockAccounts = accounts
                        .where(
                          (a) =>
                              a.accountType.toUpperCase() == '주식' &&
                              a.status == '활동',
                        )
                        .toList()
                      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                    // 만약 '주식' 타입 계좌가 없다면 전체 활동 계좌를 보여주거나 유연하게 처리
                    final targetAccounts = stockAccounts.isNotEmpty
                        ? stockAccounts
                        : accounts.where((a) => a.status == '활동').toList();

                    if (targetAccounts.isEmpty) {
                      return const Text('활동 중인 주식 계좌가 없습니다.');
                    }

                    final accountNameMap = {
                      for (var an in accountNames) an.id: an,
                    };

                    if (_selectedAccountId == null &&
                        targetAccounts.isNotEmpty) {
                      _selectedAccountId = targetAccounts.first.id;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedAccountId,
                      decoration: const InputDecoration(
                        labelText: '주식 계좌 선택',
                        border: OutlineInputBorder(),
                      ),
                      items: targetAccounts.map((acc) {
                        final institution = acc.financialInstitution;
                        final nameObj = accountNameMap[acc.accountNameId];
                        return DropdownMenuItem(
                          value: acc.id,
                          child: Text(
                            '$institution - ${nameObj?.accountName ?? '계좌'}',
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAccountId = val;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 2. 종목 마스터 선택 (StockItem)
                stockItemsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('종목 로딩 실패: $err'),
                  data: (stockItems) {
                    if (stockItems.isEmpty) {
                      return const Text('등록된 주식 종목이 없습니다. 종목 DB를 먼저 추가해 주세요.');
                    }

                    if (_selectedStockItemId == null && stockItems.isNotEmpty) {
                      _selectedStockItemId = stockItems.first.id;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedStockItemId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '종목 선택',
                        border: OutlineInputBorder(),
                      ),
                      items: stockItems.map((stock) {
                        return DropdownMenuItem(
                          value: stock.id,
                          child: Text(
                            '${stock.itemName} (${stock.stockCode})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedStockItemId = val;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 3. 투자 원금 입력
                TextFormField(
                  controller: _principalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: isAlreadyExists ? '추가 투자 원금' : '초기 투자 원금',
                    hintText: '투자 원금 입력',
                    suffixText: '원',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return '원금을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 4. 최초 매수일 입력 (기존 등록된 날짜 초기 포커싱 반영)
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: '최초 매수일',
                    hintText: 'YYYY-MM-DD',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    DateTime initialDate = DateTime.now();
                    if (_dateController.text.trim().isNotEmpty) {
                      try {
                        initialDate = DateFormat('yyyy-MM-dd')
                            .parse(_dateController.text.trim());
                      } catch (_) {
                        initialDate = DateTime.now();
                      }
                    }

                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _dateController.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                      });
                    }
                  },
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return '최초 매수일을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 5. 전량 매도/종료 여부 스위치
                SwitchListTile(
                  title: const Text('보유 종목 매도 완료 (종료)'),
                  subtitle: const Text('전량 매도하여 더 이상 보유하지 않는 경우 체크'),
                  value: _isTerminated,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setState(() {
                      _isTerminated = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? '수정' : '등록'),
        ),
      ],
    );
  }
}