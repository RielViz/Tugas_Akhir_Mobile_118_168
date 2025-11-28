// ----------------------------------------
// lib/features/lbs_demo/bloc/lbs_bloc.dart
// ----------------------------------------

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ta_teori/data/repositories/location_repository.dart';

part 'lbs_event.dart';
part 'lbs_state.dart';

class LbsBloc extends Bloc<LbsEvent, LbsState> {
  final LocationRepository locationRepository;

  LbsBloc({required this.locationRepository}) : super(LbsInitial()) {
    on<FetchLocation>((event, emit) async {
      emit(LbsLoading());
      try {
        final position = await locationRepository.getCurrentPosition();
        emit(LbsLoaded(position: position));
      } catch (e) {
        emit(LbsError(message: e.toString().replaceFirst("Exception: ", "")));
      }
    });
  }
}