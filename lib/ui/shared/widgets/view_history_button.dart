import 'package:flutter/material.dart';

class ViewHistoryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const ViewHistoryButton({
    super.key, 
    required this.onPressed,
    this.text = 'Xem lịch sử cứu hộ',
    this.icon = Icons.history,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E40AF),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0xFF1E40AF).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:  0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
          ),
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}