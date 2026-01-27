import 'package:flutter/material.dart';

/// Widget để chọn các vấn đề của xe
class RescueIssueSelector extends StatelessWidget {
  final List<String> allIssues;
  final List<String> selectedIssues;
  final ValueChanged<String> onIssueToggle;

  const RescueIssueSelector({
    super.key,
    required this.allIssues,
    required this.selectedIssues,
    required this.onIssueToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allIssues.map((issue) {
        final isSelected = selectedIssues.contains(issue);
        return GestureDetector(
          onTap: () => onIssueToggle(issue),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF008CA8)
                  : const Color(0xFF001029),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.blue.shade300
                    : Colors.blue.shade700,
                width: 1,
              ),
            ),
            child: Text(
              issue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
