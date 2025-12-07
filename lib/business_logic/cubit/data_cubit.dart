import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/repository.dart';
import 'data_state.dart';

class DataCubit extends Cubit<DataState> {
  final Repository repository;

  DataCubit(this.repository) : super(DataInitial());

  void getAllPosts() {
    emit(DataLoading());
    repository.getAllPosts().then((posts) {
      emit(DataLoaded(posts));
    }).catchError((error) {
      emit(DataError(error.toString()));
    });
  }
}
