// -----------------------------------------
// lib/features/search/bloc/search_bloc.dart
// -----------------------------------------

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:ta_teori/data/models/anime_model.dart';
import 'package:ta_teori/data/repositories/anime_repository.dart';
import 'package:ta_teori/data/repositories/search_history_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) {
    return events.debounce(duration).switchMap(mapper);
  };
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final AnimeRepository animeRepository;
  final SearchHistoryRepository searchHistoryRepository;

  SearchBloc({
    required this.animeRepository,
    required this.searchHistoryRepository,
  }) : super(const SearchInitial(recentSearches: [])) {
    
    on<LoadRecentSearches>((event, emit) {
      try {
        final history = searchHistoryRepository.getSearchHistory();
        emit(SearchInitial(recentSearches: history));
      } catch (e) {

        emit(const SearchInitial(recentSearches: []));
      }
    });

    on<SearchQueryChanged>(
      (event, emit) async {
        if (event.query.isEmpty) {
          final history = searchHistoryRepository.getSearchHistory();
          emit(SearchInitial(recentSearches: history));
          return;
        }

        emit(SearchLoading());
        try {
          final results = await animeRepository.searchAnime(event.query);
          
          await searchHistoryRepository.addSearchTerm(event.query);
          
          emit(SearchLoaded(results: results));
        } catch (e) {
          emit(SearchError(
              message: e.toString().replaceFirst("Exception: ", "")));
        }
      },
      transformer: _debounce(const Duration(milliseconds: 500)),
    );

    on<ClearRecentSearches>((event, emit) async {
      try {
        await searchHistoryRepository.clearSearchHistory();
        emit(const SearchInitial(recentSearches: []));
      } catch (e) {
        emit(const SearchInitial(recentSearches: []));
      }
    });
  }
}