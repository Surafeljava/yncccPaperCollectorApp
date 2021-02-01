import 'package:flutter/foundation.dart';

class SenderUserModel{
  final DateTime dateOfSignUp;
  final String name;
  final String phone;
  final String profilePictureURL;
  final Map<String,dynamic> rating;
  final int totalRequestsAccepted;

  SenderUserModel({
    @required this.dateOfSignUp,
    @required this.name,
    @required this.phone,
    @required this.profilePictureURL,
    @required this.rating,
    @required this.totalRequestsAccepted,
  });

  factory SenderUserModel.fromJson(dynamic json){
    return SenderUserModel(
      dateOfSignUp: DateTime.fromMicrosecondsSinceEpoch(json['dateOfSignUp'].microsecondsSinceEpoch),
      name: json['name'],
      phone: json['phone'],
      profilePictureURL: json['profilePictureURL'],
      rating: json['rating'],
      totalRequestsAccepted: json['totalRequestsAccepted'],
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'dateOfSignUp': dateOfSignUp,
        'name': name,
        'phone': phone,
        'profilePictureURL': profilePictureURL,
        'rating': rating,
        'totalRequestsAccepted': totalRequestsAccepted,
      };
}