part of 'competition_bloc.dart';

@immutable
abstract class CompetitionState extends Equatable{
  Competition competition;
  @override
  List<Object> get props => [];
}

class InitialCompetitionState extends CompetitionState {
  final Competition competition;

  InitialCompetitionState(this.competition);

  @override
  List<Object> get props => [competition];
}

class IsSubmitting extends CompetitionState{
  final Competition competition;

  IsSubmitting(this.competition);
  @override
  List<Object> get props => [competition];
}

class SubmissionSuccessful extends CompetitionState{
  final Competition competition;

  SubmissionSuccessful(this.competition);
  @override
  List<Object> get props => [competition];
}

class SubmissionFailed extends CompetitionState{
  final Competition competition;

  SubmissionFailed(this.competition);

  @override
  List<Object> get props => [competition];
}

class InformationIncomplete extends CompetitionState{
  final List conditions;
  final Competition competition;
  InformationIncomplete(this.competition, this.conditions);

  @override
  List<Object> get props => [competition, conditions];
}