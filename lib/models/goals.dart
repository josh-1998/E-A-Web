import 'package:e_athlete_web/misc/constants.dart';
import 'package:e_athlete_web/misc/useful_functions.dart';
import 'package:e_athlete_web/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:e_athlete_web/misc/user_repository.dart';
import 'package:e_athlete_web/models/diary_model.dart';
import '../misc/database.dart';
import 'dart:convert';
import '../misc/constants.dart';
import '../misc/exceptions.dart';
import '../misc/user_repository.dart';

class Goal extends DiaryModel {
  String content;
  String deadlineDate;
  String setOnDate;
  String goalType;
  String id;
  String achieved;

  Goal(
      {this.content,
      this.deadlineDate,
      this.setOnDate,
      this.id,
      this.goalType,
      this.achieved = 'true'});

  void sendToItemsToSend(UserRepository _userRepository) {
    _userRepository.diaryItemsToSend.add(Goal(
        content: content,
        deadlineDate: deadlineDate,
        setOnDate: setOnDate,
        id: id));
  }

  Future<DiaryModel> upload(UserRepository _userRepository) async {
    Map body = {};
    if (content != null) body['content'] = this.content;
    if (deadlineDate != null)
      body['deadline'] = this.deadlineDate.toString().substring(0, 10);
    if (setOnDate != null)
      body['set_on_date'] = this.setOnDate.toString().substring(0, 10);
    if (id != null) body['id'] = this.id;
    if (goalType != null) body['goal_type'] = this.goalType;
    if (achieved != null) body['achieved'] = this.achieved;

    var response;
    String tempid = this.id.substring(1);
    if (this.id[0] == "e") {
      response = await http.patch(kAPIAddress + '/api/goal/$tempid/',
          headers: {
            'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
          },
          body: body);
    } else {
      response = await http.post(kAPIAddress + '/api/goal/',
          headers: {
            'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
          },
          body: body);
    }
    Map responseBody = jsonDecode(response.body);
    print(responseBody);
    if ((response.statusCode / 100).floor() != 2) {
      throw ServerErrorException;
    }
    Goal _newGoal = Goal()
      ..achieved = responseBody['achieved']
      ..setOnDate = responseBody['set_on_date']
      ..deadlineDate = responseBody['deadline']
      ..id = responseBody['id'].toString()
      ..content = responseBody['content']
      ..goalType = responseBody['goal_type'];
    if (response.statusCode == 201) {
      _userRepository.diaryItemsToSend.remove(this);
      DBHelper.deleteGoal([this]);
      DBHelper.updateGoalsList([_newGoal]);
    } else if (response.statusCode == 200) {
      _userRepository.diaryItemsToSend.remove(this);
      DBHelper.deleteGoal([this]);
      //DBHelper.updateGoalsList([_newGoal]);
    }

    print("now");
    for (Goal g in await DBHelper.getShortTermGoals()) {
      print("after");
      print(g.id);
    }
    return _newGoal;
  }

  Future<DiaryModel> uploadGoal(UserRepository _userRepository) async {
    //create newGoal instance
    Goal _newGoal = Goal(
        content: content,
        deadlineDate: deadlineDate,
        setOnDate: setOnDate,
        goalType: goalType,
        achieved: achieved);
    //assign prefix to id if necessary
    if (this.id == null) {
      this.id = 'x${DateTime.now().millisecondsSinceEpoch}';
      DBHelper.updateGoalsList([this]);
    }
    if (this.id != null) {
      if (this.id[0] != 'e' && this.id[0] != 'x') {
        DBHelper.deleteGoal([this]);
        this.id = 'e' + this.id;
        DBHelper.updateGoalsList([this]);
      }
    }
    print('HERE');
    print(this.id);
    //add to diaryitemstosend list
    _newGoal.id = this.id;
    _userRepository.diaryItemsToSend.add(this);

    //check for internet and call upload if true
    if (await hasInternetConnection()) {
      _newGoal = await upload(_userRepository);
    }

    return _newGoal;
  }

  Future<String> delete(UserRepository _userRepository) async {
    //sort out id prefix
    String tempid = "";
    if (this.id[0] == 'd') {
      tempid = this.id.substring(1);
    } else {
      tempid = this.id;
    }

    //delete from server
    var response = await http.delete(kAPIAddress + '/api/goal/$tempid/',
        headers: {
          'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
        });
    //if status code correct, delete from toDelete list
    if (response.statusCode == 204) {
      _userRepository.diaryItemsToDelete.remove(this);
    }
    List<Goal> gl = [];
    int found = 0;
    gl = await getGoals(await _userRepository.refreshIdToken(), "S");
    for (Goal g in await DBHelper.getShortTermGoals()) {
      found = 0;
      for (Goal a in gl) {
        if (a == g) {
          found = 1;
        }
      }
      if (found == 0) {
        DBHelper.deleteGoal([g]);
      }
    }
    gl = await getGoals(await _userRepository.refreshIdToken(), "M");
    for (Goal g in await DBHelper.getMediumTermGoals()) {
      found = 0;
      for (Goal a in gl) {
        if (a == g) {
          found = 1;
        }
      }
      if (found == 0) {
        DBHelper.deleteGoal([g]);
      }
    }

    gl = await getGoals(await _userRepository.refreshIdToken(), "L");
    for (Goal g in await DBHelper.getLongTermGoals()) {
      found = 0;
      for (Goal a in gl) {
        if (a == g) {
          found = 1;
        }
      }
      if (found == 0) {
        DBHelper.deleteGoal([g]);
      }
    }
  }

  Future<String> deleteGoal(UserRepository _userRepository) async {
    //remove from db
    DBHelper.deleteGoal([this]);

    //add d to id
    if (this.id[0] != 'd') {
      this.id = 'd' + this.id;
    }
    //add to todelete list
    _userRepository.diaryItemsToDelete.add(this);

    //call delete
    if (await hasInternetConnection()) {
      delete(_userRepository);
    }
  }
}

Future<List<Goal>> getGoals(String jwt, String type) async {
  var response = await http.get(kAPIAddress + '/api/goal/',
      headers: {'Authorization': 'JWT ' + jwt});
  assert(response.statusCode == 200);
  List body = jsonDecode(response.body);
  List<Goal> goals = [];
  for (var goal in body) {
    Goal _newGoal = Goal()
      ..achieved = goal['achieved']
      ..setOnDate = goal['set_on_date']
      ..deadlineDate = goal['deadline']
      ..id = goal['id'].toString()
      ..content = goal['content']
      ..goalType = goal['goal_type'];
    if (_newGoal.goalType[0] == type[0]) {
      goals.add(_newGoal);
    }
  }
  return goals;
}

class Objective extends DiaryModel {
  DateTime startDate;
  DateTime endDate;
  String isFinished;
  String objectiveType;
  int average = 0;
  int hoursOfWork = 0;
  String id;

  Objective(
      {this.startDate,
      this.endDate,
      this.isFinished = 'false',
      this.objectiveType,
      this.hoursOfWork = 1,
      this.average = 5});

  Future<DiaryModel> upload(UserRepository _userRepository) async {
    Map body = {};
    if (this.startDate != null) body['start_date'] = this.startDate.toString();
    if (this.isFinished != null) body['is_finished'] = this.isFinished;
    if (this.endDate != null) body['end_date'] = this.endDate.toString();
    if (this.objectiveType != null)
      body['objective_type'] = this.objectiveType.toString();
    if (this.hoursOfWork != null)
      body['hours_of_work'] = this.hoursOfWork.toString();
    if (this.average != null) body['average'] = this.average.toString();
    if (this.startDate != null)
      body['start_date'] = this.startDate.toString().substring(0, 10);
    if (this.endDate != null)
      body['end_date'] = this.endDate.toString().substring(0, 10);

    var response;
    String tempid = this.id.substring(1);
    if (this.id[0] == "e") {
      response = await http.patch(kAPIAddress + '/api/objective/$tempid/',
          headers: {
            'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
          },
          body: body);
    } else {
      response = await http.post(kAPIAddress + '/api/objective/',
          headers: {
            'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
          },
          body: body);
    }
    Map responseBody = jsonDecode(response.body);
    print(responseBody);
    if ((response.statusCode / 100).floor() != 2) {
      throw ServerErrorException;
    }

    Objective _newObjective = Objective()
      ..startDate = DateTime.parse(responseBody['start_date'])
      ..endDate = DateTime.parse(responseBody['end_date'])
      ..isFinished = responseBody['is_finished']
      ..objectiveType = responseBody['objective_type']
      ..hoursOfWork = responseBody['hours_of_work']
      ..average = responseBody['average']
      ..id = responseBody['id'].toString();
    if (response.statusCode == 201) {
      _userRepository.diaryItemsToSend.remove(this);
      DBHelper.deleteObjective([this]);
      this.id = _newObjective.id;
      DBHelper.updateObjectives([this]);
    } else if (response.statusCode == 200) {
      _userRepository.diaryItemsToSend.remove(this);
      DBHelper.deleteObjective([this]);
      this.id = _newObjective.id;
      DBHelper.updateObjectives([this]);
    }
    return this;
  }

  Future<Objective> uploadObjective(UserRepository _userRepository) async {
    Objective _newObjective = Objective(
      startDate: startDate,
      endDate: endDate,
      isFinished: isFinished,
      objectiveType: objectiveType,
      average: average,
      hoursOfWork: hoursOfWork,
    );

    //assign prefix to id
    if (this.id == null) {
      this.id = 'x${DateTime.now().millisecondsSinceEpoch}';
      DBHelper.updateObjectives([this]);
    }
    if (this.id != null) {
      if (this.id[0] != 'e' && this.id[0] != 'x') {
        DBHelper.deleteObjective([this]);
        this.id = 'e' + this.id;
        DBHelper.updateObjectives([this]);
      }
    }
    //add to diaryitemstosend list
    _newObjective.id = this.id;
    _userRepository.diaryItemsToSend.add(this);

    //check for internet and call upload if true
    if (await hasInternetConnection()) {
      _newObjective = await upload(_userRepository);
    }

    return _newObjective;
  }

  Future<String> delete(UserRepository _userRepository) async {
    //sort out id prefix
    String tempid = "";
    if (this.id[0] == 'd') {
      tempid = this.id.substring(1);
    } else {
      tempid = this.id;
    }

    //delete from server
    var response = await http.delete(kAPIAddress + '/api/objective/$tempid/',
        headers: {
          'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
        });
    //if status code correct, delete from db and toDelete list
    if (response.statusCode == 204) {
      DBHelper.deleteObjective([this]);
      _userRepository.diaryItemsToDelete.remove(this);
    }
  }

  Future<String> deleteObjective(UserRepository _userRepository) async {
    //remove from db
    DBHelper.deleteObjective([this]);
    print(this.id);
    //add d to id
    if (this.id[0] != 'd') {
      this.id = 'd' + this.id;
    }
    //add to todelete list
    _userRepository.diaryItemsToDelete.add(this);

    //call delete
    if (await hasInternetConnection()) {
      delete(_userRepository);
    }
  }

  void addToQueue(UserRepository _userRepository) {
    _userRepository.diaryItemsToSend.add(this);
  }
}

Future<Objective> getObjective(String jwt, String type) async {
  var response = await http.get(kAPIAddress + '/api/objective/',
      headers: {'Authorization': 'JWT ' + jwt});
  List body = jsonDecode(response.body);
  List<Objective> objectives = [];
  for (var day in body) {
    Objective objective = Objective()
      ..startDate = DateTime.parse(day['start_date'])
      ..endDate = DateTime.parse(day['end_date'])
      ..isFinished = day['is_finished']
      ..objectiveType = day['objective_type']
      ..average = day['average']
      ..hoursOfWork = day['hours_of_work']
      ..id = day['id'].toString();
    if (objective.objectiveType == type) {
      objectives.add(objective);
    }
  }
  if (objectives.length > 0) {
    return objectives.last;
  } else {
    return null;
  }
}
