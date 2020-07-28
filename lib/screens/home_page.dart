import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app_routes.dart';
import '../app_routes.dart';
import '../main.dart';
import '../main.dart';
import '../models/feedsArticle.dart';
import '../redux/actions.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ecoeden/models/user.dart';
import 'package:ecoeden/services/webservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoeden/models/feedsArticle.dart';
import 'package:ecoeden/screens/feeds_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../redux/actions.dart';

final get_User = 'https://api.ecoeden.xyz/users/';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  GoogleMapController _controller;
  Position position;
  Widget _child;
  List<Placemark> placemark;
  String _address;
  double _lat, _lng;
  Set<Marker> _markings = Set<Marker>();

  List<FeedsArticle> _newsArticles = List<FeedsArticle>();
  static String nextPage = 'https://api.ecoeden.xyz/leaderboard/';
  @override
  void initState() {
    super.initState();
    print("Inside home");
    FeedsPageState.nextPage = 'https://api.ecoeden.xyz/feed/';
    _fetcher();
  }

  void _fetcher() async {
    await _fetch();
  }

  Future<void> _fetch() async {
    await getValidUser();
    await getCurrentLocation();
    while (FeedsPageState.nextPage != null) {
      await _fetchNewsArticles();
    }

  }

  Future<void> getValidUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt = prefs.getString('user');

    var response = await http.get(get_User,
        headers: {HttpHeaders.authorizationHeader: "Token " + jwt});

    if (response.statusCode == 200) {
      print(response.body.toString());
      final result = json.decode(response.body);
      User user = User.fromJson(result["results"][0]);
      global_store.dispatch(new userAction(user));
      print("User" + user.id.toString());
      print("User" + user.firstName.toString());
      print("User score : " + user.verifications.toString());
    } else {
      print("Exception !!!");
      throw Exception('Failed to load data!');
    }
  }

  Future<void> _fetchNewsArticles() async {
    List<FeedsArticle> newsArticles = await Webservice().load(FeedsArticle.all);
    setState(() {
      _newsArticles.addAll(newsArticles);
    });
    _createMarker(newsArticles);
  }



  Future<String> getAddress(double latitude, double longitude) async {
    placemark =
    await Geolocator().placemarkFromCoordinates(latitude, longitude);
    String ad = placemark[0].name.toString() +
        ", " +
        placemark[0].locality.toString() +
        ", Postal Code:" +
        placemark[0].postalCode.toString();
    return ad;
  }

  Future<void> getCurrentLocation() async {
    res = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    String ad = await getAddress(res.latitude, res.longitude);
    setState(() {
      position = res;
      _lat = position.latitude;
      _lng = position.longitude;
      _address = ad;
      _markings.add(_homeMarker());
      _child = mapWidget();
    });
  }

  String sendData() {
    if (global_store.state.user.firstName != "") {
      String str = global_store.state.user.firstName.substring(0, 1);
      print("Yo : " + str);
      return str;
    } else {
      return "Gaand Mereche";
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit the App'),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Text("NO"),
          ),
          SizedBox(height: 16),
          new GestureDetector(
            onTap: () => SystemNavigator.pop(),
            child: Text("YES"),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
            size: 50,
          ),
        ),
        drawer: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
          child: Drawer(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      UserAccountsDrawerHeader(
                        decoration: BoxDecoration(
                          color: Colors.greenAccent[100],
//                        color: Color.fromRGBO(250,250, 250, 1),
                        ),
                        accountName: Text(global_store.state.user.userName ,
                            style:TextStyle( color:Colors.black , fontSize: 20)),
                        accountEmail: Text(global_store.state.user.email,
                            style:TextStyle( color:Colors.black , fontSize: 20)),
                        currentAccountPicture: GestureDetector(
                          child: Hero(
                            tag: "profile",
                            child: CircleAvatar(
                              backgroundColor: Colors.lightBlueAccent,
                              child: Text(sendData(), style: TextStyle(fontSize: 40.0),),
                            ),
                          ),
                          onTap: () {
                            global_store.dispatch(new NavigatePushAction(AppRoutes.profile));
                          },
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
                          child: Text('Profile', style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                        onTap: () {
                          global_store.dispatch(new NavigatePushAction(AppRoutes.profile));
                        },
                      ),
                      Divider(indent: 15.0, endIndent: 20.0, color: Colors.black),
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
                          child: Text('About Us', style: TextStyle(fontSize: 20.0),),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      Divider(indent: 15.0, endIndent: 20.0, color: Colors.black),
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
                          child: Text('Privacy Policy', style: TextStyle(fontSize: 20.0),),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      Divider(indent: 15.0, endIndent: 20.0, color: Colors.black),
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
                          child: Text('Logout', style: TextStyle(fontSize: 20.0),),
                        ),
                        onTap: () {
                          global_store.dispatch(new LogoutAction().logout());
                        },
                      ),
                      Divider(indent: 15.0, endIndent: 20.0, color: Colors.black),
                    ],
                  ),
                ),
                Container(
                    child: Align(
                        alignment: FractionalOffset.bottomLeft,
                        child: Container(
                            padding: EdgeInsets.only(left: 45.0, bottom: 30.0),
                            child: Column(
                              children: <Widget>[
                                //Divider(),
                                Image.asset("assets/COVID_19_2.png", height: 50, width: 150,),
                                SizedBox(height: 20.0),
                                Image.asset("assets/EcoEden-Logo-withoutText.png",height: 150.0,width:200.0),
                                Text("\u00a9 EcoEden 2020"),
                                Text("All Rights Reserved."),
                              ],
                            )
                        )
                    )
                )
              ],
            ),
          ),
        ),
        body: _child,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add_a_photo, color: Colors.black,),
          backgroundColor: Colors.blueGrey[100],
          elevation: 0.0,
          onPressed: () {
            global_store.dispatch(new NavigatePushAction(AppRoutes.camera));
          },
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 40.0,
            color: Color(0xff22AA8D),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(FontAwesomeIcons.trophy),
                    onPressed: (){
                      global_store.dispatch(new NavigatePushAction(AppRoutes.leaderboard));
                    },
                  ),
                  IconButton(
//                color: Colors.black,
                    icon: Icon(
                      FontAwesomeIcons.listAlt,
                    ),
                    onPressed: () {
                      global_store
                          .dispatch(new NavigatePushAction(AppRoutes.feed));
                    },
                  ),
                ],
              ),
            ),
          ),
          shape: CircularNotchedRectangle(),
        ),
      ),
    );
  }

  Marker _homeMarker() {
    return Marker(
      markerId: MarkerId('Home'),
      position: LatLng(position.latitude, position.longitude),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: 'Home', snippet: _address),
    );
  }

  void _createMarker(List<FeedsArticle> articles) async {
    for (FeedsArticle x in articles) {
      String markerAddress =
      await getAddress(double.parse(x.lat), double.parse(x.lng));
      Marker marker = Marker(
          markerId: MarkerId(x.lat + "," + x.lng),
          position: LatLng(double.parse(x.lat), double.parse(x.lng)),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: 'Location', snippet: markerAddress),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: popUpPage(x.createdAt, x.image, x.description),
                ),
              ),
            );
          });
      setState(() {
        _markings.add(marker);
        _child = mapWidget();
      });
    }
  }

  Widget popUpPage(String date, String url, String description) {
    date = date.substring(0, date.indexOf('T'));
    final String dateFormat =
    DateFormat("dd-MM-yyyy").format(DateTime.parse(date));
    DateTime dateTimeCreatedAt = DateTime.parse(date);
    DateTime dateTimeNow = DateTime.now();
    final differenceInDays = dateTimeNow.difference(dateTimeCreatedAt).inDays;
    return Container(
      color: Color(0xff757575),
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              description,
              style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
            ),
            Center(
              child: CachedNetworkImage(
                imageUrl: url,
                height: 350.0,
                width: 500.0,
                placeholder: (context, url) => CircularProgressIndicator(
                  backgroundColor: Color(0xFFB4B4B4),
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Text(
              "Created on " + dateFormat,
              style: TextStyle(
                  fontStyle: FontStyle.normal, fontWeight: FontWeight.w900),
            ),
            Text(
              "- $differenceInDays days ago", style: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }

  Widget mapWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      markers: _markings,
      initialCameraPosition: CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 12.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
    );
  }
}