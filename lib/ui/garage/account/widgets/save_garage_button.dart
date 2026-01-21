import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/garage/account/viewmodel/garage_vm.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

class SaveGarageButton extends ConsumerWidget {
  const SaveGarageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(garageProvider);
    final userId = ref.watch(userIdProvider);

    return SizedBox(
      width: double.infinity,
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
                } catch (e) {
                  if (context.mounted) {
                    String errorMessage = 'Lỗi lưu thông tin';

                    // Hiển thị message lỗi cụ thể hơn
                    if (e.toString().contains('permission') ||
                        e.toString().contains('PERMISSION_DENIED')) {
                      errorMessage =
                          'Lỗi quyền truy cập! Kiểm tra Firestore Rules trong Firebase Console.';
                    } else if (e.toString().contains('network') ||
                        e.toString().contains('UNAVAILABLE')) {
                      errorMessage =
                          'Lỗi kết nối mạng! Kiểm tra internet connection.';
                    } else if (e.toString().contains('not-found')) {
                      errorMessage =
                          'Collection không tồn tại. Đang tự động tạo...';
                    } else {
                      errorMessage = 'Lỗi: ${e.toString()}';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                        action: SnackBarAction(
                          label: 'Đóng',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    );
                  }
                }
              },
        child: state.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Lưu thông tin'),
      ),
    );
  }
}
