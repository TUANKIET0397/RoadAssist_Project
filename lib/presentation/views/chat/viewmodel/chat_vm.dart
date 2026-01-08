import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

final chatViewModelProvider = NotifierProvider<ChatViewModel, List<String>>(
  ChatViewModel.new,
);

class ChatViewModel extends Notifier<List<String>> {
  @override
  List<String> build() {
    final userId = ref.watch(userIdProvider);

    if (userId == null) return [];

    // Tạm mock data
    return ['Chat of $userId - 1', 'Chat of $userId - 2'];
  }
}
