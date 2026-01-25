class ChangePasswordState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const ChangePasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  ChangePasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}
