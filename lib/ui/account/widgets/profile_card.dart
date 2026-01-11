import 'package:flutter/material.dart';
import 'package:road_assist/data/models/user_model.dart';

class ProfileCard extends StatelessWidget {
  final UserModel user;

  const ProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Color.fromRGBO(25, 37, 59, 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 255, 255, 0.6),
            offset: Offset(2, 6),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              //avatar
              Container(
                width: 71,
                height: 71,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(75, 76, 237, 1),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/illustrations/vehicle1.png',
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 27,
                  ),
                ),
                Text(
                  user.phone,
                  style: const TextStyle(
                    color: Color.fromRGBO(111, 127, 161, 1),
                    fontSize: 17,
                  ),
                ),
                Text(
                  user.email ?? 'Thêm Email',
                  style: TextStyle(
                    color: user.email == null
                        ? Colors.redAccent
                        : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
