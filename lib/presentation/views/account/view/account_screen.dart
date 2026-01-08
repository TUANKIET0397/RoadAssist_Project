import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/presentation/views/account/viewmodel/account_vm.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(accountViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Center(child: Text(userId == null ? 'Guest' : 'User: $userId')),
    );
  }
}
