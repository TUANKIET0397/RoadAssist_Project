import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:road_assist/ui/user/rescue/view/rescueRequest_screen.dart';

import 'route_paths.dart';
import 'route_redirect.dart';

import 'package:road_assist/core/providers/auth_provider.dart';
import 'package:road_assist/ui/navigation/view/user_main_screen.dart';

// ===== AUTH UI =====
import 'package:road_assist/ui/auth/view/auth_role_screen.dart';
import 'package:road_assist/ui/auth/view/login_screen.dart';
import 'package:road_assist/ui/auth/view/user_register_screen.dart';

import 'package:road_assist/ui/auth/view/garage_register_screen.dart';

// ===== USER UI =====
import 'package:road_assist/ui/user/chat/view/chatList_screen.dart';
import 'package:road_assist/ui/user/garage/view/garage_screen.dart';
import 'package:road_assist/ui/user/home/view/home_screen.dart';
import 'package:road_assist/ui/user/history/view/history_screen.dart';
import 'package:road_assist/ui/user/account/view/account_screen.dart';

import 'package:road_assist/ui/user/garage/view/garageDetail.dart';

// ===== GARAGE UI =====
import 'package:road_assist/ui/garage/review/view/garage_reviews_screen.dart';
import 'package:road_assist/ui/navigation/view/garage_main_screen.dart';
//history
import 'package:road_assist/ui/garage/account/view/garage_account_screen.dart';

import 'package:road_assist/ui/garage/account/view/info_screen.dart';
import 'package:road_assist/ui/garage/account/view/password_reset_sreen.dart';

/// GoRouter provider
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    debugLogDiagnostics: true,

    /// App bắt đầu từ màn chọn role
    initialLocation: RoutePaths.authRole,

    /// ===== REDIRECT (ủy quyền cho route_redirect) =====
    redirect: (context, state) {
      debugPrint('➡️ location = ${state.uri}');
      debugPrint('➡️ role = ${authState.role}');
      return RouteRedirect.handle(
        auth: authState,
        location: state.uri.path,
        // location: state.uri.toString(),
      );
    },

    routes: [
      // =================================================
      // ================== AUTH FLOW ====================
      // =================================================
      GoRoute(
        path: RoutePaths.authRole,
        builder: (_, __) => const AuthRoleScreen(),
      ),

      GoRoute(
        path: RoutePaths.userLogin,
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: RoutePaths.garageLogin,
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: RoutePaths.userRegister,
        builder: (_, __) => const UserRegisterScreen(),
      ),

      GoRoute(
        path: RoutePaths.garageRegister,
        builder: (_, __) => const GarageRegisterScreen(),
      ),

      // =================================================
      // ================= USER FLOW =====================
      // =================================================
      ShellRoute(
        builder: (_, __, child) {
          return UserMainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: RoutePaths.userHome,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: RoutePaths.userChat,
            builder: (_, __) => const ChatListScreen(),
          ),
          GoRoute(
            path: RoutePaths.userGarage,
            builder: (_, __) => const GarageListScreen(),
            routes: [
              GoRoute(path: 'detail', builder: (_, __) => const GarageDetailScreen()),
            ],
          ),
          GoRoute(
            path: RoutePaths.userHistory,
            builder: (_, __) => const HistoryScreen(),
          ),
          GoRoute(
            path: RoutePaths.userAccount,
            builder: (_, __) => const AccountScreen(),
          ),
          GoRoute(
            path: '/rescue-request',
            builder: (context, state) => const RescueRequestScreen(),
          ),
        ],
      ),

      // =================================================
      // ================= GARAGE FLOW ===================
      // =================================================
      ShellRoute(
        builder: (_, __, child) {
          return GarageMainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: RoutePaths.garageChat,
            builder: (_, __) => const ChatListScreen(),
          ),
          GoRoute(
            path: RoutePaths.garageReview,

            builder: (_, __) => const GarageReviewsScreen(),
          ),
          GoRoute(
            path: RoutePaths.garageHome,
            builder: (_, __) => Text('hello'),

            // builder: (_, __) => const GarageHomeScreen(),
          ),
          GoRoute(
            path: RoutePaths.garageHistory,
            builder: (_, __) => Text('hello'),

            // builder: (_, __) => const GarageHistoryScreen(),
          ),
          GoRoute(
            path: RoutePaths.garageAccount,
            builder: (_, __) => const GarageAccountScreen(),
            routes: [
              GoRoute(path: 'info', builder: (_, __) => const InfoScreen()),
              GoRoute(
                path: 'passwordreset',
                builder: (_, __) => const PasswordResetSreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
