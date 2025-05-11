part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitialState extends AuthState {}

class LoginSuccessState extends AuthState {
  String message;
  LoginSuccessState({required this.message});}

class LoadingState extends AuthState {}

class SuccessState extends AuthState {}

class FailedState extends AuthState {
  String message;
  FailedState({required this.message});
}

