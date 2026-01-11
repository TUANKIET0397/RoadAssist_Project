import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/completion_payload.dart';

/// Provider công khai cho UI
final completionProvider =
    StateNotifierProvider<CompletionViewModel, CompletionPayload?>(
      (ref) => CompletionViewModel(),
    );

class CompletionViewModel extends StateNotifier<CompletionPayload?> {
  CompletionViewModel() : super(null);

  /// Gọi khi rescue / nghiệp vụ hoàn tất
  void setCompletion(CompletionPayload payload) {
    state = payload;
  }

  /// Clear khi rời màn (optional)
  void clear() {
    state = null;
  }

  /// Sau này: submit rating
  Future<void> submitRating({
    required int stars,
    required String comment,
  }) async {
    // TODO: call API
  }
}

// class CompletionViewModel extends StateNotifier<CompletionPayload?> {
//   CompletionViewModel() : super(_mockPayload());

//   static CompletionPayload _mockPayload() {
//     return CompletionPayload(
//       title: 'Hoàn thành cứu hộ',
//       subtitle: 'Cảm ơn bạn đã sử dụng RoadAssist',
//       vehicleImage: 'assets/images/vehicles/sh.png',
//       vehicleName: 'Xe tay ga',
//       vehicleModel: 'Honda SH Mode 2025',
//       issue: 'Bể lốp, hư máy',
//       address: '15B Nguyễn Lương Bằng, P25, TP HCM',
//       completedTime: '19:00 08-01-2026',
//       garageName: 'Minh Thuan Motor',
//       garageAvatar: 'assets/images/garage/minh_thuan.png',
//     );
//   }
// }
