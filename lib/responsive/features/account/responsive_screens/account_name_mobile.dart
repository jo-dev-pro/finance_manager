// lib/responsive/features/account_name/responsive_screens/account_name_mobile.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/account/account_name_provider.dart';

class AccountNameMobileScreen extends ConsumerWidget {
  const AccountNameMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountNameAsync = ref.watch(accountNameNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('은행 계좌명 관리 (조회 전용)'),
      ),
      body: accountNameAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류가 발생했습니다: $err')),
        data: (accountNames) {
          if (accountNames.isEmpty) {
            return const Center(
              child: Text(
                '등록된 계좌명이 없습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
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
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Text(
                    accountName.accountName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}