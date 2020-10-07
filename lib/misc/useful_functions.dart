import 'package:e_athlete_web/misc/user_repository.dart';
import 'package:e_athlete_web/models/diary_model.dart';
import 'package:connectivity/connectivity.dart';

///adds a 0 in front of any number less than 10
String timeToString(int time) {
  if (time > 9) {
    return '$time';
  } else {
    return '0$time';
  }
}

///converts total milliseconds into a human readable time
String formatTime(int timeInMilliSeconds) {
  int _totalSeconds = timeInMilliSeconds ~/ 1000;
  int _elapsedCentiseconds = (timeInMilliSeconds % 1000) ~/ 10;
  int _elapsedSeconds = _totalSeconds % 60;
  int totalMinutes = _totalSeconds ~/ 60;
  int _elapsedMinutes = totalMinutes % 60;
  int _elapsedHours = totalMinutes ~/ 60;
  return '${timeToString(_elapsedHours)}:${timeToString(_elapsedMinutes)}:${timeToString(_elapsedSeconds)}:${timeToString(_elapsedCentiseconds)}';
}

///converts numbers 1-12 to month
Map numberToMonth = {
  1: 'Jan',
  2: 'Feb',
  3: 'Mar',
  4: 'Apr',
  5: 'May',
  6: 'Jun',
  7: 'Jul',
  8: 'Aug',
  9: 'Sep',
  10: 'Oct',
  11: 'Nov',
  12: 'Dec'
};

///returns current day at midnight in a DateTime
DateTime currentDay =
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

/// checks for internet connection, returns true if connected
Future<bool> hasInternetConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else {
    return false;
  }
  // try {
  //   final result = await InternetAddress.lookup('example.com');
  //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //     return true;
  //   }
  // } on SocketException catch (_) {
  //   return false;
  // }
}

///sends out items in the queue. need to make sure that all items send correctly
void processDiaryItems(UserRepository _userRepository) async {
  if (_userRepository.diaryItemsToSend.length > 0) {
    int successfulPointer = 0;
    for (DiaryModel item in _userRepository.diaryItemsToSend) {
      await item.upload(_userRepository);
      successfulPointer += 1;

      //need to make sure that the items are sent off correctly, and then
      //remove them from the list
    }
    _userRepository.diaryItemsToSend.removeRange(0, successfulPointer - 1);
  }
  if (_userRepository.diaryItemsToDelete.length > 0) {
    int successfulPointer = 0;
    for (DiaryModel item in _userRepository.diaryItemsToDelete) {
      await item.delete(_userRepository);
      successfulPointer += 1;

      //need to make sure that the items are sent off correctly, and then
      //remove them from the list
    }
    _userRepository.diaryItemsToDelete.removeRange(0, successfulPointer - 1);
  }
}
