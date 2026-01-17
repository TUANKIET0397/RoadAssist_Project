import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network_status.dart';

final networkStatusProvider =
    StateNotifierProvider<NetworkNotifier, NetworkStatus>(
      (ref) => NetworkNotifier(),
    );

class NetworkNotifier extends StateNotifier<NetworkStatus> {
  NetworkNotifier() : super(NetworkStatus.connected);
  // NetworkNotifier() : super(NetworkStatus.disconnected);

  void setDisconnected() {
    state = NetworkStatus.disconnected;
  }

  void retry() {
    // TODO: kiểm tra lại mạng thật
    state = NetworkStatus.connected;
  }
}
