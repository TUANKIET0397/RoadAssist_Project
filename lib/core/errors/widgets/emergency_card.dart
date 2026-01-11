import 'package:flutter/material.dart';

class EmergencyCard extends StatelessWidget {
  const EmergencyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color.fromRGBO(25, 37, 59, 1),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                color: Color.fromRGBO(248, 128, 0, 1),
                size: 26,
              ),
              SizedBox(width: 8),
              Text(
                'Hỗ trợ khẩn cấp',
                style: TextStyle(
                  color: Color.fromRGBO(248, 128, 0, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Trong trường hợp khẩn cấp và không thể kết nối Internet, '
            'bạn có thể gọi trực tiếp bằng số Hotline bên dưới để hỗ trợ ngay.',
            style: TextStyle(
              color: Color.fromRGBO(113, 129, 166, 1),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              print('onpress');
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.fromRGBO(249, 64, 90, 1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(251, 238, 227, 1),
                    offset: Offset(1, 2),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, color: Colors.white, size: 21),
                  const SizedBox(width: 10),
                  const Text(
                    'Gọi Ngay',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
