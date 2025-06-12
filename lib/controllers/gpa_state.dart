part of 'gpa_cubit.dart';

abstract class GpaState {}

class GpaInitial extends GpaState {}

class GpaLoading extends GpaState {}

class GpaError extends GpaState {
  final String message;
  GpaError(this.message);
}

class GpaLoaded extends GpaState {
  final double prevGpa;
  final double prevHours;
  GpaLoaded({required this.prevGpa, required this.prevHours});
}

class GpaCalculated extends GpaState {
  final double semesterGpa;
  final double cumulativeGpa;
  final double totalCredits;

  GpaCalculated({
    required this.semesterGpa,
    required this.cumulativeGpa,
    required this.totalCredits,
  });
}

class GpaSaved extends GpaState {}

class GpaUpdated extends GpaState {}

