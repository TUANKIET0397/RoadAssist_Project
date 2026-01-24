// class VehicleGridData {
//   final String title;
//   final String subtitle1;
//   final String subtitle2;
//   final String image;
//   final bool isFavorite; //Status Favorite
//   final VoidCallback onFavoriteTap;

//   const VehicleGridData({
//     required this.title,
//     required this.subtitle1,
//     required this.subtitle2,
//     required this.image,
//     required this.isFavorite,
//     required this.onFavoriteTap,
//   });

//   VehicleGridData copyWith({bool? isFavorite}) {
//     return VehicleGridData(
//       title: title,
//       subtitle1: subtitle1,
//       subtitle2: subtitle2,
//       image: image,
//       isFavorite: isFavorite ?? this.isFavorite,
//     );
//   }
// }

// // class VehicleGridNotifier extends StateNotifier<List<VehicleGridData>> {
// //   VehicleGridNotifier() : super(_initialData);

// //   final vehicleGridData = [
// //     VehicleGridData(
// //       title: 'Xe Máy Các Loại',
// //       subtitle1: 'Tay ga',
// //       subtitle2: 'Bạn đã đăng kí',
// //       image: 'assets/images/illustrations/XeTayGa.png',
// //     ),
// //     VehicleGridData(
// //       title: 'Xe Honda Các Loại',
// //       subtitle1: 'Honda',
// //       subtitle2: 'Bạn đã đăng kí',
// //       image: 'assets/images/illustrations/XeMay.png',
// //     ),
// //     VehicleGridData(
// //       title: 'Xe Hơi Các Loại',
// //       subtitle1: 'Xe bốn bánh',
// //       subtitle2: 'Hỗ trợ',
// //       image: 'assets/images/illustrations/XeBonBanh.png',
// //     ),
// //     VehicleGridData(
// //       title: 'Xe Tải Các Loại',
// //       subtitle1: 'Xe Tải',
// //       subtitle2: 'Hỗ trợ',
// //       image: 'assets/images/illustrations/XeTai.png',
// //     ),
// //     VehicleGridData(
// //       title: 'Xe Container',
// //       subtitle1: 'container',
// //       subtitle2: 'Hỗ trợ',
// //       image: 'assets/images/illustrations/XeContainer.png',
// //     ),
// //     VehicleGridData(
// //       title: 'Xe Bus Các loại',
// //       subtitle1: 'Xe Bus',
// //       subtitle2: 'Hỗ trợ',
// //       image: 'assets/images/illustrations/XeBus.png',
// //     ),
// //     VehicleGridData(
// //       title: 'Xe Điện Các Loại',
// //       subtitle1: 'Xe Điện',
// //       subtitle2: 'Hỗ trợ',
// //       image: 'assets/images/illustrations/XeDien.png',
// //     ),
// //     VehicleGridData(
// //       title: 'Xe Ba Gác Các Loại',
// //       subtitle1: 'Xe Ba Gác',
// //       subtitle2: 'Hỗ trợ',
// //       image: 'assets/images/illustrations/XeBaGac.png',
// //     ),
// //   ];

// //   void toggleFavorite(int index) {
// //     final item = state[index];

// //     final updatedItem = item.copyWith(isFavorite: !item.isFavorite);

// //     final newList = [...state];
// //     newList[index] = updatedItem;

// //     // 🔥 sort: favorite lên trên
// //     newList.sort((a, b) {
// //       if (a.isFavorite == b.isFavorite) return 0;
// //       return a.isFavorite ? -1 : 1;
// //     });

// //     state = newList;
// //   }
// // }
