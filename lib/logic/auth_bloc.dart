// --------------------------------------
// lib/logic/auth_bloc.dart
// --------------------------------------

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

// --- EVENTS ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

// HAPUS: class AuthCheckSession extends AuthEvent {}

class LoginButtonPressed extends AuthEvent {
  final String username;
  final String password;
  const LoginButtonPressed({required this.username, required this.password});
  @override
  List<Object> get props => [username, password];
}

class RegisterButtonPressed extends AuthEvent {
  final String username;
  final String password;
  const RegisterButtonPressed({required this.username, required this.password});
  @override
  List<Object> get props => [username, password];
}

class LogoutButtonPressed extends AuthEvent {}

class ProfilePictureUpdated extends AuthEvent {
  final String imagePath;
  const ProfilePictureUpdated({required this.imagePath});
  @override
  List<Object> get props => [imagePath];
}

// --- STATES ---
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthUnauthenticated extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];

  AuthAuthenticated copyWith({
    User? user,
  }) {
    return AuthAuthenticated(
      user: user ?? this.user,
    );
  }
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object> get props => [message];
}

// --- BLOC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    
    // HAPUS HANDLER on<AuthCheckSession>

    on<LoginButtonPressed>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.login(
          event.username,
          event.password,
        );
        emit(AuthAuthenticated(user: user));
      } catch (e) {
        emit(AuthError(message: e.toString().replaceFirst("Exception: ", "")));
      }
    });

    on<RegisterButtonPressed>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.register(
          event.username,
          event.password,
        );
        final user = await authRepository.login(
          event.username,
          event.password,
        );
        emit(AuthAuthenticated(user: user));
      } catch (e) {
        emit(AuthError(message: e.toString().replaceFirst("Exception: ", "")));
      }
    });

    on<ProfilePictureUpdated>((event, emit) async {
      if (state is AuthAuthenticated) {
        final currentUser = (state as AuthAuthenticated).user;
        try {
          final updatedUser = await authRepository.updateProfilePicture(
            currentUser.username,
            event.imagePath,
          );
          emit((state as AuthAuthenticated).copyWith(user: updatedUser));
        } catch (e) {
          // Error handling
        }
      }
    });

    on<LogoutButtonPressed>((event, emit) async {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    });
  }
}