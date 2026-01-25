import 'package:flutter/material.dart';
import 'package:road_assist/data/models/rescue_request_model.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class RescueProgressTimeline extends StatelessWidget {
  final RescueRequestModel request;
  final bool showBorder;
  final EdgeInsets? padding;

  const RescueProgressTimeline({
    super.key,
    required this.request,
    this.showBorder = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'step': 1,
        'title': 'Garage đã nhận cứu hộ',
        'icon': Icons.check_circle,
      },
      {
        'step': 2,
        'title': 'Garage đã đến nơi của bạn',
        'icon': Icons.location_on,
      },
      {
        'step': 3,
        'title': 'Tiến hành sửa chữa',
        'icon': Icons.build,
      },
      {
        'step': 4,
        'title': 'Hoàn thành cứu hộ',
        'icon': Icons.done_all,
      },
    ];

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TIMELINE
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: request.progressStep >= (steps[i]['step'] as int)
                          ? Colors.greenAccent
                          : Colors.blueAccent,
                      boxShadow: [
                        if (request.progressStep >= (steps[i]['step'] as int))
                          BoxShadow(
                            color: Colors.greenAccent.withValues(alpha: 0.8),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: Icon(
                      steps[i]['icon'] as IconData,
                      color: Colors.black,
                    ),
                  ),
                  if (i < steps.length - 1)
                    Container(
                      width: 2,
                      height: 25,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 8),

              // CONTENT
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(0, 38, 50, 56).withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i]['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStepTime(request, steps[i]['step'] as int),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );

    if (!showBorder) {
      return Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF001029),
        borderRadius: BorderRadius.circular(16),
        border: GradientBoxBorder(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF3CD69E), Color(0xFFFC5C72)],
          ),
          width: 3,
        ),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: content,
    );
  }

  String _getStepTime(RescueRequestModel request, int step) {
    DateTime? dateTime;
    switch (step) {
      case 1:
        dateTime = request.acceptedAt;
        break;
      case 2:
        dateTime = request.arrivedAt;
        break;
      case 3:
        dateTime = request.repairingStartedAt;
        break;
      case 4:
        dateTime = request.completedAt;
        break;
      default:
        return '';
    }

    if (dateTime == null) return '';

    // Format thời gian thực (HH:mm:ss)
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final date = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');

    return '$date/$month lúc $hour:$minute:$second';
  }
}