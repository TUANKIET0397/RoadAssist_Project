import 'package:flutter/material.dart';
import 'package:road_assist/ui/acount_garage/models/garage_model.dart';

class GarageCard extends StatelessWidget {
  final Garage garage;

  const GarageCard({super.key, required this.garage});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      // padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [
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
            width: 400,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/illustrations/avatarDefault.png',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color.fromARGB(130, 0, 0, 0),
                  BlendMode.darken,
                ),
              ),
              borderRadius: BorderRadius.only(
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
                      child: Image.asset(
                        'assets/images/illustrations/garageMap.png',
                        width: 62,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
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
                        // const SizedBox(height: 6),
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
                          color: garage.isOpen ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          garage.isOpen ? 'Đang mở cửa' : 'Đã đóng cửa',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
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
