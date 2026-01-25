import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:road_assist/ui/garage/account/viewmodel/garage_vm.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

class SaveGarageButton extends ConsumerWidget {
  const SaveGarageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(garageProvider);
    final userId = ref.watch(userIdProvider);

    return Center(
      child: ElevatedButton(
        onPressed: state.isLoading
            ? null
            : () async {
          try {
            await ref
                .read(garageProvider.notifier)
                .saveGarage(userId: userId);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lưu thông tin garage thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
            }

            context.pop('/garage/account');
          } catch (e) {
            if (!context.mounted) return;
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4B4CED),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: state.isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Lưu thông tin',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
