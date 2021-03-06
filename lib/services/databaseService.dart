import 'dart:io';

import 'package:app/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart' as fbStore;

class DatabaseService with ChangeNotifier{

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('collectors');

  Future<void> checkRegistered() async{
    var firebaseUser = FirebaseAuth.instance.currentUser;
    var result = await firestoreInstance.collection('collectors').doc(firebaseUser.uid).get();
    return UserModel.fromJson(result);
  }

  Future<String> uploadProfileImage(File image, String name) async {

    fbStore.Reference ref = fbStore.FirebaseStorage.instance.ref('profilePictures/$name');
    fbStore.TaskSnapshot uploadTask = await ref.putFile(image);

    final String downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;

  }

  Future<bool> checkToken(String token) async{
    List<dynamic> tokens = [];

    //get all the available tokens
    var result = await firestoreInstance.collection('token').doc('yncccToken').get();
    tokens = result['tokens'];
    print('******** $tokens');

    //check if the given token is in the available tokens list
    //if true remove that token and return true
    //if false return false
    for (dynamic i in tokens){
      if(token==i.toString()){
        await firestoreInstance.collection('token').doc('yncccToken').update({'tokens': FieldValue.arrayRemove([i])});
        return true;
      }
    }

    return false;
  }

  Future<void> addNewUser(UserModel _userModel, String _uid) async {
    await userCollection.doc(_uid).set(_userModel.toJson());
  }

  Future<void> updateUser(String userName, String photoUrl) async{
    String _uid = FirebaseAuth.instance.currentUser.uid.toString();
    await firestoreInstance.doc('collectors/$_uid').update({'name': userName, 'profilePictureURL': photoUrl});
  }

  Future<UserModel> getMyInfo() async{
    String _uid = FirebaseAuth.instance.currentUser.uid.toString();
    var result = await firestoreInstance.collection('collectors').doc(_uid).get();
    return UserModel.fromJson(result);
  }


  //Accept the request
  Future<void> acceptTheRequest(String docId) async{
    String _uid = FirebaseAuth.instance.currentUser.uid.toString();
    DocumentReference reference = firestoreInstance.doc('collectors/$_uid');
    await firestoreInstance.doc('recyclingRequests/$docId').update({'status': 1, 'dateOfAcceptance': DateTime.now(), 'acceptedByCollector': reference});
    await firestoreInstance.doc('collectors/$_uid').update({'totalRequestsAccepted': FieldValue.increment(1)});
  }

  //Cancel a Request
  Future<void> cancelRequest(String docId) async{
    await firestoreInstance.doc('recyclingRequests/$docId').update({'status': 0, 'dateOfAcceptance': null, 'acceptedByCollector': null});
  }

  //Pick up the request
  Future<void> pickUpRequest(String docId) async{
    await firestoreInstance.doc('recyclingRequests/$docId').update({'status': 2});
  }

}