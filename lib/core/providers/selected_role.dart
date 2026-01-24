import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_assist/core/auth/auth_state.dart';

final selectedRoleProvider = StateProvider<UserRole?>(
      (ref) => null,
);