import 'dart:html';

import 'package:flutter/material.dart';
import 'teams_screen.dart' as tp;

class MyHomePage extends StatefulWidget {
  int pageNumber;
  static const String id = 'HomePageApp';
  MyHomePage({Key key, this.pageNumber = 0}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  String searchTerm = "";
  int _value = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset("lib/images/51012169_padded_logo.png",
                fit: BoxFit.contain, height: 30),
            SizedBox(width: 5),
            Text("E-Coach"),
            SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(4),
                //border: Border.all(color: Colors.lightBlue),
                color: Colors.grey[100],
              ),
              child: Row(
                children: [
                  Container(
                    width: 300,
                    child: TextField(
                      controller: myController,
                      decoration: const InputDecoration(
                        hintText: '   Search',
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: Colors.black54),
                      ),
                      style:
                          const TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  ),
                  IconButton(
                    hoverColor: Colors.white,
                    highlightColor: Colors.white,
                    focusColor: Colors.white,
                    disabledColor: Colors.white,
                    splashColor: Colors.white,
                    icon: Icon(Icons.search),
                    onPressed: () {
                      searchTerm = myController.text;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Row(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            children: <Widget>[
              SizedBox(height: 40),
              SideLayout(),
              SizedBox(height: 40),
            ],
          ),
        ),
        SizedBox(width: 40),
        Align(
            alignment: Alignment.topLeft,
            child: Column(children: [
              SizedBox(height: 40),
              Attendance(),
            ])),
        SizedBox(width: 40),
        Align(
            alignment: Alignment.topLeft,
            child: Column(children: [
              SizedBox(height: 40),
              Achievers(),
            ])),
      ]),
    );
  }
}

class Attendance extends StatelessWidget {
  const Attendance({Key key}) : super(key: key);
  final int _value = 1;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      height: 400,
      width: 350,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Attendance"),
              DropdownButton(
                value: _value,
                items: [
                  DropdownMenuItem(
                    child: Text("Daily"),
                    value: 1,
                  ),
                  DropdownMenuItem(
                    child: Text("Weekly"),
                    value: 2,
                  ),
                  DropdownMenuItem(
                    child: Text("Monthly"),
                    value: 3,
                  ),
                ],
                onChanged: (value) {
                  //TODO: add value changing functionality
                },
              )
            ],
          ),
          //TODO: Graph Data
        ],
      ),
    );
  }
}

class Achievers extends StatelessWidget {
  const Achievers({Key key}) : super(key: key);
  final int _value = 1;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      height: 400,
      width: 350,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Top Achievers"),
              DropdownButton(
                value: _value,
                items: [
                  DropdownMenuItem(
                    child: Text("Daily"),
                    value: 1,
                  ),
                  DropdownMenuItem(
                    child: Text("Weekly"),
                    value: 2,
                  ),
                  DropdownMenuItem(
                    child: Text("Monthly"),
                    value: 3,
                  ),
                ],
                onChanged: (value) {
                  //TODO: add value changing functionality
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class SideLayout extends StatelessWidget {
  const SideLayout({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image(
                  image: AssetImage('lib/images/anon-profile-picture.png'),
                  height: 100,
                  width: 100,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Name Of User',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'Role Of User',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 40),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  color: Colors.grey[100],
                  onPressed: () {},
                  //TODO: add overview logo
                  child: Text("Overview",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => tp.MyTeams()),
                    );
                  },

                  //TODO: add MyTeams logo
                  child: Text("My Teams",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  },
                  //TODO: add My Athletes logo
                  child: Text("My Athletes",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    /*...*/
                  },
                  //TODO: add Sessions logo
                  child: Text("Sessions",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    /*...*/
                  },
                  //TODO: add Calendar logo
                  child: Text("Calendar",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    /*...*/
                  },
                  //TODO: add Leaderboards logo
                  child: Text("Leaderboards",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    /*...*/
                  },
                  //TODO: add My Account logo
                  child: Text("My Account",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    /*...*/
                  },
                  //TODO: add Logout logo
                  child: Text("Logout",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
