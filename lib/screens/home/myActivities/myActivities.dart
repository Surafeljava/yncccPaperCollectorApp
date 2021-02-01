import 'package:flutter/material.dart';

class MyActivities extends StatefulWidget {
  @override
  _MyActivitiesState createState() => _MyActivitiesState();
}

class _MyActivitiesState extends State<MyActivities> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text('Activities', style: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 1.0, fontSize: 20.0),),
      ),
      body: Container(
        child: Center(
          child: Text('My Activities'),
        ),
      ),
    );
  }
}
