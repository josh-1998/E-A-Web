import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:e_athlete_web/misc/user_repository.dart';
import 'package:e_athlete_web/models/diary_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_athlete_web/misc/useful_functions.dart';

class NetworkHandler extends StatefulWidget {
  final Widget child;
  NetworkHandler({Key key, this.child}) : super(key: key);

  @override
  _NetworkHandlerState createState() => _NetworkHandlerState();
}

class _NetworkHandlerState extends State<NetworkHandler> {
  StreamSubscription connectivityListener;
  @override
  void initState() {
    super.initState();
    connectivityListener = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.wifi) {
        if (await hasInternetConnection()) {
          processDiaryItems(
              Provider.of<UserRepository>(context, listen: false));
        }
        Provider.of<UserRepository>(context, listen: false).diaryItemsToSend =
            [];
        Provider.of<UserRepository>(context, listen: false).diaryItemsToDelete =
            [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    super.dispose();
    connectivityListener.cancel();
  }
}
