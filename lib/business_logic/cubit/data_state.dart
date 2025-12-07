import '../../data/models/api_model.dart';

abstract class DataState {}

class DataInitial extends DataState {}

class DataLoading extends DataState {}

class DataLoaded extends DataState {
  final List<ApiModel> posts;

  DataLoaded(this.posts);
}

class DataError extends DataState {
  final String message;

  DataError(this.message);
}
