import 'dart:async';

import 'package:app/screens/home/mainHome/mapState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class MapViewHome extends StatefulWidget {

  final List<CameraPosition> listOfCameraPositions;
  MapViewHome({this.listOfCameraPositions});

  @override
  _MapViewHomeState createState() => _MapViewHomeState();
}

class _MapViewHomeState extends State<MapViewHome> {

  Location _location = Location();

//  static final CameraPosition _myLocation = CameraPosition(
//    target: LatLng(9.005411, 38.763621),
//    zoom: 14.4746,
//    tilt: 59.0123
//  );

  PermissionStatus _permissionGranted;

  LatLng _initialcameraposition = LatLng(9.005411, 38.763621);

  @override
  void initState() {
    super.initState();

    _location.hasPermission().then((value) {
      setState(() {
        _permissionGranted = value;
      });
    });
    if (_permissionGranted == PermissionStatus.denied) {
      _location.requestPermission().then((value){
        _permissionGranted = value;
      });
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        markers: Provider.of<MapState>(context).getMarkers,
        polylines: Provider.of<MapState>(context).getPolylines,
        initialCameraPosition: CameraPosition(target: _initialcameraposition, zoom: 15.0),
        onMapCreated: (GoogleMapController controller) {
          Provider.of<MapState>(context, listen: false).addTheController(controller);
          _location.onLocationChanged.listen((event) {
//            Provider.of<MapState>(context, listen: false).changeLocation(CameraPosition(target: LatLng(event.latitude, event.longitude), zoom: 15.0));
            Provider.of<MapState>(context, listen: false).addMarker(GeoPoint(event.latitude, event.longitude), 'Me', '0', true);
            //Todo: calculate and change every time the selected request location

          });
        },
      ),
    );
  }
}
