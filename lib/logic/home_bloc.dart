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

// --- BLOC ---
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AnimeRepository animeRepository;

  HomeBloc({required this.animeRepository}) : super(HomeInitial()) {
    on<FetchHomeData>((event, emit) async {
      emit(HomeLoading());
      try {
        final animeList = await animeRepository.getPopularAnime(isRefresh: event.isRefresh);
        emit(HomeLoaded(popularAnime: animeList));
      } catch (e) {
        emit(HomeError(message: e.toString().replaceFirst("Exception: ", "")));
      }
    });
  }
}