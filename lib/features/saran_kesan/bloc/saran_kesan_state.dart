part of 'saran_kesan_bloc.dart';

abstract class SaranKesanState extends Equatable {
  const SaranKesanState();
  @override
  List<Object?> get props => [];
}

class SaranKesanInitial extends SaranKesanState {}
class SaranKesanLoading extends SaranKesanState {}

class SaranKesanSaveSuccess extends SaranKesanState {}

class SaranKesanLoaded extends SaranKesanState {
  final SaranKesan? entry;
  const SaranKesanLoaded({this.entry});
  @override
  List<Object?> get props => [entry];
}

class SaranKesanError extends SaranKesanState {
  final String message;
  const SaranKesanError({required this.message});
  @override
  List<Object> get props => [message];
}