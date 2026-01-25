// final editProfileVMProvider = StateNotifierProvider<EditProfileVM, bool>((ref) {
//   return EditProfileVM(ref);
// });

// class EditProfileVM extends StateNotifier<bool> {
//   EditProfileVM(this.ref) : super(false);

//   final Ref ref;

//   Future<void> saveProfile({
//     required String firstName,
//     required String lastName,
//     required String phone,
//     required String address,
//   }) async {
//     try {
//       state = true;

//       final uid = FirebaseAuth.instance.currentUser!.uid;
//       final fullName = '$firstName $lastName'.trim();

//       await FirebaseFirestore.instance.collection('users').doc(uid).update({
//         'name': fullName,
//         'phone': phone,
//         'address': address,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } finally {
//       state = false;
//     }
//   }
// }
