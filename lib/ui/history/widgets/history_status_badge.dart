import 'package:flutter/material.dart';
import 'package:road_assist/ui/history/model/history_item.dart';

class HistoryStatusBadge extends StatelessWidget {
  final Status status;

  const HistoryStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == Status.completed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isCompleted ? Colors.greenAccent : Colors.redAccent,
        ),
      ),
      child: Text(
        isCompleted ? 'Hoàn Thành' : 'Thất Bại',
        style: TextStyle(
          color: isCompleted ? Colors.greenAccent : Colors.redAccent,
          fontSize: 14,
        ),
      ),
    );
  }
}
