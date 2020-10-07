import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:e_athlete_web/models/user_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import 'package:meta/meta.dart';

import '../../misc/database.dart';
import '../../misc/user_repository.dart';

part 'profile_edit_event.dart';

part 'profile_edit_state.dart';

class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  User updatedUser;
  UserRepository _userRepository;

  /// constructor copies over info from main user class to temporary user class to be used while updating user
  ProfileEditBloc(this._userRepository);

  @override
  ProfileEditState get initialState {
    updatedUser = User()
      ..firstName = _userRepository.user.firstName
      ..lastName = _userRepository.user.lastName
      ..sex = _userRepository.user.sex
      ..dOB = _userRepository.user.dOB
      ..profilePhoto = _userRepository.user.profilePhoto
      ..height = _userRepository.user.height
      ..weight = _userRepository.user.weight
      ..sport = _userRepository.user.sport
      ..shortTermGoal = _userRepository.user.shortTermGoal
      ..mediumTermGoal = _userRepository.user.mediumTermGoal
      ..longTermGoal = _userRepository.user.longTermGoal
      ..jwt = _userRepository.user.jwt;
    return InitialProfileEditState(updatedUser);
  }

  @override
  Stream<ProfileEditState> mapEventToState(ProfileEditEvent event) async* {
    if (event is UpdateFirstName) {
      updatedUser.firstName = event.firstName;
      print(updatedUser.firstName);
      yield InitialProfileEditState(updatedUser);
    } else if (event is UpdateLastName) {
      updatedUser.lastName = event.lastName;
      yield InitialProfileEditState(updatedUser);
    } else if (event is UpdateSex) {
      updatedUser.sex = event.sex;
      print(updatedUser.sex);
      yield InitialProfileEditState(updatedUser);
    } else if (event is UpdateWeight) {
      updatedUser.weight = event.weight;
      yield InitialProfileEditState(updatedUser);
    } else if (event is UpdateHeight) {
      updatedUser.height = event.height;
      print(updatedUser.height);
      yield InitialProfileEditState(updatedUser);
    } else if (event is UpdateSport) {
      updatedUser.sport = event.sport;
      yield InitialProfileEditState(updatedUser);
    } else if (event is UpdateShortTermGoal) {
      updatedUser.shortTermGoal = event.shortTermGoal;
      yield InitialProfileEditState(updatedUser);
    } else if (event is UpdateMediumTermGoal) {
      updatedUser.mediumTermGoal = event.mediumTermGoal;
      yield InitialProfileEditState(updatedUser);
    } else if (event is UpdateLongTermGoal) {
      updatedUser.longTermGoal = event.longTermGoal;
      yield InitialProfileEditState(updatedUser);
    } else if (event is UpdateDOB) {
      updatedUser.dOB = event.dOB;
      yield InitialProfileEditState(updatedUser);
    } else if (event is UpdateTempImage) {
      updatedUser.tempImage = event.tempImage;
    } else if (event is UpdateProfilePhotoToSend) {
      updatedUser.profilePhotoToSend = event.profilePhoto;
      updatedUser.newPhoto = event.profilePhotoFile;
      yield InitialProfileEditState(updatedUser);
    } else if (event is SubmitForm) {
      yield IsSubmitting(updatedUser);
      try {
        await updatedUser
            .updateUserInfo(await _userRepository.refreshIdToken());
        await _userRepository.user
            .getUserInfo(await _userRepository.refreshIdToken());
        DBHelper.updateUser(_userRepository.user);
        yield SubmittedSuccessfully(updatedUser);
      } catch (e) {
        print(e);
        yield SubmittedUnsuccessfully(updatedUser);
      }
    }
  }
}
