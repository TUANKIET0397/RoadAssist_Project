abstract class RoutePaths {
  // // auth
  // static const login = '/login';
  // static const register = '/register';
  // ===== AUTH =====
  static const authRoot = '/auth';

  static const authRole = '$authRoot/role';

  static const userLogin = '$authRoot/user/login';
  static const userRegister = '$authRoot/user/register';

  static const garageLogin = '$authRoot/garage/login';
  static const garageRegister = '$authRoot/garage/register';

  // user
  static const userRoot = '/user';

  static const userChat = '$userRoot/chat';
  static const userGarage = '$userRoot/garage';
  static const userHome = '$userRoot/home';
  static const userHistory = '$userRoot/history';
  static const userAccount = '$userRoot/account';

  // garage
  static const garageRoot = '/garage';

  static const garageChat = '$garageRoot/chat';
  static const garageReview = '$garageRoot/review';
  static const garageHome = '$garageRoot/home';
  static const garageHistory = '$garageRoot/history';
  static const garageAccount = '$garageRoot/account';
}
