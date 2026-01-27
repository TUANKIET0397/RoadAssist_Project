import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/completion_payload.dart';

/// Provider quản lý trạng thái màn hình completion
/// KHÔNG dùng autoDispose vì cần giữ payload giữa các navigation
final completionProvider =
    StateNotifierProvider<CompletionViewModel, CompletionPayload?>(
  (ref) => CompletionViewModel(),
);

class CompletionViewModel extends StateNotifier<CompletionPayload?> {
  CompletionViewModel() : super(null);

  void setCompletion(CompletionPayload payload) {
    state = payload;
  }

  void clear() {
    state = null;
  }

  Future<void> submitRating({
    required int stars,
    required String comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
