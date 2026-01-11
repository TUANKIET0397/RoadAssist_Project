import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: const EdgeInsets.fromLTRB(70, 0, 70, 32),
        decoration: BoxDecoration(
          color: Color.fromRGBO(75, 76, 237, 1),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(55, 182, 233, 1),
              offset: Offset(2, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Đăng xuất',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
