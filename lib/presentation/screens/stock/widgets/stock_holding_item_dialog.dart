import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
  late TextEditingController _dateController;
  bool _isActive = true;

  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.initialData?.accountId;
    _selectedStockItemId = widget.initialData?.stockItemId;

    _dateController = TextEditingController(
      text: widget.initialData?.initialPurchaseDate ?? '',
    );
    _isActive = widget.initialData?.isActive ?? true;
  }

  @override
  void dispose() {
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

    try {
      final dateText = _dateController.text.trim();

      final item = StockHoldingItem(
        id: widget.initialData?.id,
        accountId: _selectedAccountId!,
        stockItemId: _selectedStockItemId!,
        initialPurchaseDate: dateText.isNotEmpty ? dateText : null,
        isActive: _isActive,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // 💡 바텀시트 레이아웃 안정성 개선 (SafeArea 및 가변 높이 대응)
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 타이틀 및 닫기 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditing ? '계좌별 보유종목 수정' : '계좌별 종목 등록',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: const Text(
                    '💡 안내: 이 화면에서는 계좌별 종목의 [최초 매수일]과 [종료 여부]를 설정합니다.\n'
                    '매월 발생하는 평가액, 보유 수량 및 원금 변동은 [월말 주식 평가액 입력]에서 관리하세요!',
                    style: TextStyle(fontSize: 12, color: Colors.indigoAccent),
                  ),
                ),
                const SizedBox(height: 16),

                // 1. 주식/증권 계좌 선택
                accountsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('계좌 로딩 실패: $err'),
                  data: (accounts) {
                    final accountNames = accountNamesAsync.value ?? [];
                    
                    final targetAccounts = accounts
                        .where(
                          (a) =>
                              a.accountType.toUpperCase().contains('증권') ||
                              a.accountType.toUpperCase().contains('주식'),
                        )
                        .toList()
                      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                    if (targetAccounts.isEmpty) {
                      return const Text('등록된 증권/주식 계좌가 없습니다.');
                    }

                    final accountNameMap = {
                      for (var an in accountNames) an.id: an,
                    };

                    if (_selectedAccountId == null &&
                        targetAccounts.isNotEmpty) {
                      _selectedAccountId = targetAccounts.first.id;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: targetAccounts.any((a) => a.id == _selectedAccountId)
                          ? _selectedAccountId
                          : null,
                      decoration: const InputDecoration(
                        labelText: '증권 계좌 선택',
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

                // 2. 종목 마스터 선택
                stockItemsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('종목 로딩 실패: $err'),
                  data: (stockItems) {
                    if (stockItems.isEmpty) {
                      return const Text('등록된 주식 종목이 없습니다.');
                    }

                    if (_selectedStockItemId == null && stockItems.isNotEmpty) {
                      _selectedStockItemId = stockItems.first.id;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: stockItems.any((s) => s.id == _selectedStockItemId)
                          ? _selectedStockItemId
                          : null,
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

                // 3. 최초 매수일 입력 (마우스 오버 시 흔들림 방지 구조 보완)
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

                // 4. 종료 여부 스위치
                SwitchListTile(
                  title: const Text('보유 종목 매도 완료 (종료)'),
                  subtitle: const Text('전량 매도하여 더 이상 보유하지 않는 경우 체크'),
                  value: _isActive,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setState(() {
                      _isActive = val;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // 5. 하단 등록/수정 액션 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                 child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? '수정하기' : '등록하기',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}