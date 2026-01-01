import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:road_assist/presentation/viewmodels/garage/garageList_viewmodel.dart';
import 'package:road_assist/data/models/response/garage_model.dart';

class GarageListScreen extends StatefulWidget {
  const GarageListScreen({super.key});

  @override
  State<GarageListScreen> createState() => _GarageListScreenState();
}

class _GarageListScreenState extends State<GarageListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<GarageViewModel>().fetchGarages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                //color: const Color(0xFF252D3C66)
                  color: const Color.fromRGBO(50, 65, 85, 0.7),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      ' Danh sách garage',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF34C8E8),
                          Color(0xFF4E4AF2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  // màu background
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromRGBO(45, 55, 80, 0.6),
                      const Color.fromRGBO(30, 10, 160, 0.6),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: const [0.0, 1.0],
                  ),
                ),
                child: Consumer<GarageViewModel>(
                  builder: (context, vm, _) {
                    if (vm.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (vm.garages.isEmpty) {
                      return const Center(
                        child: Text(
                          'Không có garage nào',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: vm.garages.length,
                      itemBuilder: (context, index) {
                        final garage = vm.garages[index];
                        return GarageCard(garage: garage);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GarageCard extends StatelessWidget {
  final GarageModel garage;

  const GarageCard({super.key, required this.garage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:  Colors.transparent,
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
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  garage.imageUrl!,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 90,
                      height: 90,
                      color: const Color(0xFF1E2A38),
                      child: const Icon(
                        Icons.garage,
                        size: 40,
                        color: Colors.white24,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Rating
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      garage.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              // Rating
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    garage.rating != null
                                        ? '${garage.rating!.toStringAsFixed(1)} · 220 Đánh giá'
                                        : 'Chưa có đánh giá',
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

                        // Heart & Distance
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Heart Icon
                            Align(
                              alignment: Alignment.topCenter,
                              child: IconButton(
                                icon: Icon(
                                  garage.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: garage.isFavorite ? Colors.red : Colors.white,
                                  size: 24,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(height: 1),
                            // Row Distance
                            Row(
                              children: [
                                Text(
                                  '3.5 km', // sau sửa lại theo định vị user
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
                      ],
                    ),
                    const SizedBox(height: 1),

                    // Open & Close time
                    Row(
                      children: [
                        // Open time
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF3CD69E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 1),
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
                        ),
                        const SizedBox(width: 1),

                        // Close time
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 1,
                              vertical: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFC5C72),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 1),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF001029),
                  borderRadius: BorderRadius.circular(8),
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

          // Services
          Text(
            garage.services.join('  ·  '),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 2),

          const Divider(
            color: Color(0xFF34CAE8),
            thickness: 1,
          ),


          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.mark_unread_chat_alt,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  // chuyển hướng chat
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}