part of 'log_in_bloc.dart';

@immutable
abstract class LogInState extends Equatable {

  const LogInState();

  @override
  List<Object> get props => [];
}

class InitialLoginState extends LogInState {
}

class SuccessfulLogin extends LogInState {}

class LoginFailure extends LogInState{}

class IsSubmitting extends LogInState{}
