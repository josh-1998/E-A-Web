part of 'session_bloc.dart';

@immutable
abstract class SessionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UpdateTitle extends SessionEvent {
  final String title;

  UpdateTitle(this.title);

  @override
  List<Object> get props => [title];
}

class UpdateIntensity extends SessionEvent {
  final int intensity;

  UpdateIntensity(this.intensity);

  @override
  List<Object> get props => [intensity];
}

class UpdatePerformance extends SessionEvent {
  final int performance;

  UpdatePerformance(this.performance);

  @override
  List<Object> get props => [performance];
}

class UpdateLengthOfSession extends SessionEvent {
  int lengthOfSession;

  UpdateLengthOfSession(this.lengthOfSession);

  @override
  List<Object> get props => [lengthOfSession];
}

class UpdateFeeling extends SessionEvent {
  final String feeling;

  UpdateFeeling(this.feeling);

  @override
  List<Object> get props => [feeling];
}

class UpdateTarget extends SessionEvent {
  final String target;

  UpdateTarget(this.target);

  @override
  List<Object> get props => [target];
}

class UpdateReflections extends SessionEvent {
  final String reflections;

  UpdateReflections(this.reflections);

  @override
  List<Object> get props => [reflections];
}

class Submit extends SessionEvent {}

class ChangeDateBackwards extends SessionEvent {}

class ChangeDateForwards extends SessionEvent {}
