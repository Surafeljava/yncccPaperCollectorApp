import 'package:app/models/requestModel.dart';
import 'package:app/screens/home/mainHome/mapState.dart';
import 'package:app/services/databaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spring_button/spring_button.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestItemView extends StatefulWidget {

  final RequestModel requestModel;
  final QueryDocumentSnapshot requestSnapshot;

  RequestItemView({this.requestModel, this.requestSnapshot});

  @override
  _RequestItemViewState createState() => _RequestItemViewState();
}

class _RequestItemViewState extends State<RequestItemView> {

  bool userGot = false;

  String location = '';

  DatabaseService _databaseService = new DatabaseService();

  bool locationCalculated = false;
  String distance = '';
  String theLocationName = '';

  Future<String> getLocationInfo(LatLng locationPoint) async{
    var address = await Geocoder.local.findAddressesFromCoordinates(Coordinates(locationPoint.latitude, locationPoint.longitude));
    String theAddress = address.first.subLocality.toString() + ', ' + address.first.locality.toString();
    return theAddress;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationInfo(LatLng(widget.requestModel.placeOfPickup.latitude, widget.requestModel.placeOfPickup.longitude)).then((value) {
      setState(() {
        locationCalculated = true;
        theLocationName = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.doc(widget.requestModel.fromUser.path).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.data==null){
            return Shimmer.fromColors(
              baseColor: Colors.grey[200],
              highlightColor: Colors.grey[100],
              enabled: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 100.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.0,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 80.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ListTile(
                title: Text(snapshot.data['name']),
                subtitle: locationCalculated ? Text('$theLocationName') : Text('Loading...'),
                leading: Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(snapshot.data['profilePictureURL']),
                      fit: BoxFit.cover
                    )
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      image: DecorationImage(
                        image: NetworkImage(widget.requestModel.photoURL),
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                  Column(
                    children: [
                      Text('Size~'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('${widget.requestModel.mass.toString()}', style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w600),),
                          Text('Kgs', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.location_on, color: Colors.redAccent, size: 25.0,),
                    onPressed: (){
                      final CameraPosition _myLocation = CameraPosition(
                          target: LatLng(widget.requestModel.placeOfPickup.latitude, widget.requestModel.placeOfPickup.longitude),
                          zoom: 16.2746,
                          tilt: 59.0123,
                      );
                      Provider.of<MapState>(context, listen: false).changeLocation(_myLocation);
                      Provider.of<MapState>(context, listen: false).addMarker(widget.requestModel.placeOfPickup, snapshot.data['name'], widget.requestModel.mass.toString(), false);
                      Provider.of<MapState>(context, listen: false).addPolyline(LatLng(widget.requestModel.placeOfPickup.latitude, widget.requestModel.placeOfPickup.longitude));
                    },
                  ),
                  SpringButton(
                    SpringButtonType.OnlyScale,
                    Container(
                      height: 35.0,
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.green,
                        gradient: LinearGradient(
                            colors: [
                              Color(0xFF85FF40),
                              Color(0xFF0CE69C)
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight
                        ),
                      ),
                      child: Center(child: Text('ACCEPT', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.0, color: Color(0xFF002E49)),)),
                    ),
                    onTap: () async{
                      await _databaseService.acceptTheRequest(widget.requestSnapshot.id);
                    },
                  ),
                ],
              ),

            ],
          );
        }
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
