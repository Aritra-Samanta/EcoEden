import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CoronaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/COVID 19 - 1.png",height: 100,width:1024),
            Divider(
              indent: MediaQuery.of(context).size.width/8,
              endIndent: MediaQuery.of(context).size.width/8,
              color:Colors.black,
              thickness: 1.2,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height/20,
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width/15,),
                Image.asset("assets/Mask.png",height: 120,width: 120,),
                Text('Use a Medical Mask',style: TextStyle(color: Color(0xff22cf8d),fontSize: 21.0),),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width/10,),
                Expanded(child: Text('Use an alcohol based gel',style: TextStyle(color: Color(0xffff9a1b),fontSize: 21.0),)),
                Image.asset("assets/Hand Wash - 1.png",height: 100,width: 100,),
                SizedBox(width: 40,),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width/10,),
                Expanded(child: Text('Wash your hands thoroughly',style: TextStyle(color: Color(0xff22cf8d),fontSize: 21.0),)),
                Image.asset("assets/Hand Wash - 2.png",height: 100,width: 100,),
                SizedBox(width: 40,),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: MediaQuery.of(context).size.width/12,),
                Image.asset("assets/No Contact.png",height: 100,width: 100,),
                Text('Avoid Physical Contact',style: TextStyle(color: Color(0xffff9a1b),fontSize: 20.5),),
                SizedBox(width: 40,),
              ],
            ),
            Container(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: <Widget>[
                    SizedBox(width: MediaQuery.of(context).size.width/12,),
                    Image.asset("assets/EcoEden-Logo-withoutText.png",height: 80,width: 80,),
                    VerticalDivider(color: Colors.black,
                      thickness: 2, width: 20,),
                    RichText(text: TextSpan(text :'#In This',style: TextStyle(color: Color(0xff22cf8d),fontSize: 20.5),children: <TextSpan>[
                      TextSpan(text :'Together',style: TextStyle(color: Color(0xffff9a1b),fontSize: 20.5)),
                    ])
                    ),
                    //SizedBox(width: 40,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
