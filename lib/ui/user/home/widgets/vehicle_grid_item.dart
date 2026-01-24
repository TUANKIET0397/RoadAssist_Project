import 'package:flutter/material.dart';
import 'package:road_assist/ui/user/home/widgets/clipped_card.dart';
import 'package:road_assist/ui/user/home/clippers/rps_clipper_small.dart';

class VehicleGridItem extends StatelessWidget {
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String image;

  const VehicleGridItem({
    super.key,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return ClippedCard(
          width: width,
          heightFactor: 1.73,
          clipper: RPSClipperSmall(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 26, 20, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ❤️ FAVORITE
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(
                      Icons.favorite_border,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                /// 🛵 IMAGE
                Expanded(
                  flex: 3,
                  child: Center(child: Image.asset(image, fit: BoxFit.contain)),
                ),

                const SizedBox(height: 6),

                /// TEXT
                Text(
                  subtitle1,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle2,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
