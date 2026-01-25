import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:road_assist/data/models/user_model.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// ===============================
/// REALTIME USER ACCOUNT PROVIDER
/// ===============================
final accountStreamProvider = StreamProvider<UserModel?>((ref) {
  final authAsync = ref.watch(authStateProvider);

  return authAsync.when(
    data: (authUser) {
      // 🔴 Chưa đăng nhập
      if (authUser == null) {
        return const Stream.empty();
      }

      // 🔵 Đã đăng nhập → listen đúng UID hiện tại
      return FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;

            final data = doc.data();
            if (data == null) return null;

            return UserModel.fromJson(data);
          });
    },

    // loading / error → không emit user
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:road_assist/ui/user/account/model/account_action.dart';
// import 'package:road_assist/ui/user/account/model/vehicle_model.dart';
// import 'package:road_assist/ui/user/account/viewmodel/account_state.dart';

// final accountVmProvider =
//     StateNotifierProvider.autoDispose<AccountViewModel, AccountState>(
//       (ref) => AccountViewModel(ref),
//     );

// class AccountViewModel extends StateNotifier<AccountState> {
//   AccountViewModel(this.ref) : super(AccountState.initial());
//   final Ref ref;

//   void updateVehicleDescription(Vehicle vehicle, String? description) {
//     final updated = state.vehicles.map((v) {
//       if (v == vehicle) {
//         return Vehicle(
//           name: v.name,
//           image: v.image,
//           description: description?.trim().isEmpty ?? true ? null : description,
//         );
//       }
//       return v;
//     }).toList();

//     state = state.copyWith(vehicles: updated);
//   }

//   void removeVehicle(Vehicle vehicle) {
//     final updated = [...state.vehicles]..remove(vehicle);
//     state = state.copyWith(vehicles: updated);
//   }

//   List<AccountActionItem> get actions => const [
//     AccountActionItem(
//       type: AccountActionType.rescues,
//       title: 'Các cuộc cứu hộ',
//       icon: Icons.search,
//     ),
//     AccountActionItem(
//       type: AccountActionType.favoriteGarage,
//       title: 'Garage yêu thích',
//       icon: Icons.favorite_border,
//     ),
//     AccountActionItem(
//       type: AccountActionType.personalInfo,
//       title: 'Thông tin cá nhân',
//       icon: Icons.person_outline,
//     ),
//     AccountActionItem(
//       type: AccountActionType.changePassword,
//       title: 'Đổi mật khẩu',
//       icon: Icons.lock_outline,
//     ),
//   ];

//   Future<void> logout() async {
//     await FirebaseAuth.instance.signOut();
//   }

//   void onActionTap(AccountActionType type) {
//     // TODO
//   }
// }
