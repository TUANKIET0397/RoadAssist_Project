import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

final accountViewModelProvider = NotifierProvider<AccountViewModel, String?>(
  AccountViewModel.new,
);

class AccountViewModel extends Notifier<String?> {
  @override
  String? build() {
    return ref.watch(userIdProvider);
  }
}
