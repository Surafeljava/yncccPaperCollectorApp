import 'package:app/models/requestModel.dart';
import 'package:app/screens/home/mainHome/requestItemSingleView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActivityItem extends StatefulWidget {
  final RequestModel requestModel;
  final String docId;
  final QueryDocumentSnapshot requestSnapshot;
  ActivityItem(
      {@required this.requestModel,
      @required this.docId,
      @required this.requestSnapshot});

  @override
  _ActivityItemState createState() => _ActivityItemState();
}

class _ActivityItemState extends State<ActivityItem> {
  bool locationCalculated = false;
  String distance = '';
  String theLocationName = '';

  Future<String> getLocationInfo(LatLng locationPoint) async {
    var address = await Geocoder.local.findAddressesFromCoordinates(
        Coordinates(locationPoint.latitude, locationPoint.longitude));
    String theAddress = address.first.subLocality.toString() +
        ', ' +
        address.first.locality.toString();
    return theAddress;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationInfo(LatLng(widget.requestModel.placeOfPickup.latitude,
            widget.requestModel.placeOfPickup.longitude))
        .then((value) {
      setState(() {
        locationCalculated = true;
        theLocationName = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200],
            offset: Offset(1, 2),
            blurRadius: 8,
          )
        ],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .doc(widget.requestModel.fromUser.path)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Column(
                children: [
                  ListTile(
                    title: Text(snapshot.data['name']),
                    subtitle: locationCalculated
                        ? Text('$theLocationName')
                        : Text('Loading...'),
                    trailing: widget.requestModel.status == 1
                        ? Text(
                            'Pending',
                            style: TextStyle(color: Colors.red[600]),
                          )
                        : Text(
                            'Closed',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: [
                        Text('Requested on: '),
                        Text(
                          '${widget.requestModel.dateOfRequest.day}-${widget.requestModel.dateOfRequest.month}-${widget.requestModel.dateOfRequest.year}',
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_outlined,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RequestItemSingleView(
                                      docId: widget.docId,
                                      requestSnapshot: widget.requestSnapshot,
                                    )));
                          },
                        )
                      ],
                    ),
                  )
                ],
              );
            }
          }),
    );
  }
}
