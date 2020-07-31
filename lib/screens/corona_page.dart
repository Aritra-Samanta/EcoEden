import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CoronaPage extends StatelessWidget {
  double L, M, S;
  @override
  Widget build(BuildContext context) {
    L = MediaQuery.of(context).size.height / 7;
    M = MediaQuery.of(context).size.height / 9;
    S = MediaQuery.of(context).size.height / 11;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/COVID 19 - 1.png",height: L, width: MediaQuery.of(context).size.height / 1.35),
            Divider(
              indent: MediaQuery.of(context).size.width / 8,
              endIndent: MediaQuery.of(context).size.width / 8,
              color:Colors.black,
              thickness: 1.2,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 40,
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width / 15,),
                Image.asset("assets/Mask.png",height: L,width: L),
                Text(' ' * 8 + 'Use a Medical Mask',style: TextStyle(color: Color(0xff22cf8d),fontSize: 21.0),),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width / 10,),
                Expanded(child: Text('Use an alcohol based gel',style: TextStyle(color: Color(0xffff9a1b),fontSize: 21.0),)),
                Image.asset("assets/Hand Wash - 1.png",height: M,width: M),
                SizedBox(width: 40,),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width / 10,),
                Expanded(child: Text('Wash your hands thoroughly',style: TextStyle(color: Color(0xff22cf8d),fontSize: 21.0),)),
                Image.asset("assets/Hand Wash - 2.png",height: M,width: M),
                SizedBox(width: 40,),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width / 12,),
                Image.asset("assets/No Contact.png",height: M,width: M),
                Text(' ' * 8 + 'Avoid Physical Contact',style: TextStyle(color: Color(0xffff9a1b),fontSize: 20.5),),
                SizedBox(width: 40,),
              ],
            ),
            SizedBox(height: S/2),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
//                  SizedBox(width: MediaQuery.of(context).size.width / 7),
                  Image.asset("assets/EcoEden-Logo-withoutText.png",height: S, width: S),
                  Container(padding: EdgeInsets.only(left: 10.0, right: 10.0), height: S / 1.1 , child: VerticalDivider(color: Colors.black, thickness: 1, width: 20,)),
                  RichText(text: TextSpan(text :'#InThis',style: TextStyle(color: Color(0xff22cf8d),fontSize: 20.5),children: <TextSpan>[
                    TextSpan(text :'Together',style: TextStyle(color: Color(0xffff9a1b),fontSize: 20.5)),
                  ])
                  ),
                  //SizedBox(width: 40,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
