import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/firebase_auth_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Cubit for managing authentication state
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  bool _initialized = false;

  AuthCubit(this._authRepository) : super(const AuthState.initial()) {
    // Start listening immediately
    _initialize();
  }


  /// Initialize by listening to auth state changes
  void _initialize() {
    if (_initialized) return;
    _initialized = true;
    
    _authStateSubscription = _authRepository.authStateChanges.listen(
      _onAuthStateChanged,
      onError: (error) {
        emit(AuthState.error('Auth stream error: $error'));
      },
    );
  }

  /// Handle auth state changes from Firebase
  void _onAuthStateChanged(User? user) {
    if (user == null) {
      // User is signed out
      emit(const AuthState.unauthenticated());
      return;
    }
    
    // User is signed in - create profile
    final profile = UserProfile.fromFirebaseUser(user);
    emit(AuthState.authenticated(profile));
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    emit(const AuthState.loading());


    try {
      await _authRepository.signInWithGoogle();
      // Auth state change will trigger _onAuthStateChanged
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
      // Auth state change will trigger _onAuthStateChanged
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