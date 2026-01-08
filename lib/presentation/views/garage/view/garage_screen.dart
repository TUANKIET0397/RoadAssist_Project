import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/response/garage_model.dart';
import 'package:road_assist/presentation/views/navigation/viewmodel/garage_navigation_provider.dart';
import 'package:road_assist/presentation/views/garage/viewmodel/garage_vm.dart';

class GarageListScreen extends ConsumerStatefulWidget {
  const GarageListScreen({super.key});

  @override
  ConsumerState<GarageListScreen> createState() => _GarageListScreenState();
}

class _GarageListScreenState extends ConsumerState<GarageListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(garageProvider.notifier).fetchGarages());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(garageProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(56, 56, 224, 1),
            Color.fromRGBO(46, 144, 183, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(37, 44, 59, 1),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      ' Danh sách garage',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF34C8E8), Color(0xFF4E4AF2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search,
                          color: Colors.white, size: 16),
                      onPressed: () {
                        // TODO: search
                      },
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: Builder(builder: (_) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.garages.isEmpty) {
                  return const Center(
                      child: Text('Không có garage nào',
                          style: TextStyle(color: Colors.white)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: state.garages.length,
                  itemBuilder: (context, index) {
                    final garage = state.garages[index];
                    return GarageCard(garage: garage);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class GarageCard extends ConsumerWidget {
  final GarageModel garage;

  const GarageCard({super.key, required this.garage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedGarageProvider.notifier).state = garage;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4FC3F7), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    garage.imageUrl ?? '',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      width: 90,
                      height: 90,
                      color: const Color(0xFF1E2A38),
                      child: const Icon(Icons.garage, size: 40, color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Rating
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(garage.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w200)),
                                const SizedBox(height: 1),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.green, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      garage.rating != null
                                          ? '${garage.rating!.toStringAsFixed(1)} · 220 Đánh giá'
                                          : 'Chưa có đánh giá',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Heart & Distance
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await ref
                                      .read(garageProvider.notifier)
                                      .toggleFavorite(
                                        userId:
                                            'currentUserId', // TODO: set actual userId
                                        garage: garage,
                                      );
                                },
                                child: Icon(
                                  garage.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: garage.isFavorite
                                      ? Colors.red
                                      : Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 1),
                              const Text(
                                '3.5 km',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Open & Close
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
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Text('Mở cửa lúc ${garage.openTime}',
                                    style: const TextStyle(
                                        color: Color(0xFF3CD69E),
                                        fontSize: 10)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                        color: Color(0xFFFC5C72),
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Text('Đóng cửa lúc ${garage.closeTime}',
                                    style: const TextStyle(
                                        color: Color(0xFFFC5C72),
                                        fontSize: 10)),
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

            // Vehicle types
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: garage.vehicleTypes.map((type) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFF001029),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(type,
                      style: const TextStyle(
                          color: Color(0xFF1E8AF6),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Services
            Text(
              garage.services.join('  ·  '),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),

            const SizedBox(height: 2),

            const Divider(color: Color(0xFF34CAE8), thickness: 1),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(garage.address,
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to chat
                  },
                  child: const Icon(Icons.mark_unread_chat_alt,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
