import 'package:flutter/material.dart';
import 'package:road_assist/core/services/call_hotline.dart';


class EmergencyCard extends StatelessWidget {
  const EmergencyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final hotlineService = HotlineService();

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
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Xác nhận'),
                  content: const Text(
                    'Bạn sắp gọi hotline hỗ trợ khẩn cấp. Tiếp tục?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('HỦY'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('GỌI'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await hotlineService.callHotline();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không thể gọi hotline'),
                      ),
                    );
                  }
                }
              }
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
