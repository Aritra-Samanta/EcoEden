import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecoeden/main.dart';
import 'package:ecoeden/screens/feeds_page.dart';
import 'package:ecoeden/models/feedsArticle.dart';
import 'package:ecoeden/services/webservice.dart';
import 'package:ecoeden/models/post.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Profile Page

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<FeedsArticle> _newsArticles = List<FeedsArticle>();

  @override
  void initState() {
    super.initState();
    FeedsPageState.nextPage = 'https://api.ecoeden.xyz/photos/';
    _fetch();
  }

  void _fetch() async {
    while (FeedsPageState.nextPage != null) {
      await _fetchNewsArticles();
    }
  }

  Future<void> _fetchNewsArticles() async {
    List<FeedsArticle> newsArticles = await Webservice().load(FeedsArticle.all);
    setState(() {
      _newsArticles.addAll(newsArticles);
    });
  }

  TextStyle labelStyle =
  TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w500);
  TextStyle normalStyle =
  TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w500);

  TextStyle selectStyle(String status) {
    if (status.compareTo('verified') == 0) {
      return TextStyle(
          color: Colors.green, fontSize: 6, fontWeight: FontWeight.w300);
    } else {
      return TextStyle(
          color: Colors.red, fontSize: 6, fontWeight: FontWeight.w300);
    }
  }

//  Porny & Bati Productions
  @override
  Widget build(BuildContext context) {
    Widget showProfile(BuildContext context) {
      print("In Profile");
      return Column(
//        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 25, 0, 0),

            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon :Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size : 28
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                },

              ),
            ),

          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 10, 0, 0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Profile' , style: TextStyle( color: Colors.black , fontSize : 40.0,
                    fontWeight: FontWeight.bold), textAlign: TextAlign.left,)
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0 ),
            child: Center(
              child : Hero(
                tag: "profile",
                child: CircleAvatar(
                  radius: 38.0,
                  backgroundColor: Colors.lightBlueAccent,
                  child: Text(
                    (global_store.state.user.firstName)[0].toString(),
                    style: TextStyle(fontSize: 40.0),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0,  0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      global_store.state.user.firstName +
                          " " +
                          global_store.state.user.lastName,
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(global_store.state.user.email,  style: TextStyle(
                      fontSize: 15.0, fontWeight: FontWeight.bold),

                  ),
//                        Text(global_store.state.user.mobile),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(70, 20, 70, 10),
            child: Center(
              child: Table(
                border : TableBorder(
                    horizontalInside: BorderSide(color: Colors.black),
                    verticalInside: BorderSide(color: Colors.black)
                ),
                children: [
                  TableRow(
                      children: [

                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                          child: Center(child:
                          CircleAvatar(
                            radius: 18.0,
                            backgroundColor: Colors.red,
                            child: Icon(

                              FontAwesomeIcons.solidTrashAlt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                          child: Center(child:
                          CircleAvatar(
                            radius: 18.0,
                            backgroundColor: Colors.yellow,
                            child: Icon(

                              FontAwesomeIcons.solidTrashAlt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                          child: Center(child:
                          CircleAvatar(
                            radius: 18.0,
                            backgroundColor: Colors.green,
                            child: Icon(

                              FontAwesomeIcons.solidTrashAlt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          ),
                        ),
                      ]
                  ),
                  TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text(global_store.state.user.posts.toString())),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text(global_store.state.user.collections.toString())),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text(global_store.state.user.verifications.toString())),
                        ),
                      ]
                  ),

                ],
              ),
            ),
          ),





          Expanded(
            flex: 1,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _newsArticles.length,
              itemBuilder: (BuildContext context, int index) {
                return Post(
                  showHeartOverlay: false,
                  description: _newsArticles[index].description,
                  imageUrl: _newsArticles[index].image,
                  upvotes: _newsArticles[index].upvotes,
                  downvotes: _newsArticles[index].downvotes,
                  lat: _newsArticles[index].lat,
                  lng: _newsArticles[index].lng,
                  id: _newsArticles[index].id,
                  user: _newsArticles[index].user,
                  activity: _newsArticles[index].activity,
                );
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
//      appBar: AppBar(
////        title: Text('Profile'),
//          backgroundColor: Color.fromRGBO(250,250, 250, 1),
//          elevation: 0,
//          leading : BackButton(
//              color: Colors.black
//          )
//      ),
      body: Stack(
          children: <Widget>[
            Positioned(
                child : Image.asset(
                  'assets/wave.png' ,
                  fit: BoxFit.fitWidth,
                )
            ),
            showProfile(context)
          ]
      ),

    );


  }
}