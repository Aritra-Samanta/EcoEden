import 'dart:async';
import 'dart:convert';
import 'package:ecoeden/models/feedsArticle.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecoeden/app_routes.dart';
import 'package:ecoeden/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ecoeden/redux/actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Post extends StatefulWidget {
  bool showHeartOverlay = false;
  final String description;
  final String imageUrl;
  final String lat;
  final String lng;
  final int id;
  final Map<String, dynamic> user;
  HasVoted voted;
  HasVerified verified;
  final bool is_indoors;

  Post(
      {this.id,
      this.showHeartOverlay,
      this.lat,
      this.lng,
      this.description,
      this.imageUrl,
      this.user,
      this.voted,
      this.verified,
      this.is_indoors});

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  // ignore: non_constant_identifier_names
  static String base_url = 'https://api.ecoeden.xyz/activity/';
  static String base_url_trash =
      'https://api.ecoeden.xyz/trash_collection_activity/';

  @override
  void initState() {
    super.initState();
  }

  Future<void> vote_function() async {
    print("inside vote");
    var voteJson = new Map<String, dynamic>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt = prefs.getString('user');
    if (widget.voted.disliked == false && widget.voted.trashed == false)
      voteJson['vote'] = "0";
    else if (widget.voted.disliked == false && widget.voted.trashed == true)
      voteJson['vote'] = "1";
    else if (widget.voted.disliked == true && widget.voted.trashed == false)
      voteJson['vote'] = "-1";
    if (widget.voted.activityId != -1) {
      String url = base_url + widget.voted.activityId.toString() + "/";
      var response = await http.patch(url,
          headers: {HttpHeaders.authorizationHeader: "Token " + jwt},
          body: voteJson);
      if (response.statusCode >= 200 && response.statusCode < 400) {
        print("Patch successful");
      }
    } else {
      voteJson['user'] = "http://api.ecoeden.xyz/users/" +
          global_store.state.user.id.toString() +
          "/";
      voteJson['photo'] =
          "http://api.ecoeden.xyz/photos/" + widget.id.toString() + "/";
      var response = await http.post(base_url,
          headers: {HttpHeaders.authorizationHeader: "Token " + jwt},
          body: voteJson);
      if (response.statusCode >= 200 && response.statusCode < 400) {
        widget.voted.activityId = json.decode(response.body)['id'];
        print("Post successful");
      }
    }
  }

  Future<void> verify_function() async {
    print("inside verify");
    var verifyJson = new Map<String, dynamic>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt = prefs.getString('user');
    if (widget.verified.disliked == false && widget.verified.trashed == false)
      verifyJson['vote'] = "0";
    else if (widget.verified.disliked == false &&
        widget.verified.trashed == true)
      verifyJson['vote'] = "1";
    else if (widget.verified.disliked == true &&
        widget.verified.trashed == false) verifyJson['vote'] = "-1";
    if (widget.verified.activityId != -1) {
      String url = base_url_trash + widget.verified.activityId.toString() + "/";
      var response = await http.patch(url,
          headers: {HttpHeaders.authorizationHeader: "Token " + jwt},
          body: verifyJson);
      if (response.statusCode >= 200 && response.statusCode < 400)
        print("Patch successful in verification");
      else
        print("Fuck Patch");
    } else {
      verifyJson['user'] = "http://api.ecoeden.xyz/users/" +
          global_store.state.user.id.toString() +
          "/";
      verifyJson['trash_collection'] =
          "http://api.ecoeden.xyz/trash_collection/" +
              widget.verified.trashId.toString() +
              "/";
      var response = await http.post(base_url_trash,
          headers: {HttpHeaders.authorizationHeader: "Token " + jwt},
          body: verifyJson);
      print(response.body.toString());
      if (response.statusCode >= 200 && response.statusCode < 400) {
        widget.verified.activityId = json.decode(response.body)['id'];
        print("Post successful in verfication");
      } else
        print("Fuck Post");
    }
  }

  Future<void> collect() async {
    var collectJson = new Map<String, dynamic>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt = prefs.getString('user');
    collectJson['collector'] = "http://api.ecoeden.xyz/users/" +
        global_store.state.user.id.toString() +
        "/";
    collectJson['photo'] =
        "http://api.ecoeden.xyz/photos/" + widget.id.toString() + "/";
    collectJson['visible'] = "true";
    var response = await http.post('https://api.ecoeden.xyz/trash_collection/',
        headers: {HttpHeaders.authorizationHeader: "Token " + jwt},
        body: collectJson);
    widget.verified.trashId = json.decode(response.body)['id'];
    print(response.statusCode);
    if (response.statusCode == 201) {
      setState(() {
        widget.verified.collected = true;
      });
    }
  }

  Color getColor() {
    if (widget.verified.collected == true)
      return Color.fromRGBO(243, 240, 140, 1);
    else if (widget.is_indoors == true)
      return Color.fromRGBO(251, 207, 146, 1);
    else if (ifCollect(double.parse(widget.lat), double.parse(widget.lng)))
      return Color(0xff59b8e8);
    else
      return Color(0xffeb858a);
  }

  Color getIconColor() {
    if (widget.verified.collected == true)
      return Color(0xFFE7BF04);
    else
      return Colors.red;
  }

  bool ifCollect(double lat, double long) {
    double lat2 = res.latitude;
    double long2 = res.longitude;
    print("Latitude : " + lat2.toString());
    print("Longitude : " + long2.toString());
    if ((lat - lat2).abs() <= 0.1 && (long - long2).abs() <= 0.1) return true;
    return false;
  }

  Widget getCollect(BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 2.0, 8.0, 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 43.0,
            width: MediaQuery.of(context).size.width / 2.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 16.0,
                    backgroundColor: Colors.lightBlueAccent,
                    child: Text(
                      _sendData(),
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 12.0),
                  child: Text(
                    "COLLECTED",
                    style: TextStyle(
                        color: Color(0xFFE7C004),
                        fontFamily: "SegoeUI",
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2.45,
            height: 42.0,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Wrap(
              spacing: 1.0,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 6, 0, 0),
                  child: Text(
                    " ${widget.verified.upvotes}",
                    style: TextStyle(fontFamily: "SegoeUI", fontSize: 20),
                  ),
                ),
                IconButton(
                    padding: EdgeInsets.only(left: 10.0, top: 6.0),
                    alignment: Alignment.topLeft,
                    iconSize: 25.0,
                    icon: Icon(
                        widget.verified.trashed
                            ? FontAwesomeIcons.solidArrowAltCircleUp
                            : FontAwesomeIcons.arrowUp,
                        color: widget.verified.trashed
                            ? Colors.green
                            : Colors.grey),
                    onPressed: () async {
                      setState(() {
                        widget.verified.upvotes = widget.verified.trashed
                            ? widget.verified.upvotes - 1
                            : widget.verified.upvotes + 1;
                        widget.verified.downvotes = widget.verified.disliked
                            ? widget.verified.downvotes - 1
                            : widget.verified.downvotes;
                        widget.verified.trashed = !widget.verified.trashed;
                        widget.verified.disliked = false;
                      });
                      await verify_function();
                    }),
                Container(
                    padding: EdgeInsets.only(left: 2.0, right: 4.0),
                    height: 36.0,
                    child: VerticalDivider(
                      color: Colors.black,
                      thickness: 1,
                      width: 10,
                      indent: 6,
                    )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 6, 0, 0),
                  child: Text(
                    " ${widget.verified.downvotes}",
                    style: TextStyle(fontFamily: "SegoeUI", fontSize: 20),
                  ),
                ),
                IconButton(
                    padding: EdgeInsets.only(left: 10.0, bottom: 14.0),
                    alignment: Alignment.bottomLeft,
                    iconSize: 25.0,
                    icon: Icon(
                        widget.verified.disliked
                            ? FontAwesomeIcons.solidArrowAltCircleDown
                            : FontAwesomeIcons.arrowDown,
                        color: widget.verified.disliked
                            ? Colors.red
                            : Colors.grey),
                    onPressed: () async {
                      setState(() {
                        widget.verified.downvotes = widget.verified.disliked
                            ? widget.verified.downvotes - 1
                            : widget.verified.downvotes + 1;
                        widget.verified.upvotes = widget.verified.trashed
                            ? widget.verified.upvotes - 1
                            : widget.verified.upvotes;
                        widget.verified.disliked = !widget.verified.disliked;
                        widget.verified.trashed = false;
                      });
                      await verify_function();
                    }),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  String _sendData() {
    if (widget.user['first_name'] != "") {
      String str = widget.user['first_name'].substring(0, 1);
      print("Yo : " + str);
      return str;
    } else {
      return "Bakaaaa";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool render =
        ifCollect(double.parse(widget.lat), double.parse(widget.lng)) &&
            !widget.verified.collected;
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15.0))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 7, 6),
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: getColor(),
            shadowColor: Colors.grey,
            elevation: 15.0,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width / 1.6,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
                            child: Row(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: CircleAvatar(
                                    radius: 18.0,
                                    backgroundColor: Colors.lightBlueAccent,
                                    child: Text(
                                      _sendData(),
                                      style: TextStyle(fontSize: 26.0),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: SizedBox(
//                                    height: 60,
                                    width: MediaQuery.of(context).size.width /
                                            1.6 -
                                        60,
                                    child: AutoSizeText(
                                      widget.description == "" ||
                                              widget.description == null
                                          ? "Trash without description"
                                          : widget.description,
                                      softWrap: true,
                                      minFontSize: 14.0,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "SegoeUI"),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      widget.is_indoors == false
                          ? CircleAvatar(
                              backgroundColor: getIconColor(),
                              child: Icon(
                                FontAwesomeIcons.trashAlt,
                                color: Colors.white,
                              ),
                            )
                          : Image.asset(
                              'assets/home.png',
                              width: 30,
                              height: 30,
                            ),
                    ],
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onDoubleTap: () async {
                      if (widget.voted.trashed != true) {
                        setState(() {
                          widget.voted.upvotes = widget.voted.trashed
                              ? widget.voted.upvotes
                              : widget.voted.upvotes + 1;
                          widget.voted.downvotes = widget.voted.disliked
                              ? widget.voted.downvotes - 1
                              : widget.voted.downvotes;
                          widget.voted.trashed = true;
                          widget.voted.disliked = false;
                          widget.showHeartOverlay = true;
                          if (widget.showHeartOverlay) {
                            Timer(const Duration(milliseconds: 180), () {
                              setState(() {
                                widget.showHeartOverlay = false;
                              });
                            });
                          }
                        });
                      }
                      await vote_function();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        widget.imageUrl == null
                            ? Image.asset('assets/profile.jpg')
                            : CachedNetworkImage(
                                imageUrl: widget.imageUrl,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        SizedBox(
                                            height: 250,
                                            width: 380,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0),
                                                  ),
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                        Colors.blueGrey,
                                                        Colors.blueAccent
                                                      ])),
                                            )),
                                errorWidget: (context, url, error) => SizedBox(
                                    height: 250,
                                    width: 380,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.blueGrey,
                                                Colors.blueAccent
                                              ])),
                                    )),
                              ),
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
                      Container(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width / 2.45,
                                height: 42.0,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                child: Wrap(
                                  spacing: 1.0,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10.0, 8, 0, 0),
                                      child: Text(
                                        " ${widget.voted.upvotes}",
                                        style: TextStyle(
                                            fontFamily: "SegoeUI",
                                            fontSize: 20),
                                      ),
                                    ),
                                    IconButton(
                                        padding: EdgeInsets.only(
                                            left: 10.0, top: 6.0),
                                        alignment: Alignment.topLeft,
                                        iconSize: 25.0,
                                        icon: Icon(
                                            widget.voted.trashed
                                                ? FontAwesomeIcons.solidThumbsUp
                                                : FontAwesomeIcons.thumbsUp,
                                            color: widget.voted.trashed
                                                ? Colors.green
                                                : Colors.grey),
                                        onPressed: () async {
                                          setState(() {
                                            widget.voted.upvotes =
                                                widget.voted.trashed
                                                    ? widget.voted.upvotes - 1
                                                    : widget.voted.upvotes + 1;
                                            widget.voted.downvotes =
                                                widget.voted.disliked
                                                    ? widget.voted.downvotes - 1
                                                    : widget.voted.downvotes;
                                            widget.voted.trashed =
                                                !widget.voted.trashed;
                                            widget.voted.disliked = false;
                                          });
                                          await vote_function();
                                        }),
                                    Container(
                                        padding: EdgeInsets.only(
                                            left: 2.0, right: 4.0),
                                        height: 36.0,
                                        child: VerticalDivider(
                                          color: Colors.black,
                                          thickness: 1,
                                          width: 10,
                                          indent: 6,
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          5.0, 8, 0, 0),
                                      child: Text(
                                        " ${widget.voted.downvotes}",
                                        style: TextStyle(
                                            fontFamily: "SegoeUI",
                                            fontSize: 20),
                                      ),
                                    ),
                                    IconButton(
                                        padding: EdgeInsets.only(
                                            left: 10.0, bottom: 14.0),
                                        alignment: Alignment.bottomLeft,
                                        iconSize: 25.0,
                                        icon: Icon(
                                            widget.voted.disliked
                                                ? FontAwesomeIcons
                                                    .solidThumbsDown
                                                : FontAwesomeIcons.thumbsDown,
                                            color: widget.voted.disliked
                                                ? Colors.red
                                                : Colors.grey),
                                        onPressed: () async {
                                          setState(() {
                                            widget.voted.downvotes = widget
                                                    .voted.disliked
                                                ? widget.voted.downvotes - 1
                                                : widget.voted.downvotes + 1;
                                            widget.voted.upvotes =
                                                widget.voted.trashed
                                                    ? widget.voted.upvotes - 1
                                                    : widget.voted.upvotes;
                                            widget.voted.disliked =
                                                !widget.voted.disliked;
                                            widget.voted.trashed = false;
                                          });
                                          await vote_function();
                                        }),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                child: widget.is_indoors == false
                                    ? (render
                                        ? Image.asset(
                                            "assets/Collect Button.png",
                                            height: 50,
                                            width: 135)
                                        : Container(
                                            child: Image.asset(
                                                "assets/Google Maps Button.png",
                                                height: 43,
                                                width: 150),
                                          ))
                                    : Container(
                                        child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Colors.white,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Contact',
                                              style: TextStyle(
                                                fontFamily: 'SegoeUI',
                                                color: Colors.yellow[700],
                                                fontSize: 20,
                                              )),
                                        ),
                                      )),
                                onTap: () async {
                                  if (widget.is_indoors == true) {
                                    print('Contact');
                                  } else {
                                    if (render) {
                                      await collect();
                                      print("Tapped");
                                    } else {
                                      global_store
                                          .dispatch(new LatAction(widget.lat));
                                      global_store
                                          .dispatch(new LngAction(widget.lng));
                                      global_store.dispatch(
                                          new NavigatePushAction(
                                              AppRoutes.map));
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      widget.is_indoors == false
                          ? (widget.verified.collected
                              ? Divider(
                                  color: Colors.black,
                                  thickness: 1.2,
                                )
                              : Container())
                          : Container(),
                      widget.is_indoors == false
                          ? (widget.verified.collected
                              ? getCollect(context)
                              : Container())
                          : Container()
                    ],
                  )
                ],
              ),
            )),
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
