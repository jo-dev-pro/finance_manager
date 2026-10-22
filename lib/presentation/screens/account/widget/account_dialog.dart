import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/account/account.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/account/account_name_provider.dart';

class AccountDialog extends ConsumerStatefulWidget {
  final Account? initialAccount;

  const AccountDialog({super.key, this.initialAccount});

  @override
  ConsumerState<AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends ConsumerState<AccountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _institutionController;
  late final TextEditingController _numberController;
  late final TextEditingController _sortOrderController; // 💡 출력 순서 컨트롤러 추가

  String? _selectedAccountNameId;
  String? _selectedAccountName;
  late String _selectedType;

  XFile? _selectedImage;
  Uint8List? _imageBytes;

  final List<String> _accountTypes = ['은행', '연금', '증권', '기타'];

  bool get _isEditing => widget.initialAccount != null;

  @override
  void initState() {
    super.initState();
    _institutionController = TextEditingController(
      text: widget.initialAccount?.financialInstitution ?? '',
    );
    _numberController = TextEditingController(
      text: widget.initialAccount?.accountNumber ?? '',
    );
    // 💡 기존 값이 있으면 대입, 없으면 기본값 '0'
    _sortOrderController = TextEditingController(
      text: widget.initialAccount?.sortOrder.toString() ?? '0',
    );

    _selectedAccountNameId = widget.initialAccount?.accountNameId;
    _selectedAccountName = widget.initialAccount?.accountName;

    _selectedType = widget.initialAccount?.accountType ?? '은행';
    if (!_accountTypes.contains(_selectedType)) {
      _selectedType = '기타';
    }
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _numberController.dispose();
    _sortOrderController.dispose(); // 💡 메모리 해제
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final institution = _institutionController.text.trim();
      final number = _numberController.text.trim();
      final sortOrder = int.tryParse(_sortOrderController.text.trim()) ?? 0;

      // 💡 1. 현재 등록된 전체 계좌 목록 가져오기
      final existingAccounts = ref.read(accountNotifierProvider).value ?? [];

      // 💡 2. 중복 체크 (수정 중인 본인 계좌는 제외하고, 동일한 sortOrder가 있는지 확인)
      final isDuplicate = existingAccounts.any((acc) => 
        acc.sortOrder == sortOrder && acc.id != widget.initialAccount?.id
      );

      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미 사용 중인 출력 순서입니다. 다른 번호를 입력해 주세요.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return; // 중복일 경우 저장을 중단하고 빠져나감
      }

      if (_isEditing) {
        final updatedAccount = widget.initialAccount!.copyWith(
          financialInstitution: institution,
          accountType: _selectedType,
          accountNameId: _selectedAccountNameId!,
          accountName: _selectedAccountName!,
          accountNumber: number.isEmpty ? null : number,
          sortOrder: sortOrder,
        );
        ref
            .read(accountNotifierProvider.notifier)
            .updateAccount(updatedAccount, _selectedImage);
      } else {
        final newAccount = Account(
          financialInstitution: institution,
          accountType: _selectedType,
          accountNameId: _selectedAccountNameId!,
          accountName: _selectedAccountName!,
          accountNumber: number.isEmpty ? null : number,
          sortOrder: sortOrder,
        );
        ref
            .read(accountNotifierProvider.notifier)
            .addAccount(newAccount, _selectedImage);
      }
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final existingLogoUrl = widget.initialAccount?.logoUrl;
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);

    return AlertDialog(
      title: Text(_isEditing ? '계좌 정보 수정' : '신규 계좌 등록'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      _imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : (existingLogoUrl != null &&
                                  existingLogoUrl.isNotEmpty
                              ? NetworkImage(existingLogoUrl) as ImageProvider
                              : null),
                  child:
                      (_imageBytes == null &&
                              (existingLogoUrl == null ||
                                  existingLogoUrl.isEmpty))
                          ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 20,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '로고 선택',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _institutionController,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: '금융기관 (예: 국민은행)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? '금융기관을 입력하세요' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: '계좌구분',
                  border: OutlineInputBorder(),
                ),
                icon: const Icon(Icons.arrow_drop_down),
                items:
                    _accountTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 12),

              accountNamesAsync.when(
                data: (accountNames) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAccountNameId,
                    decoration: const InputDecoration(
                      labelText: '계좌명 선택',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('계좌명을 선택하세요'),
                    icon: const Icon(Icons.arrow_drop_down),
                    items:
                        accountNames
                            .map(
                              (accountName) => DropdownMenuItem<String>(
                                value: accountName.id,
                                child: Text(accountName.accountName),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() => _selectedAccountNameId = val);
                    },
                    validator:
                        (v) => v == null || v.isEmpty ? '계좌명을 선택하세요' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error:
                    (err, _) => TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: '계좌명 목록 로드 실패 ($err)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _numberController,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '계좌번호 (선택)',
                  hintText: '예: 123-456-7890',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // 💡 [추가] 출력 순서 입력 필드
              TextFormField(
                controller: _sortOrderController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: '출력 순서 (숫자가 낮을수록 상단)',
                  hintText: '예: 1, 2, 3...',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? '순서를 입력하세요' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditing ? '수정' : '등록'),
        ),
      ],
    );
  }
}
