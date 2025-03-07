import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecoeden/models/user.dart';
import 'package:ecoeden/services/webservice.dart';

import '../main.dart';

class LeaderBoard extends StatefulWidget {
  static String nextPage = 'https://api.ecoeden.xyz/leaderboard/';
  List<User> _army = List<User>();
  @override
  _LeaderBoardState createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  @override
  void initState() {
    super.initState();
    LeaderBoard.nextPage = 'https://api.ecoeden.xyz/leaderboard/';
    _fetcher();
  }

  void _fetcher() async {
    await _fetch();
  }

  Future<void> _getLeaders() async {
    List<User> army = await Webservice().load(User.leader);
    setState(() {
      widget._army.addAll(army);
    });
  }

  Future<void> _fetch() async {
    await _getLeaders();
    var val = widget._army.map((x) => x.id).toList();
    print("It's Show Time !!!");
    print(val);
  }

  String _getName(String x) {
    if(x.length < 15 ) return x;
    else return x.substring(0, 15) + "...";
  }

  Color renderColors(int arg) {
    switch (arg) {
      case 1:
        return Color(0xffFDDE69);
      case 2:
        return Color(0xffDFE3E6);
      case 3:
        return Color(0xffEDC194);
      default:
        return Colors.grey[200];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        Positioned(
            child: Image.asset(
              'assets/wave.png',
              fit: BoxFit.fitWidth,
            )),
        getLeaderBoard(context),
      ]),
    );
  }


  Widget getLeaderBoard(BuildContext context) {
    return Column(
//        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 25, 0, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back, size: 28, color: Colors.white,),

                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 0, 10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Leaderboard',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 48.0,
                      fontFamily: "SegoeUI",
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                )),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0.0, 30.0, 4.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset('assets/EcoEden-Logo-withoutText.png'),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: widget._army.length,
                itemBuilder: (BuildContext context, int index) {
                  return widget._army[index].userName != "anonymous" ? Padding(
                    padding:
                    EdgeInsets.fromLTRB(16, 10, 16, 2),
                    child: Container(
                      decoration: BoxDecoration(
                          color: renderColors(index + 1),
                          borderRadius: BorderRadius.all(
                              Radius.circular(6.0))),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 10.0),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              " " * 2 +
                                  (index+1).toString().padLeft(2, '0') + " " * 3,
                              style:
                              TextStyle(fontSize: 24.0, fontFamily: "SegoeUI", fontWeight: FontWeight.w300),
                            ),
                            CircleAvatar(
                              radius: 26.0,
                              backgroundColor: Colors.lightBlueAccent,
                              child: Text(
                                (widget._army[index].firstName)[0].toString(),
                                style: TextStyle(fontSize: 21.0),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                  " " * 3 + _getName(widget._army[index].firstName + " " + widget._army[index].lastName),
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontFamily:
                                      "Segoe UI")),
                              flex: 6,
                            ),
                            Expanded(
                              child: Text(
                                widget._army[index]
                                    .score
                                    .toString(),
                                style: TextStyle(
                                    fontFamily: "SegoeUI",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24.0),
                              ),
                              flex: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ): Container();
                }
            ),
          )
        ]);
  }

}