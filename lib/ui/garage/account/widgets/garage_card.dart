import 'package:flutter/material.dart';
import 'package:road_assist/data/models/garage_model.dart';

class GarageCard extends StatelessWidget {
  final GarageModel garage;

  const GarageCard({super.key, required this.garage});

  ImageProvider _buildBackgroundImage() {
    if (garage.bgimgUrl != null && garage.bgimgUrl!.isNotEmpty) {
      return NetworkImage(garage.bgimgUrl!);
    }
    return const AssetImage(
      'assets/images/illustrations/avatarDefault.png',
    );
  }

  Widget _buildAvatar() {
    if (garage.imageUrl != null && garage.imageUrl!.isNotEmpty) {
      return Image.network(
        garage.imageUrl!,
        width: 62,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: 62,
            height: 60,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          return Image.asset(
            'assets/images/illustrations/garageMap.png',
            width: 62,
            height: 60,
            fit: BoxFit.cover,
          );
        },
      );
    }

    return Image.asset(
      'assets/images/illustrations/garageMap.png',
      width: 62,
      height: 60,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(75, 76, 237, 1),
            Color.fromRGBO(25, 37, 59, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 0.7],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _buildBackgroundImage(),
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  Color.fromARGB(130, 0, 0, 0),
                  BlendMode.darken,
                ),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: _buildAvatar(),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          garage.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          garage.phone,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.white24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: garage.isActive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          garage.isActive ? 'Đang mở cửa' : 'Đã đóng cửa',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 15,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${garage.openTime} - ${garage.closeTime}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
