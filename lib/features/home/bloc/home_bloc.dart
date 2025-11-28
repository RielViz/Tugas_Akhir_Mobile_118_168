// -------------------------------------
// lib/features/home/bloc/home_bloc.dart
// -------------------------------------

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ta_teori/data/models/anime_model.dart';
import 'package:ta_teori/data/repositories/anime_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AnimeRepository animeRepository;

  HomeBloc({required this.animeRepository}) : super(HomeInitial()) {
    on<FetchHomeData>((event, emit) async {
      emit(HomeLoading());

      try {
        final List<AnimeModel> animeList =
            await animeRepository.getPopularAnime(isRefresh: event.isRefresh);

        emit(HomeLoaded(popularAnime: animeList));
      } catch (e) {
        emit(HomeError(message: e.toString().replaceFirst("Exception: ", "")));
      }
    });
  }
}