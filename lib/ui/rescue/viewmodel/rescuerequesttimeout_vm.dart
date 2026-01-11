// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:road_assist/data/models/garage_model.dart';


class NoGarageFoundViewModel extends ChangeNotifier {
  List<GarageModel> _nearbyGarages = [];
  bool _isLoading = false;

  List<GarageModel> get nearbyGarages => _nearbyGarages;
  bool get isLoading => _isLoading;

  void loadNearbyGarages() {
    _isLoading = true;
    notifyListeners();

    // Simulate loading data
    Future.delayed(const Duration(milliseconds: 500), () {
      _nearbyGarages = [
        GarageModel(
          id: '1',
          name: 'Minh Thuan motor',
          imageUrl: 'assets/images/garage1.png',
          vehicleTypes: ['Xe máy', 'xe tay ga'],
          issues: ['Sửa chữa xe máy', 'Sửa chữa xe tay ga'], address: '', phone: '', openTime: '', closeTime: '', lat: null, lng: null, isActive: true, distance: null,
        ),
        GarageModel(
          id: '2',
          name: 'Đức mạnh oto',
          imageUrl: 'assets/images/garage2.png',
          vehicleTypes: ['Xe container', 'bus'],
          issues: ['Sửa chữa xe container', 'Sửa chữa xe bus'],
          address: '',
          phone: '0337760281',
          openTime: '',
          closeTime: '',
          lat: null,
          lng: null,
          isActive: false, distance: null,
        ),
        GarageModel(
          id: '3',
          name: 'Giabao Xe',
          imageUrl: 'assets/images/garage3.png',
          vehicleTypes: ['Xe điện'],
          issues: ['Sửa chữa xe điện'],
          address: '',
          phone: '0337760282',
          openTime: '',
          closeTime: '',
          lat: null,
          lng: null,
          isActive: true, distance: null,
        ),
      ];
      _isLoading = false;
      notifyListeners();
    });
  }
      void callGarage(String garageId) {
    final garage = _nearbyGarages.firstWhere((g) => g.id == garageId);
    // ignore: duplicate_ignore
    // ignore: avoid_print
    print('Calling garage: ${garage.name} - ${garage.phone}');
  }

  void resendRescueRequest() {
    print('Resending rescue request...');
  }
}
