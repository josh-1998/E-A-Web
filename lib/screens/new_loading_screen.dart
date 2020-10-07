import 'package:flutter/material.dart';

class NewLoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "lib/images/51012169_padded_logo.png",
                scale: 2,
              ),
              SizedBox(
                height: 10,
              ),
              CircularProgressIndicator()
            ],
          ),
        ),
      ),
    );
  }
}
