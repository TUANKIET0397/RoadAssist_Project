import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/core/theme/app_palette.dart';
import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/navigation/viewmodel/garage_navigation_provider.dart';
import 'package:road_assist/ui/user/chat/view/chatGarage_screen.dart';
import 'package:road_assist/ui/user/chat/viewmodel/chatList_vm.dart';
import 'package:road_assist/ui/user/garage/viewmodel/garageDetail_viewmodel.dart';
import 'package:road_assist/ui/user/garage/view/review_screen.dart';

import 'package:road_assist/core/providers/auth_provider.dart';

class GarageDetailScreen extends ConsumerStatefulWidget {
  const GarageDetailScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GarageDetailScreen> createState() =>
      _GarageDetailScreenState();
}

class _GarageDetailScreenState extends ConsumerState<GarageDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final selectedGarage = ref.read(selectedGarageProvider);
      if (selectedGarage != null) {
        ref
            .read(garageDetailProvider.notifier)
            .watchGarageReviews(selectedGarage.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final garage = ref.watch(selectedGarageProvider);
    final state = ref.watch(garageDetailProvider);

    if (garage == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Không có garage nào',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppPalette.bgColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(garage),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildMainImage(garage, state),
                  const SizedBox(height: 20),
                  _buildVehicleTypes(garage),
                  const SizedBox(height: 20),
                  _buildAddressActions(garage),
                  const SizedBox(height: 20),
                  _buildServices(garage),
                  const SizedBox(height: 20),
                  _buildReviews(state),
                  const SizedBox(height: 20),
                  _buildBottomButtons(garage),
                  const SizedBox(height: 120),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(GarageModel garage) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 4,
      ),
      color: const Color.fromRGBO(37, 44, 59, 1),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.pop();
            },
          ),
          Expanded(
            child: Text(
              garage.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              garage.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: garage.isFavorite ? Color(0xFF34C8E8) : Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMainImage(GarageModel garage, GarageDetailState state) {
    return Container(
      height: 230,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          image: NetworkImage(
            garage.bgimgUrl ??
                'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=800',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.55), const Color(0xFF0A1220)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Row(
                children: [
                  _buildAvatar(garage),
                  const SizedBox(width: 12),
                  _buildNameRating(garage, state),
                  _buildDistance(garage),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Colors.white24),
              _buildStatusTime(garage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(GarageModel garage) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        image: DecorationImage(
          image: NetworkImage(
            garage.imageUrl ??
                'https://images.unsplash.com/photo-1625231334168-35067f8853ed?w=200',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildNameRating(GarageModel garage, GarageDetailState state) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              garage.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                ...List.generate(
                  5,
                      (index) => Icon(
                    Icons.star,
                    color: index < state.averageRating
                        ? Colors.amber
                        : Colors.grey,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  state.averageRating.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  ' (${state.totalReviews})',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistance(GarageModel garage) {
    if (garage.distance == null) return const SizedBox();

    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: Color(0xFF2FB8FF),
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          '${garage.distance!.toStringAsFixed(1)} km',
          style: const TextStyle(color: Color(0xFF2FB8FF), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildStatusTime(GarageModel garage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.circle,
              size: 8,
              color: garage.isActive
                  ? Colors.greenAccent
                  : Colors.redAccent,
            ),
            const SizedBox(width: 6),
            Text(
              garage.isActive ? 'Đang mở cửa' : 'Đã đóng cửa',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.white24),
            const SizedBox(width: 6),
            Text(
              '${garage.openTime} - ${garage.closeTime}',
              style: const TextStyle(color: Colors.white24, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleTypes(GarageModel garage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loại xe hỗ trợ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: garage.vehicleTypes
                .map((e) => _buildChip(e))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF001029),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF353F54)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.blue, fontSize: 14),
      ),
    );
  }

  Widget _buildAddressActions(GarageModel garage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF071030),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueGrey.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue, size: 32),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    garage.address,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    'assets/images/illustrations/garageMap.png',
                    width: 100,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOutlinedButton(
                  'Chỉ Đường',
                  Icons.navigation,
                      () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOutlinedButton(
                  'Gọi Garage',
                  Icons.phone_in_talk,
                      () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedButton(
      String label,
      IconData icon,
      VoidCallback onPressed,
      ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF001029),
        foregroundColor: Colors.white38,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.blueGrey, width: 0.5),
        ),
      ),
    );
  }

  Widget _buildServices(GarageModel garage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dịch vụ cứu hộ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF070C1B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueGrey, width: 0.5),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: garage.issues
                  .map(
                    (s) => RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: '• ',
                        style: TextStyle(color: Colors.blue, fontSize: 18),
                      ),
                      TextSpan(
                        text: s,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews(GarageDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF060A1B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: state.isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF34CAE8)),
        )
            : state.reviews.isEmpty
            ? const Center(
          child: Text(
            'Chưa có đánh giá nào',
            style: TextStyle(color: Colors.grey),
          ),
        )
            : SizedBox(
          height: 250,
          child: ListView.builder(
            itemCount: state.reviews.length,
            itemBuilder: (context, index) {
              final r = state.reviews[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReview(
                  r['userName'] as String,
                  (r['rating'] as num).toInt(),
                  r['time'] as String,
                  r['comment'] as String,
                  r['userAvatar'] as String?,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReview(
      String name,
      int stars,
      String time,
      String comment,
      String? avatarUrl,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl)
                : const AssetImage('assets/images/default_avatar.png')
            as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(
                        5,
                            (index) => Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Spacer(),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF2FB8FF),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(GarageModel garage) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GarageReviewView(garage: garage),
                  ),
                );
              },
              icon: const Icon(Icons.edit, size: 22),
              label: const Text('Đánh giá', style: TextStyle(fontSize: 18)),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF001029),
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.blueGrey),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final auth = ref.read(authStateProvider);
                if (!auth.isLoggedIn || auth.userId == null) return;

                final chatRepo = ref.read(chatRepositoryProvider);
                final userId = auth.userId!;
                final garageId = garage.id;

                final chatId = await chatRepo.getOrCreateChat(
                  userId: userId,
                  garageId: garageId,
                );

              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(chatId: chatId),
                ),
              );
              },
              icon: const Icon(Icons.wechat_outlined, size: 22),
              label: const Text('Chat', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34CAE8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}