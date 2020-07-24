import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecoeden/app_routes.dart';
import 'package:ecoeden/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ecoeden/redux/actions.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Post extends StatefulWidget {
  bool disliked = false;
  bool trashed = false;
  bool showHeartOverlay = false;
  final String description;
  final String imageUrl;
  final String lat;
  final String lng;
  final int id;
  final Map<String, dynamic> user;
  final List<dynamic> activity;
  int upvotes;
  int downvotes;
  Post(
      {this.activity,
      this.id,
      this.showHeartOverlay,
      this.lat,
      this.lng,
      this.upvotes,
      this.downvotes,
      this.description,
      this.imageUrl,
      this.user});

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  // ignore: non_constant_identifier_names
  static String base_url = 'https://api.ecoeden.xyz/activity/';
  Position pos;
  bool render = false;
  bool showRow = false;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    set_function();
  }

  // ignore: non_constant_identifier_names
  void set_function() async {
    if (widget.activity.length == 0 || widget.activity[0]['vote'] == 0) {
      setState(() {
        widget.disliked = false;
        widget.trashed = false;
      });
    } else if (widget.activity[0]['vote'] > 0) {
      setState(() {
        widget.disliked = false;
        widget.trashed = true;
      });
    } else {
      setState(() {
        widget.disliked = true;
        widget.trashed = false;
      });
    }
    bool temp = await setWidget(double.parse(widget.lat), double.parse(widget.lng));
    setState(() {
      render = temp;
    });
  }

  // ignore: non_constant_identifier_names
  void vote_function() async {
    print("inside vote");
    var json = new Map<String, dynamic>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt = prefs.getString('user');
    if (widget.disliked == false && widget.trashed == false)
      json['vote'] = "0";
    else if (widget.disliked == false && widget.trashed == true)
      json['vote'] = "1";
    else if (widget.disliked == true && widget.trashed == false)
      json['vote'] = "-1";
//    String json = '{"upvotes": "${widget.upvotes}","downvotes":"${widget.downvotes}"}';
    if (widget.activity.length != 0) {
      String url = base_url + widget.activity[0]['id'].toString() + "/";
      var response = await http.patch(url,
          headers: {HttpHeaders.authorizationHeader: "Token " + jwt},
          body: json);
      print(response.body.toString());
      if (response.statusCode == 200) print("Patch successful");
    } else {
      json['user'] = "http://api.ecoeden.xyz/users/" +
          global_store.state.user.id.toString() +
          "/";
      json['photo'] =
          "http://api.ecoeden.xyz/photos/" + widget.id.toString() + "/";
      var response = await http.post(base_url,
          headers: {HttpHeaders.authorizationHeader: "Token " + jwt},
          body: json);
      print(response.body.toString());
      if (response.statusCode == 200) print("Post successful");
    }
    set_function();
  }

  void collect() async {
    var json = new Map<String, dynamic>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt = prefs.getString('user');
    json['collector'] = "http://api.ecoeden.xyz/users/" +
        global_store.state.user.id.toString() + "/";
    json['photo'] =
        "http://api.ecoeden.xyz/photos/" + widget.id.toString() + "/";
    var response = await http.post('https://api.ecoeden.xyz/trash_collection/',
        headers: {HttpHeaders.authorizationHeader: "Token " + jwt},
        body: json);
    print(response.statusCode);
    if(response.statusCode == 400) {
      setState(() {
        showRow = true;
      });
    }
  }

  Color getColor() {
    if (widget.upvotes < 5) {
      return Colors.grey;
    } else {
      return Colors.red;
    }
  }

  Future<bool> setWidget(double lat, double long) async {
    res = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double lat2 = res.latitude;
    double long2 = res.longitude;
    print("Latitude : " + lat2.toString());
    print("Longitude : " + long2.toString());
    if((lat - lat2).abs() <= 1.0 && (long - long2).abs() <= 1.0) return true;
    return false;
  }

  Widget getCollect(BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(14.0, 0.0, 8.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width / 2.5,
              decoration: BoxDecoration(
                  color: Colors.yellow[400],
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 8.0),
                child: Text(
                  "Collected",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              )),
          Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: Text(
                  " ${widget.upvotes}",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                ),
              ),
              IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 0.0),
                  iconSize: widget.trashed ? 25.0 : 20.0,
                  icon: Icon(
                      widget.trashed
                          ? FontAwesomeIcons.solidArrowAltCircleUp
                          : FontAwesomeIcons.arrowUp,
                      color: widget.trashed ? Colors.green : Colors.grey),
                  onPressed: () {
                    setState(() {
                      widget.upvotes = widget.trashed
                          ? widget.upvotes - 1
                          : widget.upvotes + 1;
                      widget.downvotes = widget.disliked
                          ? widget.downvotes - 1
                          : widget.downvotes;
                      widget.trashed = !widget.trashed;
                      widget.disliked =
                          widget.disliked ? !widget.disliked : false;
                      vote_function();
                    });
                  }),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: Text(
                  " ${widget.downvotes}",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                ),
              ),
              IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 0.0),
                  iconSize: widget.trashed ? 25.0 : 20.0,
                  icon: Icon(
                      widget.disliked
                          ? FontAwesomeIcons.solidArrowAltCircleDown
                          : FontAwesomeIcons.arrowDown,
                      color: widget.disliked ? Colors.red : Colors.grey),
                  onPressed: () {
                    setState(() {
                      widget.downvotes = widget.disliked
                          ? widget.downvotes - 1
                          : widget.downvotes + 1;
                      widget.upvotes =
                          widget.trashed ? widget.upvotes - 1 : widget.upvotes;
                      widget.disliked = !widget.disliked;
                      widget.trashed = widget.trashed ? !widget.trashed : false;
                      vote_function();
                    });
                  }),
            ],
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    //print(widget.upvotes.runtimeType);
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 6, 7, 6),
      child: Card(
          color: Colors.lightGreenAccent[100],
          shadowColor: Colors.grey,
          elevation: 20.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              PostHeader(widget.user),
              Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 0.0, 8.0, 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width / 1.6,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              widget.description,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )),
                    CircleAvatar(
                      backgroundColor: getColor(),
                      child: Icon(
                        FontAwesomeIcons.trashAlt,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    widget.upvotes =
                        widget.trashed ? widget.upvotes : widget.upvotes + 1;
                    widget.downvotes = widget.disliked
                        ? widget.downvotes - 1
                        : widget.downvotes;
                    widget.trashed = true;
                    widget.disliked =
                        widget.disliked ? !widget.disliked : false;
                    widget.showHeartOverlay = true;
                    if (widget.showHeartOverlay) {
                      Timer(const Duration(milliseconds: 180), () {
                        setState(() {
                          widget.showHeartOverlay = false;
                        });
                      });
                    }
                    vote_function();
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    //Image.asset('assets/profile.jpg'),
                    widget.imageUrl == null
                        ? Image.asset('assets/profile.jpg')
                        : CachedNetworkImage(imageUrl: widget.imageUrl),
                    widget.showHeartOverlay
                        ? Icon(
                            FontAwesomeIcons.solidTrashAlt,
                            color: Colors.white54,
                            size: 80.0,
                          )
                        : Container(),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
//                ListTile(
//                  contentPadding: EdgeInsets.symmetric(horizontal: 5.0 , vertical: 2.0),
//                  leading: Wrap(
//                    spacing: 6.0,
//                    children: <Widget>[
//                      Text(" ${widget.upvotes} upvotes",style: TextStyle(fontWeight: FontWeight.w400),),
//                      Text(" ${widget.downvotes} downvotes",style: TextStyle(fontWeight: FontWeight.w400),),
//                    ],
//                  ),
//                ),
                  SizedBox(
                    height: 0.0,
                    child: Divider(
                      color: Color(0xff4E4F50),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14.0, 0.0, 8.0, 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Wrap(
                            //mainAxisSize: MainAxisSize.min,
                            spacing: 1.0,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                                child: Text(
                                  " ${widget.upvotes}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400, fontSize: 18),
                                ),
                              ),
                              IconButton(
                                  iconSize: 25.0,
                                  icon: Icon(
                                      widget.trashed
                                          ? FontAwesomeIcons.solidThumbsUp
                                          : FontAwesomeIcons.thumbsUp,
                                      color: widget.trashed
                                          ? Colors.green
                                          : Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      widget.upvotes = widget.trashed
                                          ? widget.upvotes - 1
                                          : widget.upvotes + 1;
                                      widget.downvotes = widget.disliked
                                          ? widget.downvotes - 1
                                          : widget.downvotes;
                                      widget.trashed = !widget.trashed;
                                      widget.disliked = widget.disliked
                                          ? !widget.disliked
                                          : false;
                                      vote_function();
                                    });
                                  }),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                                child: Text(
                                  " ${widget.downvotes}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400, fontSize: 18),
                                ),
                              ),
                              IconButton(
                                  iconSize: 25.0,
                                  icon: Icon(
                                      widget.disliked
                                          ? FontAwesomeIcons.solidThumbsDown
                                          : FontAwesomeIcons.thumbsDown,
                                      color: widget.disliked
                                          ? Colors.red
                                          : Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      widget.downvotes = widget.disliked
                                          ? widget.downvotes - 1
                                          : widget.downvotes + 1;
                                      widget.upvotes = widget.trashed
                                          ? widget.upvotes - 1
                                          : widget.upvotes;
                                      widget.disliked = !widget.disliked;
                                      widget.trashed =
                                          widget.trashed ? !widget.trashed : false;
                                      vote_function();
                                    });
                                  }),
                            ],
                          ),
                          GestureDetector(
                            child: render ? Image.asset("assets/splash.jpg", height: 60, width: 120) : Image.asset("assets/maps.png", height: 60, width: 120),
                            onTap: () async {
                              if(render) {
                                await collect();
                                print("Tapped");
                                print(showRow);
                              }
                              else {
                                global_store.dispatch(new LatAction(widget.lat));
                                global_store.dispatch(new LngAction(widget.lng));
                                global_store.dispatch(new NavigatePushAction(AppRoutes.map));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  showRow ? getCollect(context) : Container(),
                ],
              )
            ],
          )),
    );
  }
}

class PostHeader extends StatelessWidget {
  final Map<String, dynamic> user;

  PostHeader(this.user);

  String _sendData() {
    if (user['first_name'] != "") {
      String str = user['first_name'].substring(0, 1);
      print("Yo : " + str);
      return str;
    } else {
      return "Bakaaaa";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          //CircleImage(),
          Container(
            height: 45.0,
            width: 45.0,
            child: CircleAvatar(
              backgroundColor: Colors.lightBlueAccent,
              child: Text(
                _sendData(),
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 15.0),
            child: Text(
              user['first_name'].toString() +
                  " " +
                  user['last_name'].toString(),
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45.0,
      height: 45.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage('assets/profile.jpg'),
          )),
    );
  }
}
