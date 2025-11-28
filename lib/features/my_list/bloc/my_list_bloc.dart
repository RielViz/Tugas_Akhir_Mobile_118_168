// --------------------------------------------
// lib/features/my_list/bloc/my_list_bloc.dart
// --------------------------------------------

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ta_teori/data/models/my_anime_entry_model.dart';
import 'package:ta_teori/data/repositories/my_list_repository.dart';

part 'my_list_event.dart';
part 'my_list_state.dart';

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
      try {
        await myListRepository.addOrUpdateAnime(event.entry);
        add(LoadMyList());
      } catch (e) {
        add(LoadMyList());
      }
    });

    on<RemoveFromMyList>((event, emit) async {
      try {
        await myListRepository.deleteAnime(event.animeId);
        add(LoadMyList());
      } catch (e) {
        emit(MyListLoaded(myList: myListRepository.getMyList()));
      }
    });
  }
}