import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(milliseconds: 1200),
            () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => LoginPage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: Center(
        child: Stack(children: <Widget>[
          Image.asset('assets/giphy2.gif',gaplessPlayback: true,fit:BoxFit.fill),
          TyperAnimatedTextKit(
            textAlign: TextAlign.center,
//            duration: Duration(milliseconds: 2000),
            speed: Duration(milliseconds: 1000),
            text: ['EcoEden'],
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 45.0,
              fontWeight: FontWeight.w900,
            ),
          ),
        ]),
      ),
    );
  }
}