import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RequestModel{
  final DocumentReference acceptedByCollector;
  final DateTime dateOfAcceptance;
  final DateTime dateOfRequest;
  final DocumentReference fromUser;
  final int mass;
  final String photoURL;
  final GeoPoint placeOfPickup;
  final Map<String,dynamic> rating;
  final int status;

  RequestModel({
    @required this.acceptedByCollector,
    @required this.dateOfAcceptance,
    @required this.dateOfRequest,
    @required this.fromUser,
    @required this.mass,
    @required this.photoURL,
    @required this.placeOfPickup,
    @required this.rating,
    @required this.status,
  });

  factory RequestModel.fromJson(dynamic json){
    return RequestModel(
      acceptedByCollector: json['acceptedByCollector']== null ? null : json['acceptedByCollector'],
      dateOfAcceptance: json['dateOfAcceptance']== null ? null : DateTime.fromMicrosecondsSinceEpoch(json['dateOfAcceptance'].microsecondsSinceEpoch),
      dateOfRequest: DateTime.fromMicrosecondsSinceEpoch(json['dateOfRequest'].microsecondsSinceEpoch),
      fromUser: json['fromUser'],
      mass: json['mass'],
      photoURL: json['photoURL'],
      placeOfPickup: json['placeOfPickup'],
      rating: json['rating'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'acceptedByCollector': acceptedByCollector,
        'dateOfAcceptance': dateOfAcceptance,
        'dateOfRequest': dateOfRequest,
        'fromUser': fromUser,
        'mass': mass,
        'photoURL': photoURL,
        'placeOfPickup': placeOfPickup,
        'rating': rating,
        'status': status,
      };
}