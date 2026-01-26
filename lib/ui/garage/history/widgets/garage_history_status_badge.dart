import 'package:flutter/material.dart';
import 'package:road_assist/ui/garage/history/model/garage_history_item.dart';

class GarageHistoryStatusBadge extends StatelessWidget {
  final GarageHistoryStatus status;

  const GarageHistoryStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == GarageHistoryStatus.completed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isCompleted ? Colors.greenAccent : Colors.redAccent,
        ),
      ),
      child: Text(
        isCompleted ? 'Hoàn Thành' : 'Đã Hủy',
        style: TextStyle(
          color: isCompleted ? Colors.greenAccent : Colors.redAccent,
          fontSize: 14,
        ),
      ),
    );
  }
}
