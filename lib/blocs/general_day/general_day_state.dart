part of 'general_day_bloc.dart';

@immutable
abstract class GeneralDayState extends Equatable{
  GeneralDay generalDay;
  Last7DaysChooser last7daysChooser;
  @override

  List<Object> get props => [];
}

class InitialGeneralDayState extends GeneralDayState {
  final GeneralDay generalDay;
  final Last7DaysChooser last7daysChooser;

  InitialGeneralDayState(this.generalDay, this.last7daysChooser);

  @override
  List<Object> get props => [generalDay, last7daysChooser];
}

class IsSubmitting extends GeneralDayState{
  final GeneralDay generalDay;
  final Last7DaysChooser last7daysChooser;
  IsSubmitting(this.generalDay, this.last7daysChooser);
  @override
  List<Object> get props => [generalDay, last7daysChooser];
}

class SubmissionSuccessful extends GeneralDayState{
  final GeneralDay generalDay;
  final Last7DaysChooser last7daysChooser;
  SubmissionSuccessful(this.generalDay, this.last7daysChooser);

  @override
  List<Object> get props => [generalDay, last7daysChooser];
}

class SubmissionFailed extends GeneralDayState{
  final GeneralDay generalDay;
  final Last7DaysChooser last7daysChooser;

  SubmissionFailed(this.generalDay, this.last7daysChooser);

  @override
  List<Object> get props => [generalDay, this.last7daysChooser];
}