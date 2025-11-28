// -------------------------------------
// lib/logic/home_bloc.dart
// -------------------------------------

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/anime_model.dart';
import '../repositories/anime_repository.dart';

// --- EVENTS ---
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

class FetchHomeData extends HomeEvent {
  final bool isRefresh;
  const FetchHomeData({this.isRefresh = false});
  @override
  List<Object> get props => [isRefresh];
}

// --- STATES ---
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  // Simpan 4 list terpisah
  final List<AnimeModel> trending;
  final List<AnimeModel> thisSeason;
  final List<AnimeModel> nextSeason;
  final List<AnimeModel> allTime;

  const HomeLoaded({
    required this.trending,
    required this.thisSeason,
    required this.nextSeason,
    required this.allTime,
  });

  @override
  List<Object> get props => [trending, thisSeason, nextSeason, allTime];
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
  @override
  List<Object> get props => [message];
}

// --- BLOC ---
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AnimeRepository animeRepository;

  HomeBloc({required this.animeRepository}) : super(HomeInitial()) {
    on<FetchHomeData>((event, emit) async {
      emit(HomeLoading());
      try {
        // Ambil data map dari repository
        final data = await animeRepository.getHomeData(isRefresh: event.isRefresh);
        
        emit(HomeLoaded(
          trending: data['trending']!,
          thisSeason: data['thisSeason']!,
          nextSeason: data['nextSeason']!,
          allTime: data['allTime']!,
        ));
      } catch (e) {
        emit(HomeError(message: e.toString().replaceFirst("Exception: ", "")));
      }
    });
  }
}