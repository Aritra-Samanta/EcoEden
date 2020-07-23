import 'dart:async';
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


class Post extends StatefulWidget {
  bool disliked = false;
  bool trashed = false;
  bool showHeartOverlay = false;
  final String description;
  final String imageUrl;
  final String lat;
  final String lng;
  final int id;
  final Map<String,dynamic> user;
  final List<dynamic> activity;
  int upvotes;
  int downvotes;
  Post({this.activity,this.id,this.showHeartOverlay,this.lat,this.lng,this.upvotes,this.downvotes,this.description,this.imageUrl,this.user});

  @override
  _PostState createState() => _PostState();
}
class _PostState extends State<Post> {
  // ignore: non_constant_identifier_names
  static String base_url =  'https://api.ecoeden.xyz/activity/';

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    set_function();
  }

  // ignore: non_constant_identifier_names
  void set_function(){
    if(widget.activity.length==0 || widget.activity[0]['vote']==0)
    {
      widget.disliked = false; widget.trashed = false;
    }
    else if(widget.activity[0]['vote'] > 0)
    {
      widget.disliked = false; widget.trashed = true;
    }
    else
    {
      widget.disliked = true; widget.trashed = false;
    }
  }

  // ignore: non_constant_identifier_names
  void vote_function() async {
    print("inside vote");
    var json = new Map<String,dynamic>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt = prefs.getString('user');
    if(widget.disliked == false && widget.trashed ==false)
      json['vote'] = "0";
    else if(widget.disliked == false && widget.trashed ==true)
      json['vote'] = "1";
    else if(widget.disliked == true && widget.trashed ==false)
      json['vote'] = "-1";
//    String json = '{"upvotes": "${widget.upvotes}","downvotes":"${widget.downvotes}"}';
    if(widget.activity.length!=0){
      String url = base_url + widget.activity[0]['id'].toString() + "/";
      var response = await http.patch(url, headers: {HttpHeaders.authorizationHeader : "Token " + jwt}, body: json);
      print(response.body.toString());
      if(response.statusCode==200)
        print("Patch successful");
    }
    else{
      json['user'] = "http://api.ecoeden.xyz/users/" + global_store.state.user.id.toString() + "/";
      json['photo'] = "http://api.ecoeden.xyz/photos/" + widget.id.toString() + "/";
      var response = await http.post(base_url, headers: {HttpHeaders.authorizationHeader : "Token " + jwt}, body: json);
      print(response.body.toString());
      if(response.statusCode==200)
        print("Post successful");
    }
  set_function();
  }

  Color getColor( ){
    if ( widget.upvotes < 5) {
      return Colors.grey;
    }
    else{
      return Colors.red;
    }

  }

  @override
  Widget build(BuildContext context) {
    //print(widget.upvotes.runtimeType);
    return Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            PostHeader(widget.user),
            ListTile(
              //contentPadding: EdgeInsets.all(20.0),
              leading: Text(
                widget.description,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB( 4.0 ,0.0 , 8.0 , 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[

                  Container(
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      child:  Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child:  Text(widget.description,
                            style: TextStyle(color: Colors.black,  fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,),
                        ),
                      )),
                  Icon(
                    FontAwesomeIcons.trashAlt,
                    color: getColor(),
                  ),

                ],
              ),
            ),
            GestureDetector(
              onDoubleTap: () {
                setState(() {
                  widget.upvotes = widget.trashed ? widget.upvotes  :widget.upvotes + 1 ;
                  widget.downvotes =  widget.disliked ? widget.downvotes - 1 : widget.downvotes;
                  widget.trashed = true;
                  widget.disliked = widget.disliked ? !widget.disliked : false;
                  widget.showHeartOverlay = true;
                  if (widget.showHeartOverlay) {
                    Timer(const Duration(
                        milliseconds: 180), () {
                      setState(() {
                        widget.showHeartOverlay = false;
                      });
                    }
                    );
                  }
                  vote_function();
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  //Image.asset('assets/profile.jpg'),
                  widget.imageUrl== null
                      ? Image.asset('assets/profile.jpg')
                      : CachedNetworkImage(
                      imageUrl: widget.imageUrl),
                  widget.showHeartOverlay ?
                  Icon(
                    FontAwesomeIcons.solidTrashAlt, color: Colors.white54,
                    size: 80.0,)
                      : Container(),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 5.0 , vertical: 2.0),
                  leading: Wrap(
                    spacing: 6.0,
                    children: <Widget>[
                      Text(" ${widget.upvotes} upvotes",style: TextStyle(fontWeight: FontWeight.w400),),
                      Text(" ${widget.downvotes} downvotes",style: TextStyle(fontWeight: FontWeight.w400),),
                    ],
                  ),
                ),
                SizedBox(
                  height: 0.0,
                  child: Divider(
                    color: Color(0xff4E4F50),
                  ),
                ),
                ListTile(
                  leading: Wrap(
                    //mainAxisSize: MainAxisSize.min,
                    spacing: 1.0,
                    children: <Widget>[
                      IconButton(
                          iconSize: 25.0,
                          icon: Icon(widget.trashed ? FontAwesomeIcons.solidThumbsUp : FontAwesomeIcons.thumbsUp,
                              color: widget.trashed ? Colors.green : Colors.grey),
                          onPressed: () {
                            setState((){
                              widget.upvotes = widget.trashed ? widget.upvotes - 1 :widget.upvotes + 1 ;
                              widget.downvotes = widget.disliked ? widget.downvotes - 1 : widget.downvotes;
                              widget.trashed = !widget.trashed;
                              widget.disliked = widget.disliked ? !widget.disliked : false;
                              vote_function();
                            });
                          }),
                      IconButton(
                          iconSize: 25.0,
                          icon: Icon(widget.disliked ? FontAwesomeIcons.solidThumbsDown : FontAwesomeIcons.thumbsDown,
                              color: widget.disliked ? Colors.red : Colors.grey),
                          onPressed: () {
                            setState(() {
                              widget.downvotes = widget.disliked ? widget.downvotes - 1 :widget.downvotes + 1 ;
                              widget.upvotes =  widget.trashed ? widget.upvotes - 1 : widget.upvotes;
                              widget.disliked = !widget.disliked;
                              widget.trashed = widget.trashed ? !widget.trashed : false;
                              vote_function();
                            });
                          }),
                    ],
                  ),
                  trailing: IconButton(
                    iconSize: 27.0,
                    icon: Icon(Icons.location_on,color:Colors.red) ,
                    onPressed: (){
                      print("On pressed" + widget.lat  + widget.lng);
                      print("Global" + global_store.state.lat + global_store.state.lng);
                      global_store.dispatch(new LatAction(widget.lat));
                      global_store.dispatch(new LngAction(widget.lng));
                      print("Global" + global_store.state.lat + global_store.state.lng);
                      global_store.dispatch(new NavigatePushAction(AppRoutes.map));
                    },
                  ),
                ),
              ],
            )
          ],
        )
    );
  }
}

class PostHeader extends StatelessWidget {
  final Map<String,dynamic> user;

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
            width:45.0,
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
            child: Text(user['first_name'].toString() + " " + user['last_name'].toString() ,
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
          )
      ),
    );
  }
}