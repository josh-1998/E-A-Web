part of 'result_bloc.dart';

@immutable
abstract class ResultState extends Equatable{
  Result result;
  @override
  List<Object> get props => [];
}

class InitialResultState extends ResultState {
  final Result result;

  InitialResultState(this.result);
  @override
  List<Object> get props => [result];
}

class UpdatedResultState extends ResultState {
  final Result result;

  UpdatedResultState(this.result);
  @override
  List<Object> get props => [result];
}

class IsSubmitting extends ResultState{
  final Result result;

  IsSubmitting(this.result);
  @override
  List<Object> get props => [result];
}

class SubmissionSuccessful extends ResultState{
  final Result result;
  SubmissionSuccessful(this.result);
  @override
  List<Object> get props => [result];
}

class SubmissionFailed extends ResultState{
  final Result result;

  SubmissionFailed(this.result);
  @override
  List<Object> get props => [result];
}

class IncompleteInformation extends ResultState{
  final Result result;
  final List<bool> conditions;

  IncompleteInformation(this.result, this.conditions);
  @override
  List<Object> get props => [result, conditions];
}