import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State
class GarageDetailState {
  final bool isLoading;
  final List<Map<String, dynamic>> reviews;
  final String? error;
  final double averageRating;
  final int totalReviews;

  GarageDetailState({
    required this.isLoading,
    required this.reviews,
    this.error,
    required this.averageRating,
    required this.totalReviews,
  });

  factory GarageDetailState.initial() => GarageDetailState(
        isLoading: false,
        reviews: [],
        error: null,
        averageRating: 0,
        totalReviews: 0,
      );

  GarageDetailState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? reviews,
    String? error,
    double? averageRating,
    int? totalReviews,
  }) {
    return GarageDetailState(
      isLoading: isLoading ?? this.isLoading,
      reviews: reviews ?? this.reviews,
      error: error ?? this.error,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }
}

/// Notifier
class GarageDetailNotifier extends StateNotifier<GarageDetailState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot>? _reviewsSubscription;

  GarageDetailNotifier() : super(GarageDetailState.initial());

  void watchGarageReviews(String garageId) {
    state = state.copyWith(isLoading: true, error: null);

    _reviewsSubscription?.cancel();

    _reviewsSubscription = _firestore
        .collection('garages')
        .doc(garageId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        print("No reviews found for garage $garageId. This might be an index issue.");
      }

      final reviews = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['createdAt'] as Timestamp?;

        return {
          'id': doc.id,
          'userName': data['userName'] ?? 'Ẩn danh',
          'rating': data['rating'] ?? 0,
          'comment': data['comment'] ?? '',
          'time': timestamp,
          'time': _getTimeAgo(timestamp),
          'userAvatar': data['userAvatar'],
        };
      }).toList();

      double avgRating = 0;
      if (reviews.isNotEmpty) {
        double total = reviews.fold(0, (prev, el) => prev + (el['rating'] ?? 0));
        avgRating = total / reviews.length;
      }

      state = state.copyWith(
        isLoading: false,
        reviews: reviews,
        averageRating: avgRating,
        totalReviews: reviews.length,
      );
    }, onError: (error) {
      state = state.copyWith(isLoading: false, error: 'Lỗi load reviews: $error');
    });
  }

  Future<void> submitReview({
    required String garageId,
    required String userId,
    required String userName,
    String? userAvatar,
    required int rating,
    required String comment,
  }) async {
    try {
      await _firestore
          .collection('garages')
          .doc(garageId)
          .collection('reviews')
          .add({
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      state = state.copyWith(error: 'Lỗi submit review: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _reviewsSubscription?.cancel();
    super.dispose();
  }

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Vừa xong';
    final now = DateTime.now();
    final diff = now.difference(timestamp.toDate());

    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} năm trước';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} tháng trước';
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }
}

final garageDetailProvider =
    StateNotifierProvider<GarageDetailNotifier, GarageDetailState>(
  (ref) => GarageDetailNotifier(),
);
