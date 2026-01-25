import 'package:flutter/material.dart';
import 'package:road_assist/core/routes/route_config.dart';

/// Observer for GoRouter to log route changes and manage navbar visibility
class NavigationObserver extends NavigatorObserver {
  NavigationObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logRoute('pushed', route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logRoute('popped', route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logRoute('removed', route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _logRoute('replaced', newRoute);
    }
  }

  void _logRoute(String action, Route<dynamic> route) {
    try {
      final name = route.settings.name ?? 'Unknown';
      debugPrint('🚀 Route $action: $name');
      
      // Determine navbar visibility based on route
      if (RouteConfig.shouldHideNavbar(name)) {
        debugPrint('🔒 Should hide navbar for: $name');
      } else if (RouteConfig.shouldShowNavbar(name)) {
        debugPrint('👁️ Should show navbar for: $name');
      }
    } catch (e) {
      debugPrint('❌ Error logging route: $e');
    }
  }
}
