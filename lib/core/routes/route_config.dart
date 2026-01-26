/// Route configuration metadata for controlling navbar visibility
class RouteConfig {
  /// Routes that should hide the navbar during rescue/completion flow
  static const Set<String> hideNavbarRoutes = {
    // User rescue flow
    '/rescue-request',
    '/user/completion',

    // Garage rescue flow
    '/garage/rescue-request-detail/:requestId',
    '/garage/completion',

    // Auth flow
    '/auth/role',
    '/auth/user/login',
    '/auth/garage/login',
    '/auth/user/register',
    '/auth/garage/register',

    // Detail screens (not main tabs)
    '/user/garage/detail',
    '/garage/account/info',
    '/garage/account/passwordreset',
  };

  /// Routes that should always show the navbar
  static const Set<String> showNavbarRoutes = {
    // Main tabs
    '/user/home',
    '/user/chat',
    '/user/garage',
    '/user/history',
    '/user/account',
    '/garage/home',
    '/garage/chat',
    '/garage/review',
    '/garage/history',
    '/garage/account',
  };

  /// Check if a route should hide the navbar
  static bool shouldHideNavbar(String path) {
    // Check exact matches
    if (hideNavbarRoutes.contains(path)) {
      return true;
    }

    // Check pattern matches (for dynamic routes)
    for (final route in hideNavbarRoutes) {
      if (route.contains(':') && _matchesPattern(path, route)) {
        return true;
      }
    }

    return false;
  }

  /// Check if a route should show the navbar
  static bool shouldShowNavbar(String path) {
    // Check exact matches
    if (showNavbarRoutes.contains(path)) {
      return true;
    }

    // Check pattern matches
    for (final route in showNavbarRoutes) {
      if (route.contains(':') && _matchesPattern(path, route)) {
        return true;
      }
    }

    return false;
  }

  /// Helper to match dynamic routes
  static bool _matchesPattern(String path, String pattern) {
    final pathSegments = path.split('/');
    final patternSegments = pattern.split('/');

    if (pathSegments.length != patternSegments.length) {
      return false;
    }

    for (int i = 0; i < patternSegments.length; i++) {
      final segment = patternSegments[i];
      if (segment.startsWith(':')) {
        // Dynamic segment, matches anything
        continue;
      }
      if (pathSegments[i] != segment) {
        return false;
      }
    }

    return true;
  }
}
