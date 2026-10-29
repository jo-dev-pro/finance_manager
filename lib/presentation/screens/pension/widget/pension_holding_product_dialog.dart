import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_helper.dart'; // 💡 DateHelper 임포트 추가
import '../../../../core/utils/number_formatter.dart';
import '../../../../models/pension/pension_holding_product.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/pension/pension_holding_product_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';

class PensionHoldingProductDialog extends ConsumerStatefulWidget {
  final PensionHoldingProduct? initialData;

  const PensionHoldingProductDialog({super.key, this.initialData});

  @override
  ConsumerState<PensionHoldingProductDialog> createState() =>
      _PensionHoldingProductDialogState();
}

class _PensionHoldingProductDialogState
    extends ConsumerState<PensionHoldingProductDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedAccountId;
  String? _selectedProductId;
  late TextEditingController _principalController;
  late TextEditingController _dateController;
  bool _isTerminated = false;

  bool _isSubmitting = false;
  bool get _isEditing => widget.initialData != null;

  DateTime _selectedDate = DateTime.now(); // 💡 선택된 날짜 관리 변수 추가

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.initialData?.accountId;
    _selectedProductId = widget.initialData?.productId;

    _principalController = TextEditingController(
      text: widget.initialData != null && widget.initialData!.principal > 0
          ? widget.initialData!.principal.toCommaString()
          : '',
    );

    // 날짜 초기값 설정
    if (widget.initialData?.purchaseDate != null &&
        widget.initialData!.purchaseDate!.isNotEmpty) {
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.initialData!.purchaseDate!);
      } catch (_) {
        _selectedDate = DateTime.now();
      }
    }
    
    _dateController = TextEditingController(
      text: DateHelper.formatToDate(_selectedDate),
    );
    
    _isTerminated = widget.initialData?.isTerminated ?? false;
  }

  @override
  void dispose() {
    _principalController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // 💡 DateHelper를 활용한 날짜 피커 메서드
  Future<void> _pickDate() async {
    final picked = await DateHelper.pickDate(
      context,
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateHelper.formatToDate(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null || _selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계좌와 상품을 모두 선택해 주세요.')),
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

      final item = PensionHoldingProduct(
        id: widget.initialData?.id,
        accountId: _selectedAccountId!,
        productId: _selectedProductId!,
        principal: principalVal,
        totalPayout: 0.0,
        purchaseDate: dateText.isNotEmpty ? dateText : null,
        isTerminated: _isTerminated,
      );

      final notifier = ref.read(pensionHoldingProductNotifierProvider.notifier);
      if (_isEditing) {
        await notifier.updatePensionHoldingProduct(item);
      } else {
        await notifier.addPensionHoldingProduct(item);
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
    final productsAsync = ref.watch(pensionProductNotifierProvider);
    final holdingProductsAsync = ref.watch(
      pensionHoldingProductNotifierProvider,
    );

    final existingHoldingList = holdingProductsAsync.value ?? [];
    final bool isAlreadyExists = existingHoldingList.any(
      (item) =>
          item.accountId == _selectedAccountId &&
          item.productId == _selectedProductId &&
          (!_isEditing || item.id != widget.initialData?.id),
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
              // 상단 헤더 (타이틀 + 닫기 버튼)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? '계좌별 보유상품 수정' : '계좌별 상품 등록',
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

              // 안내 가이드 박스
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Text(
                  '💡 안내: 이 화면에서는 상품의 [초기 투자 원금]과 [매수일]을 등록합니다.\n'
                  '매월 발생하는 추가 투자, 연금 수령액, 중도 인출금은 [월말 연금 입력] 다이얼로그에서 입력해 주세요!',
                  style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 16),

              // 1. 연금 계좌 선택
              accountsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('계좌 로딩 실패: $err'),
                data: (accounts) {
                  final accountNames = accountNamesAsync.value ?? [];
                  final pensionAccounts = accounts
                      .where(
                        (a) =>
                            a.accountType.toUpperCase() == '연금' &&
                            a.status == '활동',
                      )
                      .toList()
                    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                  if (pensionAccounts.isEmpty) {
                    return const Text('활동 중인 연금 계좌가 없습니다.');
                  }

                  final accountNameMap = {
                    for (var an in accountNames) an.id: an,
                  };

                  if (_selectedAccountId == null &&
                      pensionAccounts.isNotEmpty) {
                    _selectedAccountId = pensionAccounts.first.id;
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: '연금 계좌 선택',
                      border: OutlineInputBorder(),
                    ),
                    items: pensionAccounts.map((acc) {
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

              // 2. 공용 상품 선택
              productsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('상품 로딩 실패: $err'),
                data: (products) {
                  if (products.isEmpty) {
                    return const Text('등록된 연금 상품이 없습니다. 먼저 상품을 추가해 주세요.');
                  }

                  if (_selectedProductId == null && products.isNotEmpty) {
                    _selectedProductId = products.first.id;
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedProductId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: '상품 선택',
                      border: OutlineInputBorder(),
                    ),
                    items: products.map((prod) {
                      return DropdownMenuItem(
                        value: prod.id,
                        child: Text(
                          prod.productName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedProductId = val;
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
                  labelText: isAlreadyExists ? '추가 매수 원금' : '초기 투자 원금',
                  hintText: isAlreadyExists ? '이번 매수의 원금' : '최초 투자 원금 입력',
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

              // 4. 매수일 입력 (DateHelper 적용)
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: '매수일',
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return '매수일을 입력해 주세요.';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),

              if (isAlreadyExists)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'ℹ️ 동일 계좌·상품의 추가 매수 내역입니다. 개별 매수일을 각각 지정할 수 있습니다.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

              // 5. 연금 수령 완료(종료) 여부 스위치
              SwitchListTile(
                title: const Text('연금 수령 완료 (종료 상품)'),
                subtitle: const Text('지급이 완전히 끝나 잔액이 0원인 경우 체크'),
                value: _isTerminated,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    _isTerminated = val;
                  });
                },
              ),
              const SizedBox(height: 24),

              // 하단 버튼 영역 (좌우 꽉 찬 버튼)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing ? '수정하기' : '등록하기',
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
}