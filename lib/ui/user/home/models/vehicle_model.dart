class VehicleGridData {
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String image;

  const VehicleGridData({
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.image,
  });
}

final vehicleGridData = [
  VehicleGridData(
    title: 'Xe Máy Các Loại',
    subtitle1: 'Tay ga',
    subtitle2: 'Bạn đã đăng ký',
    image: 'assets/images/illustrations/XeTayGa.png',
  ),
  VehicleGridData(
    title: 'Ô tô',
    subtitle1: '4 chỗ',
    subtitle2: 'Chưa đăng ký',
    image: 'assets/images/illustrations/XeMay.png',
  ),
];
