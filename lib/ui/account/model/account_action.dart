import 'package:flutter/material.dart';

enum AccountActionType { rescues, favoriteGarage, personalInfo, changePassword }

class AccountActionItem {
  final AccountActionType type;
  final String title;
  final IconData icon;

  const AccountActionItem({
    required this.type,
    required this.title,
    required this.icon,
  });
}
