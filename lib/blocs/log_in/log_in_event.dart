part of 'log_in_bloc.dart';

@immutable
abstract class LogInEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class NameChanged extends LogInEvent {
  final String name;
  NameChanged(this.name);
  @override
  List<Object> get props => [name];
}

class EmailChanged extends LogInEvent {
  final String email;

  EmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class PasswordChanged extends LogInEvent {
  final String password;

  PasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class Submitted extends LogInEvent {
  final bool isDelete;

  Submitted(this.isDelete);
  @override
  List<Object> get props => [isDelete];
}

class FacebookLoginAttempt extends LogInEvent {
  final bool isDelete;

  FacebookLoginAttempt(this.isDelete);
  @override
  List<Object> get props => [isDelete];
}

class GoogleLogin extends LogInEvent {
  final bool isDelete;

  GoogleLogin(this.isDelete);
  @override
  List<Object> get props => [isDelete];
}

class SignUp extends LogInEvent {}

class ForgotPassword extends LogInEvent {}




