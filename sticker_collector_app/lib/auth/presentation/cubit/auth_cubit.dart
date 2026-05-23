import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/firebase_auth_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Cubit for managing authentication state
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authStateSubscription;

  AuthCubit(this._authRepository) : super(const AuthState.initial()) {
    _initialize();
  }

  /// Initialize by listening to auth state changes
  void _initialize() {
    _authStateSubscription = _authRepository.authStateChanges.listen(
      _onAuthStateChanged,
      onError: (error) {
        emit(AuthState.error('Auth stream error: $error'));
      },
    );
  }

  /// Handle auth state changes from Firebase
  void _onAuthStateChanged(dynamic user) {
    if (user != null) {
      // User is signed in
      final profile = _authRepository.currentUserProfile;
      if (profile != null) {
        emit(AuthState.authenticated(profile));
      } else {
        emit(const AuthState.error('Failed to load user profile'));
      }
    } else {
      // User is signed out
      emit(const AuthState.unauthenticated());
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    emit(const AuthState.loading());

    try {
      final user = await _authRepository.signInWithGoogle();
      emit(AuthState.authenticated(user));
    } on AuthException catch (e) {
      emit(AuthState.error(e.message));
    } catch (e) {
      emit(AuthState.error('Sign in failed: $e'));
    }
  }

  /// Sign out
  Future<void> signOut() async {
    emit(const AuthState.loading());

    try {
      await _authRepository.signOut();
      emit(const AuthState.unauthenticated());
    } on AuthException catch (e) {
      emit(AuthState.error(e.message));
    } catch (e) {
      emit(AuthState.error('Sign out failed: $e'));
    }
  }

  /// Clear error state
  void clearError() {
    if (state.status == AuthStateStatus.error) {
      emit(const AuthState.unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}