import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecoeden/models/post.dart';
import 'package:ecoeden/models/feedsArticle.dart';
import 'package:ecoeden/services/webservice.dart';
import 'package:geolocator/geolocator.dart';
import "package:threading/threading.dart";

class FeedsPageState extends State<FeedsPage> {
  List<FeedsArticle> _newsArticles = List<FeedsArticle>();
  bool showHeartOverlay = false;
  bool isLoading = false;
  bool _insideFeed = true;
  Position myLoc;

  ScrollController _scrollController = new ScrollController();
  static String nextPage = 'https://api.ecoeden.xyz/feed/';
  // ignore: non_constant_identifier_names
  static final String NEWS_PLACEHOLDER_IMAGE_ASSET_URL =
      'assets/placeholder.png';
  @override
  void initState() {
    print("Inside Feed");
    super.initState();
    locationTracker();
    nextPage = 'https://api.ecoeden.xyz/feed/';
    _populateNewsArticles();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          FeedsPageState.nextPage != null) {
        _populateNewsArticles();
        var val = _newsArticles.map((x) => x.id).toList();
        print("It's Feed Show Time !!!");
        print(val);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _insideFeed = false;
    super.dispose();
  }

  void locationTracker() async {
    print("Inside tracker");
    var thread = new Thread(_getLocation);
    await thread.start();
    await thread.join();
  }

  Future _getLocation() async {
    while(_insideFeed) {
      await Thread.sleep(3000);
      myLoc = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print("Upgraded Location !!");
    }
  }

  void _populateNewsArticles() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      List<FeedsArticle> newsArticles =
          await Webservice().load(FeedsArticle.all);
      setState(() {
        isLoading = false;
        _newsArticles.addAll(newsArticles);
      });
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 0.0,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //print(_newsArticles[0].description);
    return Scaffold(
        appBar: AppBar(
          title: Text('Feed'),
        ),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: _newsArticles.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == _newsArticles.length) {
                      return _buildProgressIndicator();
                    } else {
                      print("Index : " + index.toString());
                      return Post(
                          showHeartOverlay: showHeartOverlay,
                          description: _newsArticles[index].description,
                          imageUrl: _newsArticles[index].image,
                          lat: _newsArticles[index].lat,
                          lng: _newsArticles[index].lng,
                          id: _newsArticles[index].id,
                          user: _newsArticles[index].user,
                          voted: _newsArticles[index].voted,
                          verified: _newsArticles[index].verified);
                    }
                  },
                  controller: _scrollController,
                ),
              )
            ],
          ),
        ));
  }
}

class FeedsPage extends StatefulWidget {
  @override
  createState() => FeedsPageState();
}
