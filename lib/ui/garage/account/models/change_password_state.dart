class ChangePasswordState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const ChangePasswordState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  ChangePasswordState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
