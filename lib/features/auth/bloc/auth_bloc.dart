// -------------------------------------
// lib/features/auth/bloc/auth_bloc.dart
// -------------------------------------

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ta_teori/data/models/user_model.dart';
import 'package:ta_teori/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
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
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        try {
          // Panggil repository untuk update path di Hive
          final updatedUser = await authRepository.updateProfilePicture(
            currentState.user.username,
            event.imagePath,
          );
          emit(currentState.copyWith(user: updatedUser));
        } catch (e) {
          // Jika gagal, bisa emit error atau biarkan
        }
      }
    });

    on<LogoutButtonPressed>((event, emit) async {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    });
  }
}