import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/ui/acount_garage/models/garage_model.dart';

/// Provider giữ trạng thái garage
final garageProvider = StateProvider<Garage>((ref) {
  return Garage(
    name: 'Minh thuận Garage',
    phone: '0337760280',
    isOpen: true,
    openTime: '07:00',
    closeTime: '19:00',
    supportedVehicles: ['Xe Bốn bánh', 'Xe Honda'],
  );
});
