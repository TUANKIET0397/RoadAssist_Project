import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'network_status.dart';

final networkStatusProvider =
    StateNotifierProvider<NetworkNotifier, NetworkStatus>(
      (ref) => NetworkNotifier(),
    );

class NetworkNotifier extends StateNotifier<NetworkStatus> {
  late final StreamSubscription _subscription;

  NetworkNotifier() : super(NetworkStatus.connected) {
    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      state = NetworkStatus.disconnected;
    } else {
      state = NetworkStatus.connected;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
