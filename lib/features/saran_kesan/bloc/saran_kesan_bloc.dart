import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ta_teori/data/models/saran_kesan_model.dart';
import 'package:ta_teori/data/repositories/saran_kesan_repository.dart';

part 'saran_kesan_event.dart';
part 'saran_kesan_state.dart';

class SaranKesanBloc extends Bloc<SaranKesanEvent, SaranKesanState> {
  final SaranKesanRepository repository;

  SaranKesanBloc({required this.repository}) : super(SaranKesanInitial()) {

    // Handler untuk Load data
    on<LoadSaranKesan>((event, emit) {
      emit(SaranKesanLoading());
      try {
        final entry = repository.getSaranKesan();
        emit(SaranKesanLoaded(entry: entry));
      } catch (e) {
        emit(SaranKesanError(message: e.toString()));
      }
    });

    // Handler untuk Save data
    on<SaveSaranKesan>((event, emit) async {
      emit(SaranKesanLoading());
      try {
        await repository.saveSaranKesan(event.saran, event.kesan);
        emit(SaranKesanSaveSuccess());
        add(LoadSaranKesan()); 
      } catch (e) {
        emit(SaranKesanError(message: e.toString()));
      }
    });
  }
}