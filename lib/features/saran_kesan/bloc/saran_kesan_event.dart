part of 'saran_kesan_bloc.dart';

abstract class SaranKesanEvent extends Equatable {
  const SaranKesanEvent();
  @override
  List<Object> get props => [];
}

class LoadSaranKesan extends SaranKesanEvent {}

class SaveSaranKesan extends SaranKesanEvent {
  final String saran;
  final String kesan;
  const SaveSaranKesan({required this.saran, required this.kesan});
  @override
  List<Object> get props => [saran, kesan];
}