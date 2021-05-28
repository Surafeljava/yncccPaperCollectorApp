import 'package:app/models/requestModel.dart';
import 'package:app/screens/home/myActivities/activityItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllActivity extends StatefulWidget {
  final int type;
  AllActivity({@required this.type});

  @override
  _AllActivityState createState() => _AllActivityState();
}

class _AllActivityState extends State<AllActivity> {
  String reference = '';
  DocumentReference docRef;

  @override
  void initState() {
    super.initState();
    setState(() {
      docRef = FirebaseFirestore.instance.doc(
          'collectors/${FirebaseAuth.instance.currentUser.uid.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder(
      stream: widget.type == 0
          ? FirebaseFirestore.instance
              .collection('recyclingRequests')
              .where('acceptedByCollector', isEqualTo: docRef)
              .orderBy('dateOfRequest')
              .snapshots()
          : FirebaseFirestore.instance
              .collection('recyclingRequests')
              .where('status', isEqualTo: widget.type)
              .where('acceptedByCollector', isEqualTo: docRef)
              .orderBy('dateOfRequest')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.data.documents.length == 0) {
            return Center(
              child: Text('No Activity Yet!'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                RequestModel model =
                    RequestModel.fromJson(snapshot.data.documents[index]);
                return ActivityItem(
                    requestModel: model,
                    docId: snapshot.data.documents[index].id,
                    requestSnapshot: snapshot.data.documents[index]);
              },
            );
          }
        }
      },
    ));
  }
}
