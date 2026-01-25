import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/garage_completion_payload.dart';

/// Provider công khai cho UI
final garageCompletionProvider =
    StateNotifierProvider<GarageCompletionViewModel, GarageCompletionPayload?>(
      (ref) => GarageCompletionViewModel(),
    );

class GarageCompletionViewModel extends StateNotifier<GarageCompletionPayload?> {
  GarageCompletionViewModel() : super(null);

  /// Gọi khi rescue / nghiệp vụ hoàn tất
  void setCompletion(GarageCompletionPayload payload) {
    state = payload;
  }

  /// Clear khi rời màn (optional)
  void clear() {
    state = null;
  }
}
