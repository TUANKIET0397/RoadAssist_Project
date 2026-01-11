import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/presentation/views/history/model/history_item.dart';

enum HistoryFilter { all, completed, failed }

final HistoryProvider = StateNotifierProvider<HistoryVM, HistoryFilter>((ref) {
  return HistoryVM();
});

class HistoryVM extends StateNotifier<HistoryFilter> {
  HistoryVM() : super(HistoryFilter.all);

  void setFilter(HistoryFilter filter) {
    state = filter;
  }
}

final HistoryListProvider = Provider<List<HistoryItem>>((ref) {
  final filter = ref.watch(HistoryProvider);

  final all = [
    HistoryItem(
      vehicleType: 'Xe tay ga',
      vehicleName: 'Xe tay ga',
      vehicleModel: 'Honda SH Mode 2025',
      image: 'assets/images/illustrations/vehicle.png',
      status: Status.completed,
      issue: 'Bể lốp, hư máy',
      address: '15B Nguyễn Lương Bằng, P25, TP HCM',
      completedTime: '19:00 08-01-2026',
    ),
    HistoryItem(
      vehicleType: 'Xe Hơi',
      vehicleName: 'Xe Hơi',
      vehicleModel: 'Toyota A125 2025',
      image: 'assets/images/illustrations/vehicle1.png',
      status: Status.failed,
      issue: 'Bể lốp, hư máy',
      address: '15B Nguyễn Lương Bằng, P25, TP HCM',
      completedTime: '19:00 08-01-2026',
    ),
    HistoryItem(
      vehicleType: 'Xe Hơi 1',
      vehicleName: 'Xe Hơi 1',
      vehicleModel: 'Toyota A125 2025',
      image: 'assets/images/illustrations/vehicle1.png',
      status: Status.completed,
      issue: 'Bể lốp, hư máy',
      address: '15B Nguyễn Lương Bằng, P25, TP HCM',
      completedTime: '19:00 08-01-2026',
    ),
    HistoryItem(
      vehicleType: 'Xe Hơi 2',
      vehicleName: 'Xe Hơi 2',
      vehicleModel: 'Toyota A125 2025',
      image: 'assets/images/illustrations/vehicle1.png',
      status: Status.failed,
      issue: 'Bể lốp, hư máy',
      address: '15B Nguyễn Lương Bằng, P25, TP HCM',
      completedTime: '19:00 08-01-2026',
    ),
    HistoryItem(
      vehicleType: 'Xe Hơi 3',
      vehicleName: 'Xe Hơi 3',
      vehicleModel: 'Toyota A125 2025',
      image: 'assets/images/illustrations/vehicle1.png',
      status: Status.completed,
      issue: 'Bể lốp, hư máy',
      address: '15B Nguyễn Lương Bằng, P25, TP HCM',
      completedTime: '19:00 08-01-2026',
    ),
  ];

  switch (filter) {
    case HistoryFilter.completed:
      return all.where((e) => e.status == Status.completed).toList();
    case HistoryFilter.failed:
      return all.where((e) => e.status == Status.failed).toList();
    default:
      return all;
  }
});
