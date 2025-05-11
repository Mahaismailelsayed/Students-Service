part of 'data_cubit.dart';

@immutable
abstract class DataState {}

class DataInitial extends DataState {}

class DataLoading extends DataState {}

class DataLoaded extends DataState {
  final String? userName;
  final String?email;
  final String?phoneNumber;
  final double gpa;
  final String? id;

  DataLoaded({ this.userName, this.email, this.phoneNumber ,required this.gpa, this.id});
}

class DataError extends DataState {
  final String message;
  DataError(this.message);
}
