import 'dart:io';

import 'package:app/models/userModel.dart';
import 'package:app/screens/registration/registrationState.dart';
import 'package:app/services/databaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:spring_button/spring_button.dart';

class EditProfile extends StatefulWidget {
  final String uid;

  EditProfile({this.uid});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _nameController = new TextEditingController();

  String fullName = '';

  String _photoURL;
  File _photo;
  bool _imageGetClicked = false;
  bool _uploading = false;
  String _uploadingWhat = '';
  final picker = ImagePicker();

  bool error = false;
  String errorMessage = '';

  DatabaseService _databaseService = new DatabaseService();

  Future<bool> getImage(ImageSource src) async {
    final pickedFile = await picker.getImage(source: src);
    if (pickedFile == null) {
      print('*********** Hereeeee');
    }
    if (pickedFile.path.toString().isNotEmpty) {
      setState(() {
        _photo = File(pickedFile.path);
      });
      return true;
    } else {
      print('No image selected.');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          'Edit Profile',
          style: TextStyle(
              fontWeight: FontWeight.w400, letterSpacing: 1.0, fontSize: 20.0),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .doc('collectors/${widget.uid}')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              UserModel user = UserModel.fromJson(snapshot.data);
              return Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 25.0,
                        ),
                        Text(
                          'This user account will not be shared with other external applications or users',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Color(0x55002E49),
                              fontWeight: FontWeight.w400),
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'NEW',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xFF002E49),
                                      fontWeight: FontWeight.w400),
                                ),
                                SpringButton(
                                  SpringButtonType.OnlyScale,
                                  Container(
                                      width: 80.0,
                                      height: 80.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius:
                                            BorderRadius.circular(60.0),
                                      ),
                                      child: _photo == null
                                          ? Container(
                                              child: Center(
                                                child: Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(60.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: FileImage(_photo),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            )),
                                  useCache: false,
                                  onTap: () {
                                    setState(() {
                                      _imageGetClicked = true;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Icon(Icons.arrow_forward),
                            SizedBox(
                              width: 5.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'OLD',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xFF002E49),
                                      fontWeight: FontWeight.w400),
                                ),
                                Container(
                                    width: 80.0,
                                    height: 80.0,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(60.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                user.profilePictureURL),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 5.0),
                          child: Row(
                            children: [
                              Text(
                                'Previously: ',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color(0xFF002E49),
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                user.name,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Color(0xFF002E49),
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextFormField(
                            autofocus: false,
                            validator: (val) =>
                                val.isEmpty ? 'Empty Field' : null,
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                              letterSpacing: 2,
                            ),
                            onChanged: (val) {
                              setState(() {
                                fullName = val;
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 20.0, right: 20.0, top: 10),
                              hintText: 'New Name',
                              hintStyle: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[900],
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 2.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 2.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        error
                            ? Center(
                                child: Text(
                                errorMessage,
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 17.0,
                                    letterSpacing: 1.0),
                              ))
                            : Container(),
                        Spacer(
                          flex: 4,
                        ),
                        SpringButton(
                          SpringButtonType.OnlyScale,
                          Container(
                            width: MediaQuery.of(context).size.width / 1.2,
                            height: 50.0,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF85FF40),
                                      Color(0xFF0CE69C)
                                    ],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight),
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Center(
                              child: Text(
                                'UPDATE',
                                style: TextStyle(
                                    color: Color(0xFF002E49),
                                    fontSize: 18,
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          useCache: false,
                          onTap: () async {
                            //Register the User

                            if (_nameController.text.isEmpty) {
                              setState(() {
                                error = true;
                                errorMessage = 'Write your name';
                              });
                            } else {
                              String profileUrl = '';
                              if (_photo != null) {
                                //set the uploading var true
                                //set the _uploadingWhat var 'photo'
                                setState(() {
                                  _uploading = true;
                                  _uploadingWhat = 'Profile Picture';
                                });

                                //Upload Picture
                                String _uid = FirebaseAuth
                                    .instance.currentUser.uid
                                    .toString();
                                profileUrl = await _databaseService
                                    .uploadProfileImage(_photo, _uid);

                                //set the uploading var true
                                //set the _uploadingWhat var 'User Information'
                                setState(() {
                                  _uploading = true;
                                  _uploadingWhat = 'User Information';
                                });
                              }

                              //Upload User data to the database
                              await _databaseService.updateUser(
                                  _nameController.text.isEmpty
                                      ? user.name
                                      : _nameController.text,
                                  _photo == null
                                      ? user.profilePictureURL
                                      : profileUrl);

                              //Set the uploading var false
                              //set the _uploadingWhat var ''
                              setState(() {
                                _uploading = false;
                                _uploadingWhat = '';
                              });

                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                  ),

                  _uploading
                      ? Container(
                          color: Colors.black38,
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              height: MediaQuery.of(context).size.width / 2,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _uploadingWhat,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16.0,
                                        letterSpacing: 1.0),
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  SpinKitFadingCircle(
                                    color: Color(0xFFD12043),
                                    size: 40.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(),

                  //The Choose Picture UI
                  _imageGetClicked && !_uploading
                      ? Container(
                          color: Colors.black38,
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.5,
                              height: MediaQuery.of(context).size.width / 1.5,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Column(
                                children: [
                                  TextButton(
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _imageGetClicked = false;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Center(
                                    child: SpringButton(
                                      SpringButtonType.OnlyScale,
                                      Container(
                                        width:
                                            (MediaQuery.of(context).size.width /
                                                    1.5) -
                                                30.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: Center(
                                          child: Text(
                                            'Camera',
                                            style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 18,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      useCache: false,
                                      onTap: () async {
                                        getImage(ImageSource.camera)
                                            .then((value) {
                                          print('Image get Result: $value');
                                        });
                                        setState(() {
                                          _imageGetClicked = false;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Center(
                                    child: SpringButton(
                                      SpringButtonType.OnlyScale,
                                      Container(
                                        width:
                                            (MediaQuery.of(context).size.width /
                                                    1.5) -
                                                30.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: Center(
                                          child: Text(
                                            'Gallery',
                                            style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 18,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      useCache: false,
                                      onTap: () {
                                        getImage(ImageSource.gallery)
                                            .then((value) {
                                          print('Image get Result: $value');
                                        });
                                        setState(() {
                                          _imageGetClicked = false;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : !_imageGetClicked && _uploading
                          ? Container(
                              color: Colors.black38,
                              child: Center(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.6,
                                  height:
                                      MediaQuery.of(context).size.width / 1.6,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'uploading...',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 22.0,
                                            letterSpacing: 0.0,
                                            color: Colors.grey[800]),
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      SpinKitFadingCircle(
                                        color: Color(0xFFD12043),
                                        size: 40.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                ],
              );
            }
          }),
    );
  }
}
