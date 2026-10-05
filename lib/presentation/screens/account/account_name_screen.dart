import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/account/account_name.dart';
import '../../../providers/account/account_name_provider.dart';
import 'widget/account_name_dialog.dart';

class AccountNameScreen extends ConsumerWidget {
  const AccountNameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountNameAsync = ref.watch(accountNameNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('은행 계좌명 관리')),
      body: accountNameAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류가 발생했습니다: $err')),
        data: (accountNames) {
          if (accountNames.isEmpty) {
            return const Center(child: Text('등록된 계좌명이 없습니다.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accountNames.length,
            itemBuilder: (context, index) {
              final accountName = accountNames[index];

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          accountName.accountName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 수정 & 삭제 버튼
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: Colors.grey.shade700,
                        onPressed:
                            () =>
                                _showDialog(context, accountName: accountName),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red.shade400,
                        onPressed:
                            () => _confirmDelete(context, ref, accountName),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('계좌명 추가'),
      ),
    );
  }

  void _showDialog(BuildContext context, {AccountName? accountName}) {
    showDialog(
      context: context,
      builder: (context) => AccountNameDialog(accountName: accountName),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AccountName accountName,
  ) {
    if (accountName.id == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('삭제'),
            content: Text('\'${accountName.accountName}\' 계좌명을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await ref
                      .read(accountNameNotifierProvider.notifier)
                      .deleteAccountName(accountName.id!);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('삭제', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}
