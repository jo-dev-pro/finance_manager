import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/account_name.dart';
import '../../providers/account_name_provider.dart';
import '../widgets/account_name_dialog.dart';

class AccountNameScreen extends ConsumerWidget {
  const AccountNameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountNameAsync = ref.watch(accountNameNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('은행 계좌명 관리'),
      ),
      body: accountNameAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류가 발생했습니다: $err')),
        data: (accountNames) {
          if (accountNames.isEmpty) {
            return const Center(child: Text('등록된 계좌명이 없습니다.'));
          }

          return ListView.builder(
            itemCount: accountNames.length,
            itemBuilder: (context, index) {
              final accountName = accountNames[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  title: Text(
                    accountName.accountName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showDialog(context, accountName: accountName),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, ref, accountName),
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

  void _confirmDelete(BuildContext context, WidgetRef ref, AccountName accountName) {
    if (accountName.id == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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