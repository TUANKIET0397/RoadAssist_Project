import 'package:road_assist/core/auth/auth_state.dart';
import 'package:road_assist/core/routes/route_paths.dart';

class RouteRedirect {
  static String? handle({required AuthState auth, required String location}) {
    // 0️⃣ Auth chưa sẵn sàng
    if (!auth.isInitialized) return null;

    final isAuthRoute = location.startsWith(RoutePaths.authRoot);

    // 1️⃣ CHƯA LOGIN
    if (!auth.isLoggedIn) {
      return isAuthRoute ? null : RoutePaths.authRole;
    }

    // 2️⃣ ĐÃ LOGIN mà vẫn vào auth
    if (isAuthRoute) {
      return auth.role == UserRole.customer
          ? RoutePaths.userHome
          : RoutePaths.garageHome;
    }

    // 3️⃣ ROLE USER
    if (auth.role == UserRole.customer &&
        location.startsWith(RoutePaths.garageRoot)) {
      return RoutePaths.userHome;
    }

    // 4️⃣ ROLE GARAGE
    if (auth.role == UserRole.garage &&
        location.startsWith(RoutePaths.userRoot)) {
      return RoutePaths.garageHome;
    }

    return null;
  }
}
