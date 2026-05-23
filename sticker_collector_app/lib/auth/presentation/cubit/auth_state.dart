import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

/// Authentication state enum
enum AuthStateStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Auth state class
class AuthState extends Equatable {
  final AuthStateStatus status;
  final UserProfile? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStateStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// Initial state
  const AuthState.initial() : this();

  /// Loading state
  const AuthState.loading()
      : this(status: AuthStateStatus.loading);

  /// Authenticated state
  const AuthState.authenticated(UserProfile user)
      : this(status: AuthStateStatus.authenticated, user: user);

  /// Unauthenticated state
  const AuthState.unauthenticated()
      : this(status: AuthStateStatus.unauthenticated);

  /// Error state
  const AuthState.error(String message)
      : this(status: AuthStateStatus.error, errorMessage: message);

  /// Copy with method for state updates
  AuthState copyWith({
    AuthStateStatus? status,
    UserProfile? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if authenticated
  bool get isAuthenticated => status == AuthStateStatus.authenticated;

  /// Check if loading
  bool get isLoading => status == AuthStateStatus.loading;

  /// Get user ID or null
  String? get userId => user?.uid;

  @override
  List<Object?> get props => [status, user, errorMessage];
}