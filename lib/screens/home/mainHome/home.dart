import 'package:app/screens/authenticate/tokenCheckState.dart';
import 'package:app/screens/home/mainHome/mapViewHome.dart';
import 'package:app/screens/home/mainHome/myDrawer.dart';
import 'package:app/screens/home/mainHome/requestsView.dart';
import 'package:app/screens/registration/registrationState.dart';
import 'package:app/services/authService.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  AuthService _authService = new AuthService();

  bool checked = false;
  String uid = '';
  DocumentReference reference;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      uid = FirebaseAuth.instance.currentUser.uid.toString();
      reference = FirebaseFirestore.instance.doc('collectors/$uid');
      checked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: MyDrawer(),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text('HOME', style: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 1.0, fontSize: 20.0),),
        actions: [
          !checked ?
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.grey[400],),
          ) :
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('recyclingRequests').where('acceptedByCollector', isEqualTo: reference).orderBy('dateOfAcceptance').snapshots(),
            builder: (context, snapshot) {
              if(snapshot.data==null){
                return IconButton(
                  icon: Icon(Icons.notifications, color: Colors.grey[400],),
                );
              }else{
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Badge(
                      padding: EdgeInsets.all(4.0),
                      position: BadgePosition.topStart(),
                      badgeColor: Color(0xFF0DE79D),
                      badgeContent: Text(snapshot.data.documents.length.toString(), style: TextStyle(color: Colors.white),),
                      child: Icon(Icons.notifications, color: Color(0xFF002E49),),
                    ),
                    onPressed: (){

                    },
                  )
                );
              }
            }
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            MapViewHome(),
            RequestsView(),
          ],
        ),
      ),
    );
  }
}
