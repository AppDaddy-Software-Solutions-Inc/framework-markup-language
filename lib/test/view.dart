// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

class TestWidget extends StatefulWidget {
  @override
  TestWidgetState createState() => TestWidgetState();
}

class TestWidgetState extends State<TestWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [

        Expanded(child:
          Row(children: [
//            Expanded(child:
//              Container(color: Colors.blue, child:
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(color: Colors.deepOrange, child: Icon(Icons.airplanemode_active)),
                  Icon(Icons.airplanemode_inactive),
              ],),//)//)
          ],),)
      ],)
    );
  }
}
