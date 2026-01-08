import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

final historyViewModelProvider =
    NotifierProvider<HistoryViewModel, List<String>>(HistoryViewModel.new);

class HistoryViewModel extends Notifier<List<String>> {
  @override
  List<String> build() {
    final userId = ref.watch(userIdProvider);
    if (userId == null) return [];

    return ['History 1 of $userId', 'History 2 of $userId'];
  }
}
