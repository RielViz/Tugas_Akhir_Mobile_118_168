// -----------------------------------------
// lib/features/shell/cubit/shell_cubit.dart
// -----------------------------------------

import 'package:bloc/bloc.dart';

class ShellCubit extends Cubit<int> {
  ShellCubit() : super(0);

  void changePage(int index) {
    emit(index);
  }
}