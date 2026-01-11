import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/data/models/garage_model.dart';
import 'package:road_assist/ui/garage/viewmodel/garageDetail_viewmodel.dart';
import 'package:road_assist/ui/navigation/view/slanted_bottom_bar.dart';

class GarageReviewView extends ConsumerStatefulWidget {
  final GarageModel garage;

  const GarageReviewView({Key? key, required this.garage}) : super(key: key);

  @override
  ConsumerState<GarageReviewView> createState() => _GarageReviewViewState();
}

class _GarageReviewViewState extends ConsumerState<GarageReviewView> {
  int selectedRating = 5;
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(garageDetailProvider);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(37, 44, 59, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Đánh giá',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.warning_sharp,
              color: Color(0xFFF88000),
              size: 28,
            ),
          ),
        ],
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
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
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    children: [
                      _buildGarageInfo(state),
                      const SizedBox(height: 20),
                      _buildReviewInput(),
                      const SizedBox(height: 20),
                      _buildSubmitButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: const SlantedAnimatedBottomBar(popNavigator: true),
    );
  }

  Widget _buildGarageInfo(GarageDetailState state) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          image: NetworkImage(
            widget.garage.bgimgUrl ??
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
                  // Avatar Garage
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      image: DecorationImage(
                        image: NetworkImage(
                          widget.garage.imageUrl ??
                              'https://images.unsplash.com/photo-1625231334168-35067f8853ed?w=200',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + Rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.garage.name,
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
                                index < state.averageRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              state.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              ' (${state.totalReviews})',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Distance
                  Row(
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF2FB8FF),
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '2.1 km',
                        style: TextStyle(
                          color: Color(0xFF2FB8FF),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Colors.white24),
              // Status + Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: widget.garage.isActive
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.garage.isActive ? 'Đang mở cửa' : 'Đã đóng cửa',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.white24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.garage.openTime} - ${widget.garage.closeTime}',
                        style: const TextStyle(
                          color: Colors.white24,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF19253B), Color(0xFF34CAE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => IconButton(
                icon: Icon(
                  index < selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () => setState(() => selectedRating = index + 1),
              ),
            ),
          ),
          const SizedBox(height: 8),

          const Divider(color: Colors.grey, thickness: 1),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4B4CED), Color(0xFF3CD69E)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(1),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF353F54),
                borderRadius: BorderRadius.circular(7),
              ),
              child: TextField(
                controller: commentController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Chia sẻ cảm nghĩ của bạn về Garage',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              ref
                  .read(garageDetailProvider.notifier)
                  .submitReview(
                    garageId: widget.garage.id,
                    userId: 'currentUserId',
                    userName: 'Current User',
                    userAvatar: null,
                    rating: selectedRating,
                    comment: commentController.text,
                  );
              commentController.clear();
              setState(() => selectedRating = 5);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF34CAE8), Color(0xFF19253B)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Gửi đánh giá',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Đánh giá của bạn giúp cải thiện chất lượng dịch vụ',
          style: TextStyle(color: Colors.white54, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
