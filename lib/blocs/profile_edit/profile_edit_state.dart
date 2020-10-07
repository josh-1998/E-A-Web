part of 'profile_edit_bloc.dart';

@immutable
abstract class ProfileEditState extends Equatable{
  User user;
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class InitialProfileEditState extends ProfileEditState {
  final User user;

  InitialProfileEditState(this.user);

  @override
  List<Object> get props => [user];
}

class IsSubmitting extends ProfileEditState {
  final User user;

  IsSubmitting(this.user);

  @override
  List<Object> get props => [user];
}

class SubmittedSuccessfully extends ProfileEditState {
  final User user;

  SubmittedSuccessfully(this.user);

  @override
  List<Object> get props => [user];
}

class SubmittedUnsuccessfully extends ProfileEditState {
  final User user;

  SubmittedUnsuccessfully(this.user);

  @override
  List<Object> get props => [user];
}