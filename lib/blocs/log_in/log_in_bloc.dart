import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:meta/meta.dart';

import '../../misc/user_repository.dart';

part 'log_in_event.dart';

part 'log_in_state.dart';

class LogInBloc extends Bloc<LogInEvent, LogInState> {
  final UserRepository _userRepository;

  LogInBloc(@required UserRepository userRepository)
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  LogInState get initialState => InitialLoginState();

  String name;
  String email;
  String password;

  @override
  Stream<LogInState> mapEventToState(LogInEvent event) async* {
    if (event is NameChanged) {
      name = event.name;
      yield InitialLoginState();
    } else if (event is EmailChanged) {
      email = event.email;
      yield InitialLoginState();
    } else if (event is PasswordChanged) {
      password = event.password;
      yield InitialLoginState();
    } else if (event is Submitted) {
      yield IsSubmitting();
      try {
        print("email: " + email + ". Password: " + password);
        await _userRepository.signInWithCredentials(
            email.trim(), password, event.isDelete);
        yield SuccessfulLogin();
      } catch (e) {
        print(e);
        yield LoginFailure();
      }
//      catch(e){
//        print(e);
//        yield LoginFailure();
//      }
    } else if (event is SignUp) {
      print(email);
      yield IsSubmitting();
      try {
        await _userRepository.signUp(email: email.trim(), password: password);
        print('user created');
        await _userRepository.signInWithCredentials(email, password, false);
        yield SuccessfulLogin();
      } catch (e) {
        print(e);
        yield LoginFailure();
      }
    } else if (event is FacebookLoginAttempt) {
      yield IsSubmitting();
      try {
        await _userRepository.signInWithFacebook(event.isDelete);
        yield SuccessfulLogin();
      } catch (e) {
        print(e);
        yield LoginFailure();
      }
    } else if (event is GoogleLogin) {
      yield IsSubmitting();
      try {
        await _userRepository.signInWithGoogle(event.isDelete);
        yield SuccessfulLogin();
      } catch (e) {
        yield LoginFailure();
      }
    }
  }
}
