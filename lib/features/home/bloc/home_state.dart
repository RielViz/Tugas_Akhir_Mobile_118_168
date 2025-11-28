// --------------------------------------
// lib/features/home/bloc/home_state.dart
// --------------------------------------

part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {

  final List<AnimeModel> popularAnime;

  const HomeLoaded({required this.popularAnime});

  @override
  List<Object> get props => [popularAnime];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}