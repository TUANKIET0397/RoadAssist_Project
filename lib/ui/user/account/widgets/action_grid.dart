import 'package:flutter/material.dart';
import '../model/account_action.dart';

class ActionGrid extends StatelessWidget {
  final List<AccountActionItem> actions;
  final void Function(AccountActionType) onTap;

  const ActionGrid({super.key, required this.actions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Cứu hộ & hoạt động',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3,
          children: actions
              .map(
                (a) => InkWell(
                  onTap: () => onTap(a.type),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color.fromRGBO(25, 37, 59, 1),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(75, 76, 237, 1),
                          offset: Offset(2, 6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(a.icon, color: Colors.white),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            a.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
