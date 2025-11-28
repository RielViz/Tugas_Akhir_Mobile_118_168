import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/my_anime_entry_model.dart';
import '../repositories/my_list_repository.dart';

// --- EVENTS ---
abstract class MyListEvent extends Equatable {
  const MyListEvent();
  @override
  List<Object> get props => [];
}

class LoadMyList extends MyListEvent {}

class RemoveFromMyList extends MyListEvent {
  final int animeId;
  const RemoveFromMyList({required this.animeId});
  @override
  List<Object> get props => [animeId];
}

class AddOrUpdateEntry extends MyListEvent {
  final MyAnimeEntryModel entry;
  const AddOrUpdateEntry({required this.entry});
  @override
  List<Object> get props => [entry];
}

// --- STATES ---
abstract class MyListState extends Equatable {
  const MyListState();
  @override
  List<Object> get props => [];
}

class MyListLoading extends MyListState {}

class MyListLoaded extends MyListState {
  final List<MyAnimeEntryModel> myList;
  const MyListLoaded({required this.myList});
  @override
  List<Object> get props => [myList];
}

// --- BLOC ---
class MyListBloc extends Bloc<MyListEvent, MyListState> {
  final MyListRepository myListRepository;

  MyListBloc({required this.myListRepository}) : super(MyListLoading()) {
    on<LoadMyList>((event, emit) {
      try {
        final list = myListRepository.getMyList();
        emit(MyListLoaded(myList: list));
      } catch (e) {
        emit(const MyListLoaded(myList: []));
      }
    });

    on<AddOrUpdateEntry>((event, emit) async {
      await myListRepository.addOrUpdateAnime(event.entry);
      add(LoadMyList());
    });

    on<RemoveFromMyList>((event, emit) async {
      await myListRepository.deleteAnime(event.animeId);
      add(LoadMyList());
    });
  }
}