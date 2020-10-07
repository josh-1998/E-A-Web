import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:e_athlete_web/models/diary_model.dart';
import 'package:e_athlete_web/misc/useful_functions.dart';
import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

import '../../models/class_definitions.dart';
import '../../misc/user_repository.dart';

part 'graph_event.dart';

part 'graph_state.dart';

class GraphBloc extends Bloc<GraphEvent, GraphState> {
  final UserRepository userRepository;

  ///Map with lists of all sessions with key values of day they were inputted
  Map sessionMap = {};

  /// Limits for the graph
  List<DateTime> limits = [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 7),
    currentDay
  ];

  /// Map with lists of all generalDays with key values of day they were inputted
  Map generalDayMap = {};

  ///List of data for the first graph
  List<GraphObject> dataForGraph1 = [];

  ///List of data for the second graph
  List<GraphObject> dataForGraph2 = [];

  ///The current data that is being shown on graph 1
  String graph1Current = 'Intensity';

  ///The current data that is being shown on graph 2
  String graph2Current = 'Performance';

  ///String being shown on the button to change length of time
  String timeFrame = '2 weeks';

  /// String shown on change time period button
  String timePeriod =
      '${DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 7).day}'
      ' ${numberToMonth[DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 7).month]}'
      ' - ${DateTime.now().day} ${numberToMonth[DateTime.now().month]}';

  /// number of days currently being shown
  int numberOfDays = 7;

  /// way of updating the graphs from the name given
  Map nameToFunction;
  DateTime lastDay =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  Map daysToName = {7: '2 weeks', 14: '3 weeks', 21: '4 weeks', 28: '1 week'};
  GraphBloc({@required this.userRepository}) {}

  ///Function that takes the type of data to be shown and gets the graph
  ///information for that
  ///
  List<GraphObject> nameToFunctionFunction(String graphType) {
    List<GraphObject> returnValue = [];
    if (graphType == 'Intensity') {
      returnValue = getGraphDataIntensity(getAllDaysSession());
    } else if (graphType == 'Performance') {
      returnValue = getGraphDataPerformance(getAllDaysSession());
    } else if (graphType == 'Feeling') {
      returnValue = getGraphDataFeeling(getAllDaysSession());
    } else if (graphType == 'Rest') {
      returnValue = getGraphDataRested(getAllDaysGeneralDay());
    } else if (graphType == 'Nutrition') {
      returnValue = getGraphDataNutrition(getAllDaysGeneralDay());
    } else if (graphType == 'Concentration') {
      returnValue = getGraphDataConcentration(getAllDaysGeneralDay());
    } else if (graphType == 'None') {
      returnValue = <GraphObject>[];
    }

    return returnValue;
  }

  void getIndividualDays() {
    for (GeneralDay generalDay in userRepository.diary.generalDayList) {
      DateTime date = DateTime.parse(generalDay.date);
      generalDayMap.update(date, (existingValue) {
        existingValue.add(generalDay);
        return existingValue;
      }, ifAbsent: () => [generalDay]);
    }
    for (Session session in userRepository.diary.sessionList) {
      DateTime date = DateTime.parse(session.date);
      sessionMap.update(date, (existingValue) {
        existingValue.add(session);
        return existingValue;
      }, ifAbsent: () => [session]);
    }
  }

  List<List> getAllDaysSession() {
    List<List> lastSevenDaysSessions = [];
    sessionMap.forEach((key, value) {
      List _currentDayEvents = value;
      if (_currentDayEvents != null) {
        DateTime _currentDay = key;
        lastSevenDaysSessions.add([_currentDay, _currentDayEvents]);
      }
    });
    //this is a list of lists with [DateTime, [Session, Session, Session etc]
    return lastSevenDaysSessions;
  }

  List<List> getAllDaysGeneralDay() {
    List<List> lastSevenDaysSessions = [];
    generalDayMap.forEach((key, value) {
      List _currentDayEvents = value;
      if (_currentDayEvents != null) {
        DateTime _currentDay = key;
        lastSevenDaysSessions.add([_currentDay, _currentDayEvents]);
      }
    });

    //this is a list of lists with [DateTime, [Session, Session, Session etc]

    return lastSevenDaysSessions;
  }

  List<GraphObject> getGraphDataIntensity(List lastSevenDaySessions) {
    List<GraphObject> returnValue = [];
    for (List item in lastSevenDaySessions) {
      int _totalNumber = 0;
      for (Session _session in item[1]) {
        _totalNumber += _session.intensity;
      }
      int valueToAdd = (_totalNumber / item[1].length).round();

      returnValue.add(GraphObject(item[0], valueToAdd));
    }
    returnValue.sort((a, b) => a.xAxis.compareTo(b.xAxis));
    return returnValue;
  }

  List<GraphObject> getGraphDataPerformance(List lastSevenDaySessions) {
    List<GraphObject> returnValue = [];
    for (List item in lastSevenDaySessions) {
      int _totalNumber = 0;
      for (Session _session in item[1]) {
        _totalNumber += _session.performance;
      }
      int valueToAdd = ((_totalNumber / item[1].length) * 2).round();

      returnValue.add(GraphObject(item[0], valueToAdd));
    }
    returnValue.sort((a, b) => a.xAxis.compareTo(b.xAxis));
    return returnValue;
  }

  List<GraphObject> getGraphDataRested(List lastSevenDaySessions) {
    List<GraphObject> returnValue = [];
    for (List item in lastSevenDaySessions) {
      int _totalNumber = 0;

      for (GeneralDay _generalDay in item[1]) {
        if (_generalDay.rested != null) {
          _totalNumber += _generalDay.rested;
        }
      }

      int valueToAdd = ((_totalNumber / item[1].length)).round();

      returnValue.add(GraphObject(item[0], valueToAdd));
    }
    returnValue.sort((a, b) => a.xAxis.compareTo(b.xAxis));
    return returnValue;
  }

  List<GraphObject> getGraphDataConcentration(List lastSevenDaySessions) {
    List<GraphObject> returnValue = [];
    for (List item in lastSevenDaySessions) {
      int _totalNumber = 0;

      for (GeneralDay _generalDay in item[1]) {
        if (_generalDay.concentration != null) {
          _totalNumber += _generalDay.concentration;
        }
      }

      int valueToAdd = ((_totalNumber / item[1].length)).round();
      returnValue.sort((a, b) => a.xAxis.compareTo(b.xAxis));
      returnValue.add(GraphObject(item[0], valueToAdd));
    }

    return returnValue;
  }

  List<GraphObject> getGraphDataNutrition(List lastSevenDaySessions) {
    List<GraphObject> returnValue = [];
    for (List item in lastSevenDaySessions) {
      int _totalNumber = 0;

      for (GeneralDay _generalDay in item[1]) {
        if (_generalDay.nutrition != null) {
          _totalNumber += _generalDay.nutrition;
        }
      }

      int valueToAdd = ((_totalNumber / item[1].length)).round();

      returnValue.add(GraphObject(item[0], valueToAdd));
    }
    returnValue.sort((a, b) => a.xAxis.compareTo(b.xAxis));
    return returnValue;
  }

  List<GraphObject> getGraphDataFeeling(List lastSevenDaySessions) {
    Map feelingToInt = {
      'Frustrated': 2,
      'Bad': 4,
      'Neutral': 6,
      'Happy': 8,
      'Buzzing': 10
    };
    List<GraphObject> returnValue = [];
    for (List item in lastSevenDaySessions) {
      int _totalNumber = 0;

      for (Session _session in item[1]) {
        if (feelingToInt[_session.feeling] != null) {
          _totalNumber += feelingToInt[_session.feeling];
        }
      }

      int valueToAdd = ((_totalNumber / item[1].length)).round();

      returnValue.add(GraphObject(item[0], valueToAdd));
    }
    returnValue.sort((a, b) => a.xAxis.compareTo(b.xAxis));
    return returnValue;
  }

  @override
  GraphState get initialState {
    getIndividualDays();
    dataForGraph1 = getGraphDataIntensity(getAllDaysSession());
    dataForGraph2 = getGraphDataPerformance(getAllDaysSession());
    return InitialGraphState(dataForGraph1, dataForGraph2);
  }

  @override
  Stream<GraphState> mapEventToState(GraphEvent event) async* {
    if (event is ChangeGraph1) {
      graph1Current = event.valueName;
      dataForGraph1 = nameToFunctionFunction(event.valueName);
      yield NewGraphInfo(dataForGraph1, dataForGraph2);
    }
    if (event is ChangeGraph2) {
      graph2Current = event.valueName;
      dataForGraph2 = nameToFunctionFunction(graph2Current);
      yield NewGraphInfo(dataForGraph1, dataForGraph2);
    }
    if (event is ChangeTimeViewBack) {
      lastDay =
          DateTime(lastDay.year, lastDay.month, lastDay.day - numberOfDays);
      timePeriod =
          '${DateTime(lastDay.year, lastDay.month, lastDay.day - numberOfDays + 1).day} ${numberToMonth[DateTime(lastDay.year, lastDay.month, lastDay.day - numberOfDays + 1).month]}'
          ' - ${lastDay.day} ${numberToMonth[lastDay.month]}';
      getGraphDataNutrition(getAllDaysGeneralDay());
      dataForGraph1 = nameToFunctionFunction(graph1Current);
      dataForGraph2 = nameToFunctionFunction(graph2Current);
      yield NewGraphInfo(dataForGraph1, dataForGraph2);
    }
    if (event is ChangeTimeViewForward) {
      lastDay =
          DateTime(lastDay.year, lastDay.month, lastDay.day + numberOfDays);
      timePeriod =
          '${DateTime(lastDay.year, lastDay.month, lastDay.day - numberOfDays + 1).day} ${numberToMonth[DateTime(lastDay.year, lastDay.month, lastDay.day - numberOfDays + 1).month]}'
          ' - ${lastDay.day} ${numberToMonth[lastDay.month]}';
      getGraphDataNutrition(getAllDaysGeneralDay());
      dataForGraph1 = nameToFunctionFunction(graph1Current);
      dataForGraph2 = nameToFunctionFunction(graph2Current);

      yield NewGraphInfo(dataForGraph1, dataForGraph2);
    }
    if (event is ChangeTimeViewTimeFrame) {
      if (numberOfDays == 28) {
        numberOfDays = 7;
      } else {
        numberOfDays += 7;
      }
      limits = [
        DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day - numberOfDays),
        currentDay
      ];

      yield NewGraphInfo(dataForGraph1, dataForGraph2);
    }
  }
}
