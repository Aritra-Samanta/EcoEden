import 'dart:async';
import 'package:ecoeden/screens/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(milliseconds: 2000),
            () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => LoginPage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.deepPurpleAccent,
      body: Container(
        child: Stack(children: <Widget>[
          Image.asset(
            'assets/wave.png' ,
            fit: BoxFit.fill,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 90.0,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Center(child: Image.asset("assets/EcoEden-Logo.png",height: 320,width: 320,)),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(50.0,0.0,50.0,80.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(child: Center(child: Image.asset("assets/SIH-Logo.png"))),
                      SizedBox(width: 15,),
                      Expanded(child: Center(child: Image.asset("assets/MIC-Logo.png")))
                    ],
                  ),
                ),
              )
            ],
          )
        ]),
      ),
    );
  }
}