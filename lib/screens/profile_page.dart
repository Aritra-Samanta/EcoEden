import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecoeden/main.dart';
import 'package:ecoeden/screens/feeds_page.dart';
import 'package:ecoeden/models/feedsArticle.dart';
import 'package:ecoeden/services/webservice.dart';
import 'package:ecoeden/models/post.dart';
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

  List<Widget> getPosts() {
    return _newsArticles
        .map((article) => Post(
              showHeartOverlay: false,
              description: article.description,
              imageUrl: article.image,
              lat: article.lat,
              lng: article.lng,
              id: article.id,
              user: article.user,
              voted: article.voted,
              verified: article.verified
            ))
        .toList();
  }

//  Porny & Bati Productions
  @override
  Widget build(BuildContext context) {
    Widget showProfile(BuildContext context) {
      print("In Profile");
      return Container(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 25, 0, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            size: 28, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 10, 0, 0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Profile',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 48.0,
                              fontFamily: "SegoeUI",
                              fontWeight: FontWeight.w700),
                          textAlign: TextAlign.left,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Center(
                      child: Hero(
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
                    padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
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
                                  fontSize: 28.0,
                                  fontFamily: "SegoeUI",
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            global_store.state.user.email,
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "SegoeUI",
                                fontWeight: FontWeight.w700),
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
                        border: TableBorder(
                            horizontalInside: BorderSide(color: Colors.black),
                            verticalInside: BorderSide(color: Colors.black)),
                        children: [
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                              child: Center(
                                child: CircleAvatar(
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
                              child: Center(
                                child: CircleAvatar(
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
                              child: Center(
                                child: CircleAvatar(
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
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  global_store.state.user.posts.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                      fontSize: 21.0, fontFamily: "SegoeUI", fontWeight: FontWeight.w300),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  global_store.state.user.collections.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                      fontSize: 21.0, fontFamily: "SegoeUI", fontWeight: FontWeight.w300),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  global_store.state.user.verifications.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                      fontSize: 21.0, fontFamily: "SegoeUI", fontWeight: FontWeight.w300),
                                ),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                getPosts(),
              ),
            )
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(children: <Widget>[
        Positioned(
            child: Image.asset(
          'assets/wave.png',
          fit: BoxFit.fitWidth,
        )),
        showProfile(context),
      ]),
    );
  }
}
