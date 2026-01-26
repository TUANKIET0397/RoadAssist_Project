  enum UserRole { customer, garage }
  
  class AuthState {
    final bool isLoggedIn;
    final bool isInitialized; // 👈 THÊM
    final String? userId;
    final UserRole? role;
  
    const AuthState({
      required this.isLoggedIn,
      required this.isInitialized,
      this.userId,
      this.role,
    });
  
    const AuthState.unauthenticated()
      : isLoggedIn = false,
        isInitialized = false,
        userId = null,
        role = null;
  }
