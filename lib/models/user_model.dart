import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../misc/constants.dart';
import '../misc/exceptions.dart';

class User {
  String firstName;
  String lastName;
  String dOB; //this one will need looking at
  String profilePhoto;
  String sex;
  int height;
  int weight;
  String profilePhotoToSend;
  File newPhoto;
  ImageProvider tempImage;
  String sport;
  String shortTermGoal;
  String mediumTermGoal;
  String longTermGoal;
  String lastLogin;
  String dateJoined;
  String jwt;
  get age {
    var years = (DateTime.now().difference(DateTime.parse(dOB)).inDays) / 365;
    return years.floor();
  }

  set profilePhotos(var photoString) {
    profilePhoto = photoString;
    tempImage = NetworkImage(photoString);
  }

//  get heightInFeet {}
//  get weightInPounds {}

  User(
      {this.firstName,
      this.lastName,
      this.dOB,
      this.profilePhoto,
      this.sex,
      this.height,
      this.weight,
      this.sport,
      this.shortTermGoal,
      this.mediumTermGoal,
      this.longTermGoal});

  Future<void> getUserInfo(String jwt) async {
    print(jwt);
    var response = await http.get(
      kAPIAddress + '/api/users/current/',
      headers: {'Authorization': 'JWT ' + jwt},
    );
    print(response.body);
    if (response.statusCode == 200) {
      Map body = json.decode(response.body);
      this.firstName = body['first_name'] != null ? body['first_name'] : null;
      this.lastName = body['last_name'] != null ? body['last_name'] : null;
      this.dOB = body['date_of_birth'] != null ? body['date_of_birth'] : null;
      this.profilePhoto =
          body['profile_photo'] != null ? body['profile_photo'] : null;
      this.sex = body['sex'] != null ? body['sex'] : null;
      this.height = body['height'] != null ? body['height'] : null;
      this.weight = body['weight'] != null ? body['weight'] : null;
      this.sport = body['sport'] != null ? body['sport'] : null;
      this.shortTermGoal =
          body['short_term_goal'] != null ? body['short_term_goal'] : null;
      this.mediumTermGoal =
          body['medium_term_goal'] != null ? body['medium_term_goal'] : null;
      this.longTermGoal =
          body['long_term_goal'] != null ? body['long_term_goal'] : null;
      this.lastLogin = body['last_login'] != null ? body['last_login'] : null;
      this.dateJoined =
          body['date_joined'] != null ? body['date_joined'] : null;
    } else {
      throw ServerErrorException('Status code ${response.statusCode}');
    }
  }

  Future<void> updateUserInfo(String jwt) async {
    Map body = {};
    if (this.firstName != null) body['first_name'] = this.firstName;
    if (this.lastName != null) body['last_name'] = this.lastName;
    if (this.dOB != null) body['date_of_birth'] = this.dOB;
    if (this.sex != null) body['sex'] = this.sex;
    if (this.height != null) body['height'] = this.height.toString();
    if (this.weight != null) body['weight'] = this.weight.toString();
    if (this.sport != null) body['sport'] = this.sport;
    if (this.shortTermGoal != null)
      body['short_term_goal'] = this.shortTermGoal;
    if (this.mediumTermGoal != null)
      body['medium_term_goal'] = this.mediumTermGoal;
    if (this.longTermGoal != null) body['long_term_goal'] = this.longTermGoal;
    if (this.profilePhotoToSend != null)
      body['profile_photo'] = this.profilePhotoToSend;

    var response = await http.patch(kAPIAddress + '/api/users/current/',
        headers: {'Authorization': 'JWT ' + jwt}, body: body);
//    Map body = json.decode(response.body);
    if (response.statusCode != 200) {
      throw ServerErrorException;
    }
  }

  Future<void> deleteUser(String jwt) async {
    var response = await http.delete(
      kAPIAddress + '/api/users/current/',
      headers: {'Authorization': 'JWT ' + jwt},
    );
    print(await response.body);
  }
}
