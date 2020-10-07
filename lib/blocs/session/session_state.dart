part of 'session_bloc.dart';

@immutable
abstract class SessionState extends Equatable{
  Session session;
  Last7DaysChooser last7daysChooser;
  @override
  List<Object> get props => [];
}

class InitialSessionState extends SessionState {
  final Session session;
  final Last7DaysChooser last7daysChooser;

  InitialSessionState(this.session, this.last7daysChooser);

  @override
  List<Object> get props => [session, last7daysChooser];
}

class IsSubmitting extends SessionState{
  final Session session;
  final Last7DaysChooser last7daysChooser;

  IsSubmitting(this.session, this.last7daysChooser);

  @override
  List<Object> get props => [session, last7daysChooser];
}

class SuccessfullySubmitted extends SessionState{
  final Session session;
  final Last7DaysChooser last7daysChooser;
  SuccessfullySubmitted(this.session, this.last7daysChooser);

  @override
  List<Object> get props => [session, last7daysChooser];
}

class SubmissionFailed extends SessionState{
  final Session session;
  final Last7DaysChooser last7daysChooser;
  SubmissionFailed(this.session, this.last7daysChooser);

  @override
  List<Object> get props => [session, last7daysChooser];
}

class InformationIncomplete extends SessionState{
  final Session session;
  final Last7DaysChooser last7daysChooser;
  final List<bool> conditions;

  InformationIncomplete(this.session, this.last7daysChooser, this.conditions);

  @override
  List<Object> get props => [session, last7daysChooser, conditions];
}