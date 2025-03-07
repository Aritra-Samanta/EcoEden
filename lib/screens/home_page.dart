import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app_routes.dart';
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
import 'package:pie_chart/pie_chart.dart';

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
  Map<String, double> data = new Map();
  List<Color> _colors = [Colors.red, Colors.green[400]];
  BitmapDescriptor trashIcon, collectedIcon, postIcon, currentIcon;
  List<FeedsArticle> _newsArticles = List<FeedsArticle>();
  static String nextPage = 'https://api.ecoeden.xyz/leaderboard/';
  @override
  void initState() {
    super.initState();
    print("Inside home");
    customMapPin();
    FeedsPageState.nextPage = 'https://api.ecoeden.xyz/feed/';
    _fetcher();
  }

  void _fetcher() async {
    await _fetch();
  }

  void customMapPin() async {
    trashIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/trash-icon-red.png');
    collectedIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/trash-icon-yellow.png');
  }

  BitmapDescriptor setCustomMapMarkers(FeedsArticle x) {
    if (x.verified.collected == true)
      return collectedIcon;
    else
      return trashIcon;
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
    var len = _markings.length;
    int trash = (0.7 * len).round();
    int collected = len - trash;
    data.addAll({"Trash": trash.toDouble(), "Collected": collected.toDouble()});
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
          child: Container(
            width: MediaQuery.of(context).size.width / 1.5,
            child: Drawer(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        UserAccountsDrawerHeader(
                          decoration: BoxDecoration(
                            color: Colors.greenAccent[100],
//                        color: Color.fromRGBO(250,250, 250, 1),
                          ),
                          accountName: Text(
                              global_store.state.user.firstName +
                                  " " +
                                  global_store.state.user.lastName,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24.0,
                                  fontFamily: "SegoeUI",
                                  fontWeight: FontWeight.w700)),
                          accountEmail: Text(global_store.state.user.userName,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontFamily: "SegoeUI",
                                  fontWeight: FontWeight.w600)),
                          currentAccountPicture: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              child: Hero(
                                tag: "profile",
                                child: CircleAvatar(
                                  backgroundColor: Colors.lightBlueAccent,
                                  child: Text(sendData(),
                                      style: TextStyle(fontSize: 40.0)),
                                ),
                              ),
                              onTap: () {
                                global_store.dispatch(
                                    new NavigatePushAction(AppRoutes.profile));
                              },
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 3.0),
                            child: Text('Profile',
                                style: TextStyle(
                                    fontFamily: "SegoeUI", fontSize: 18.0)),
                          ),
                          onTap: () {
                            global_store.dispatch(
                                new NavigatePushAction(AppRoutes.profile));
                          },
                        ),
                        Divider(
                            indent: 10.0, endIndent: 20.0, color: Colors.black),
                        GestureDetector(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 3.0),
                            child: Text('About Us',
                                style: TextStyle(
                                    fontFamily: "SegoeUI", fontSize: 18.0)),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        Divider(
                            indent: 10.0, endIndent: 20.0, color: Colors.black),
                        GestureDetector(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 3.0),
                            child: Text('Privacy Policy',
                                style: TextStyle(
                                    fontFamily: "SegoeUI", fontSize: 18.0)),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        Divider(
                            indent: 10.0, endIndent: 20.0, color: Colors.black),
                        GestureDetector(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 3.0),
                            child: Text('Help & Feedback',
                                style: TextStyle(
                                    fontFamily: "SegoeUI", fontSize: 18.0)),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        Divider(
                            indent: 10.0, endIndent: 20.0, color: Colors.black),
                        GestureDetector(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 3.0),
                            child: Text('Logout',
                                style: TextStyle(
                                    fontFamily: "SegoeUI", fontSize: 18.0)),
                          ),
                          onTap: () {
                            global_store.dispatch(new LogoutAction().logout());
                          },
                        ),
                        Divider(
                            indent: 10.0, endIndent: 20.0, color: Colors.black),
                        Align(
                          alignment: FractionalOffset.bottomLeft,
                          child: Container(
                              padding: EdgeInsets.only(left: 30.0, bottom: 5.0),
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    child: Image.asset(
                                      "assets/COVID_19_2.png",
                                      height: 50,
                                      width: 150,
                                    ),
                                    onTap: () {
                                      global_store.dispatch(
                                          new NavigatePushAction(
                                              AppRoutes.corona));
                                    },
                                  ),
                                  SizedBox(height: 5.0),
                                  Image.asset(
                                      "assets/EcoEden-Logo-withoutText.png",
                                      height: 150.0,
                                      width: 200.0),
                                  Text(
                                    "\u00a9 EcoEden 2020",
                                    style: TextStyle(fontFamily: "SegoeUI"),
                                  ),
                                  Text(
                                    "All Rights Reserved.",
                                    style: TextStyle(fontFamily: "SegoeUI"),
                                  ),
                                ],
                              )),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _child,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add_a_photo,
            color: Colors.black,
            size: 27.5,
          ),
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
              padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 30.0),
                    child: IconButton(
//                color: Colors.black,
                      icon: Icon(
                        FontAwesomeIcons.users,
                      ),
                      onPressed: () {
                        global_store.dispatch(
                            new NavigatePushAction(AppRoutes.community));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 100.0),
                    child: IconButton(
//                color: Colors.black,
                      icon: Icon(
                        FontAwesomeIcons.trophy,
                      ),
                      onPressed: () {
                        global_store.dispatch(
                            new NavigatePushAction(AppRoutes.leaderboard));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 30.0),
                    child: IconButton(
//                color: Colors.black,
                      icon: Icon(
                        FontAwesomeIcons.listAlt,
                      ),
                      onPressed: () {
                        global_store
                            .dispatch(new NavigatePushAction(AppRoutes.feed));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(),
                    child: IconButton(
                      icon: Icon(FontAwesomeIcons.chartPie),
                      onPressed: () async {
                        await showModalBottomSheet<void>(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (BuildContext context) {
                            return ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0)),
                              child: Container(
                                  height: 300,
                                  color: Colors.green[100],
                                  child: Center(
                                      child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Analytics',
                                                style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: "SegoeUI",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 30),),
                                          ),

                                          PieChart(
                                            dataMap: data,
                                            legendStyle: TextStyle(color: Colors.black, fontFamily: "SegoeUI", fontSize: 18.0),
                                            colorList: _colors, // if not declared, random colors will be chosen
                                            animationDuration: Duration(milliseconds: 1500),
                                            chartLegendSpacing: 32.0,
                                            chartRadius: MediaQuery.of(context).size.width /
                                                2.7, //determines the size of the chart
                                            showChartValuesInPercentage: true,
                                            showChartValues: true,
                                            showChartValuesOutside: false,
                                            chartValueBackgroundColor: Colors.grey[100],
                                            showLegends: true,
                                            legendPosition: LegendPosition.right, //can be changed to top, left, bottom
                                            decimalPlaces: 1,
                                            showChartValueLabel: true,
                                            initialAngle: 0,
                                            chartValueStyle: defaultChartValueStyle.copyWith(
                                              color: Colors.blueGrey[900].withOpacity(0.9),
                                            ),
                                            chartType: ChartType.disc, //can be changed to ChartType.ring
                                          ),

                                          RaisedButton(
                                              child: const Text('Close', style: TextStyle(color: Colors.black, fontFamily: "SegoeUI", fontSize: 18.0),),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              color: Colors.blueGrey[300],
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }
                                          )
                                        ],

                                      ))),
                            );
                          },
                          elevation: 20.0,
                          isScrollControlled: true,
                        );
                      },
                    ),
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
          icon: setCustomMapMarkers(x),
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
              "- $differenceInDays days ago",
              style: TextStyle(
                  fontStyle: FontStyle.normal, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }

  Widget mapWidget() {
    return Stack(
      children: <Widget>[
        GoogleMap(
          mapType: MapType.normal,
          markers: _markings,
          initialCameraPosition: CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 12.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 7.0, 100.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 25,
              child: IconButton(
                  icon: Icon(Icons.my_location, size: 28, color: Colors.black),
                  onPressed: () {
                    _controller.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        bearing: 0,
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 17.0,
                      ),
                    ));
                  }),
            ),
          ),
        )
      ],
    );
  }
}
