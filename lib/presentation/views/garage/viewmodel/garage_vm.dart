import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/providers/auth_provider.dart';

final garageViewModelProvider = NotifierProvider<GarageViewModel, List<String>>(
  GarageViewModel.new,
);

class GarageViewModel extends Notifier<List<String>> {
  @override
  List<String> build() {
    final userId = ref.watch(userIdProvider);
    if (userId == null) return [];

    return ['Garage A of $userId', 'Garage B of $userId'];
  }
}
