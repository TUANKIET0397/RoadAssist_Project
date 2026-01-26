import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/call_repository.dart';
import '../services/agora_service.dart';
import 'call_controller.dart';

final callRepositoryProvider = Provider((ref) => CallRepository());

final agoraServiceProvider = Provider((ref) => AgoraService());

final callControllerProvider = Provider(
  (ref) => CallController(ref.read(callRepositoryProvider)),
);
