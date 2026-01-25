import 'package:flutter/material.dart';
import 'rescue_cancel_dialog.dart';

class RescueCancelButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onConfirmCancel;
  final String? disabledMessage;
  final double? height;
  final EdgeInsets? padding;

  const RescueCancelButton({
    super.key,
    this.enabled = true,
    required this.onConfirmCancel,
    this.disabledMessage,
    this.height,
    this.padding,
  });

  Future<void> _showCancelConfirmation(BuildContext context) async {
    await RescueCancelDialog.show(
      context,
      onConfirm: onConfirmCancel,
      message: disabledMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: height ?? 56,
        child: enabled
            ? ElevatedButton(
                onPressed: () => _showCancelConfirmation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Hủy yêu cầu cứu hộ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Không thể hủy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}
