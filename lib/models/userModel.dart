import 'package:flutter/foundation.dart';

class UserModel{
  final DateTime dateOfSignUp;
  final String name;
  final String phone;
  final String profilePictureURL;
  final double rating;
  final int totalRequestsAccepted;

  UserModel({
    @required this.dateOfSignUp,
    @required this.name,
    @required this.phone,
    @required this.profilePictureURL,
    @required this.rating,
    @required this.totalRequestsAccepted,
  });

  factory UserModel.fromJson(dynamic json){
    return UserModel(
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