import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:road_assist/core/auth/auth_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_assist/ui/user/account/model/vehicle_model.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).userId;
});

final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authStateProvider).role;
});

/// Provider để lấy tên garage hiện tại (cho garage user) - realtime
final currentGarageNameProvider = StreamProvider<String?>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return Stream.value(null);

  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('garages')
      .doc(userId)
      .snapshots()
      .map((doc) {
        if (doc.exists) {
          return doc.data()?['name'] as String?;
        }
        return null;
      });
});

/// Provider để lấy full info của garage hiện tại (name + phone)
final currentGarageInfoProvider = StreamProvider<Map<String, String>?>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return Stream.value(null);

  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('garages')
      .doc(userId)
      .snapshots()
      .map((doc) {
        if (doc.exists) {
          final data = doc.data();
          return {
            'name': data?['name'] as String? ?? 'Garage',
            'phone': data?['phone'] as String? ?? 'N/A',
          };
        }
        return null;
      });
});

/// Provider để lấy full info của user hiện tại (name + phone)
final currentUserInfoProvider = StreamProvider<Map<String, String>?>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return Stream.value(null);

  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((doc) {
        if (doc.exists) {
          final data = doc.data();
          return {
            'name': data?['name'] as String? ?? 'User',
            'phone': data?['phone'] as String? ?? 'N/A',
          };
        }
        return null;
      });
});

/// Provider để lấy full info của user hiện tại (name + phone) - FutureProvider
final currentUserInfoFutureProvider = FutureProvider<Map<String, String>?>((ref) async {
  final userId = ref.watch(userIdProvider);
  print('🔵 currentUserInfoFutureProvider: userId=$userId');
  if (userId == null) {
    print('❌ userId is null');
    return null;
  }

  final firestore = ref.watch(firestoreProvider);
  try {
    final doc = await firestore.collection('users').doc(userId).get();
    print('📄 User doc exists: ${doc.exists}');
    print('📊 User data: ${doc.data()}');
    
    if (doc.exists) {
      final data = doc.data();
      final name = data?['name'] as String? ?? 'User';
      final phone = data?['phone'] as String? ?? 'N/A';
      print('✅ User name=$name, phone=$phone');
      return {
        'name': name,
        'phone': phone,
      };
    }
    print('⚠️ User document does not exist for userId=$userId');
    return null;
  } catch (e, st) {
    print('❌ Error fetching user info: $e');
    print('Stack: $st');
    return null;
  }
});

/// Provider để lấy full info của garage hiện tại (name + phone) - FutureProvider
final currentGarageInfoFutureProvider = FutureProvider<Map<String, String>?>((ref) async {
  final userId = ref.watch(userIdProvider);
  print('🔵 currentGarageInfoFutureProvider: userId=$userId');
  if (userId == null) {
    print('❌ userId is null');
    return null;
  }

  final firestore = ref.watch(firestoreProvider);
  try {
    final doc = await firestore.collection('garages').doc(userId).get();
    print('📄 Garage doc exists: ${doc.exists}');
    print('📊 Garage data: ${doc.data()}');
    
    if (doc.exists) {
      final data = doc.data();
      final name = data?['name'] as String? ?? 'Garage';
      final phone = data?['phone'] as String? ?? 'N/A';
      print('✅ Garage name=$name, phone=$phone');
      return {
        'name': name,
        'phone': phone,
      };
    }
    print('⚠️ Garage document does not exist for userId=$userId');
    return null;
  } catch (e, st) {
    print('❌ Error fetching garage info: $e');
    print('Stack: $st');
    return null;
  }
});

/// Provider để lấy danh sách xe của user hiện tại (Real-time stream)
final currentUserVehiclesProvider = StreamProvider<List<Vehicle>>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return Stream.value([]);

  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((doc) {
    try {
      if (doc.exists) {
        final data = doc.data();
        // Sử dụng field 'vehicles' thay vì 'vehicleTypes'
        final vehiclesData = data?['vehicles'] as List<dynamic>? ?? [];
        
        // Convert to Vehicle objects using UserModel logic
        return vehiclesData.map((e) {
          // 🔵 DATA CŨ: String
          if (e is String) {
            return Vehicle(type: e);
          }

          // 🟢 DATA MỚI: Map
          if (e is Map<String, dynamic>) {
            return Vehicle.fromMap(e);
          }

          // Fallback cho data không hợp lệ
          return Vehicle(type: e.toString());
        }).toList();
      }
      return <Vehicle>[];
    } catch (e) {
      print('❌ Error parsing user vehicles: $e');
      return <Vehicle>[];
    }
  }).handleError((e) {
    print('❌ Error streaming user vehicles: $e');
    return <Vehicle>[];
  });
});

/// Provider để lấy vehicles theo subcollection (cho phương tiện mới)
final currentUserVehiclesSubcollectionProvider = StreamProvider<List<Vehicle>>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return Stream.value([]);

  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('users')
      .doc(userId)
      .collection('vehicles')
      .snapshots()
      .map((snapshot) {
    try {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Vehicle.fromMap(data..['id'] = doc.id);
      }).toList();
    } catch (e) {
      print('❌ Error parsing vehicles subcollection: $e');
      return <Vehicle>[];
    }
  }).handleError((e) {
    print('❌ Error streaming vehicles subcollection: $e');
    return <Vehicle>[];
  });
});

/// Combined provider để merge vehicles từ cả 2 nguồn
final allUserVehiclesProvider = StreamProvider<List<Vehicle>>((ref) async* {
  final mainVehiclesAsync = ref.watch(currentUserVehiclesProvider);
  final subVehiclesAsync = ref.watch(currentUserVehiclesSubcollectionProvider);
  
  await for (final mainVehicles in mainVehiclesAsync.when(
    data: (data) => Stream.value(data),
    loading: () => Stream.value(<Vehicle>[]),
    error: (_, __) => Stream.value(<Vehicle>[]),
  )) {
    await for (final subVehicles in subVehiclesAsync.when(
      data: (data) => Stream.value(data),
      loading: () => Stream.value(<Vehicle>[]),
      error: (_, __) => Stream.value(<Vehicle>[]),
    )) {
      // Combine và remove duplicates
      final allVehicles = <Vehicle>[...mainVehicles, ...subVehicles];
      final uniqueVehicles = <Vehicle>[];
      final seen = <String>{};
      
      for (final vehicle in allVehicles) {
        final key = '${vehicle.type}_${vehicle.description ?? ''}';
        if (!seen.contains(key)) {
          seen.add(key);
          uniqueVehicles.add(vehicle);
        }
      }
      
      yield uniqueVehicles;
      break;
    }
  }
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  StreamSubscription<User?>? _sub;

  AuthNotifier(this.ref)
    : super(const AuthState(isLoggedIn: false, isInitialized: false)) {
    _listenAuth();
  }

  void _listenAuth() {
    _sub = ref.read(firebaseAuthProvider).authStateChanges().listen((
      user,
    ) async {
      if (user == null) {
        state = const AuthState.unauthenticated();
      } else {
        await _detectRoleFromFirestore(user.uid);
      }
    });
  }

  Future<void> _detectRoleFromFirestore(String uid) async {
    try {
      final firestore = ref.read(firestoreProvider);

      final userDoc = await firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        state = AuthState(
          isLoggedIn: true,
          isInitialized: true,
          userId: uid,
          role: UserRole.customer,
        );
        return;
      }

      final garageDoc = await firestore.collection('garages').doc(uid).get();

      if (garageDoc.exists) {
        state = AuthState(
          isLoggedIn: true,
          isInitialized: true,
          userId: uid,
          role: UserRole.garage,
        );
        return;
      }
      throw Exception('Account not found in users or garages');
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
