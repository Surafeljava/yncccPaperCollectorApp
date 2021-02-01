import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState with ChangeNotifier{

  Completer<GoogleMapController> mapController = Completer();

  Set<Marker> markers = {};

  Set<Polyline> polyLines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  ///Polyline functions
  Set<Polyline> get getPolylines => polyLines;

  void addPolyline(LatLng to) async{
    polylineCoordinates = [];
    polyLines = {};
    LatLng from = markers.where((element) => element.markerId==MarkerId('Me')).elementAt(0).position;

    PolylineResult result = await polylinePoints?.getRouteBetweenCoordinates('AIzaSyD93vt4P82bDxJ99zcjnpyhaqJG2mubQ64', PointLatLng(from.latitude, from.longitude), PointLatLng(to.latitude, to.longitude));

    List<PointLatLng> resultPoints = result.points;

    if(resultPoints.isNotEmpty){
      resultPoints.forEach((PointLatLng point){
        polylineCoordinates.add(
            LatLng(point.latitude, point.longitude));
      });
    }

    Polyline polyline = Polyline(
        polylineId: PolylineId('path'),
        width: 5,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        color: Color(0xFF002E49),
        points: polylineCoordinates
    );

    polyLines.add(polyline);

    notifyListeners();

  }


  ///Marker Functions
  Set<Marker> get getMarkers => markers;

  void addMarker(GeoPoint point, String name, String mass, bool me) async{

    BitmapDescriptor pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        me ? 'assets/markers/pin.png' : 'assets/markers/pickPaperMarker.png');

    markers.add(Marker(
      markerId: me ? MarkerId(name) : MarkerId(LatLng(point.latitude, point.longitude).toString()),
      position: LatLng(point.latitude, point.longitude),
      infoWindow: InfoWindow(
          title: name,
          snippet: mass + 'Kg~',
          onTap: (){
            print('Hello');
          }
      ),
      icon: pinLocationIcon,
    ));
    notifyListeners();
  }

  ///Controller functions
  Completer<GoogleMapController> get getMapController => mapController;

  void addTheController(GoogleMapController controller){
    mapController.complete(controller);
    notifyListeners();
  }

  void changeLocation(CameraPosition _kLake) async{
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
    notifyListeners();
  }

}