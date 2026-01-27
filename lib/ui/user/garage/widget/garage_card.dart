import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/navigation/viewmodel/garage_navigation_provider.dart';
import 'package:road_assist/ui/user/chat/view/chatGarage_screen.dart';
import 'package:road_assist/ui/user/chat/viewmodel/chatList_vm.dart';
import 'package:road_assist/ui/user/garage/viewmodel/garage_vm.dart';

class GarageCard extends ConsumerWidget {
  final GarageModel garage;

  const GarageCard({
    super.key,
    required this.garage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingState = ref.watch(garageDetailProvider(garage.id));
    final currentUserId = ref.watch(userIdProvider);

    return GestureDetector(
      onTap: () {
        ref.read(selectedGarageProvider.notifier).state = garage;
        context.push('/user/garage/detail');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF4FC3F7),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    garage.imageUrl ?? '',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      color: const Color(0xFF1E2A38),
                      child: const Icon(
                        Icons.garage,
                        size: 40,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                /// Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  garage.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ratingState.totalReviews == 0
                                          ? 'Chưa có đánh giá'
                                          : '${ratingState.averageRating.toStringAsFixed(1)} · '
                                          '${ratingState.totalReviews} đánh giá',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          /// Favourite + Distance
                          Column(
                            children: [
                              GestureDetector(
                                onTap: currentUserId == null // 👈 KIỂM TRA NULL
                                    ? null
                                    : () async {
                                  await ref
                                      .read(garageProvider.notifier)
                                      .toggleFavorite(
                                    userId: currentUserId, // 👈 SỬ DỤNG USERID THẬT
                                    garage: garage,
                                  );
                                },
                                child: Icon(
                                  garage.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: garage.isFavorite
                                      ? Color(0xFF34C8E8)
                                      : Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                garage.distance == null
                                    ? '-- km'
                                    : '${garage.distance!.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      /// Open / Close
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF3CD69E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Mở cửa lúc ${garage.openTime}',
                                  style: const TextStyle(
                                    color: Color(0xFF3CD69E),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFC5C72),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Đóng cửa lúc ${garage.closeTime}',
                                  style: const TextStyle(
                                    color: Color(0xFFFC5C72),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: garage.vehicleTypes.map((type) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF001029),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: Color(0xFF1E8AF6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            Text(
              garage.issues.join('  ·  '),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),

            const Divider(
              color: Color(0xFF34CAE8),
              thickness: 1,
            ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    garage.address,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: currentUserId == null
                      ? null
                      : () async {
                    try {

                      final chatId = await ref
                          .read(chatRepositoryProvider)
                          .getOrCreateChat(
                        userId: currentUserId,
                        garageId: garage.id,
                      );

                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(chatId: chatId),
                          ),
                        );
                      }
                    } catch (e) {
                      // Đóng loading nếu có lỗi
                      if (context.mounted) {
                        Navigator.pop(context);
                      }

                      // Hiển thị error
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.mark_unread_chat_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
