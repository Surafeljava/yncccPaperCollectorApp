import 'dart:io';

import 'package:app/models/userModel.dart';
import 'package:app/screens/registration/registrationState.dart';
import 'package:app/services/databaseService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:spring_button/spring_button.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {

  TextEditingController _nameController = new TextEditingController();

  String fullName = '';

  File _photo;
  bool _photoAdded = false;
  bool _imageGetClicked = false;
  bool _uploading = false;
  String _uploadingWhat = '';
  final picker = ImagePicker();

  bool error = false;
  String errorMessage = '';

  DatabaseService _databaseService = new DatabaseService();

  Future<bool> getImage(ImageSource src) async {
    final pickedFile = await picker.getImage(source: src);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        _photoAdded = true;
        return true;
      } else {
        print('No image selected.');
        return false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 1,),
                Text('CREATE ACCOUNT', textAlign: TextAlign.center, style: TextStyle(fontSize: 30.0, color: Color(0xFF002E49), fontWeight: FontWeight.w600),),
                SizedBox(height: 25.0,),
                Text('This user account will not be shared with other external applications or users', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0, color: Color(0x55002E49), fontWeight: FontWeight.w400),),
                SizedBox(height: 25.0,),

                SpringButton(
                  SpringButtonType.OnlyScale,
                  Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(60.0),
                    ),
                    child: _photoAdded ?
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60.0),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(_photo),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ) : Center(
                      child: Icon(Icons.camera_alt, color: Colors.grey[300], size: 25.0,),
                    ),
                  ),
                  useCache: false,
                  onTap: () {
                    setState(() {
                      _imageGetClicked = true;
                    });
                  },
                ),

                SizedBox(height: 25.0,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    autofocus: false,
                    validator: (val) => val.isEmpty ? 'Empty Field' : null,
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    style: TextStyle(fontSize: 20.0, color: Colors.black, letterSpacing: 2,),
                    onChanged: (val){
                      setState(() {
                        fullName = val;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
                      hintText: 'Full Name',
                      hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey[900],),
                      filled: true,
                      fillColor: Colors.grey[200],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(color: Colors.transparent, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(color: Colors.transparent, width: 2.0),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 15.0,),

                error ? Center(child: Text( errorMessage, style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w400, fontSize: 17.0, letterSpacing: 1.0),)) : Container(),

                Spacer(flex: 1,),

                SpringButton(
                  SpringButtonType.OnlyScale,
                  Container(
                    width: MediaQuery.of(context).size.width/1.2,
                    height: 50.0,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Color(0xFF85FF40),
                              Color(0xFF0CE69C)
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight
                        ),
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    child: Center(
                      child:
                      Text(
                        'CREATE',
                        style: TextStyle(color: Color(0xFF002E49), fontSize: 18, letterSpacing: 1.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  useCache: false,
                  onTap: () async{
                    //Register the User

                    if(_nameController.text.isEmpty){
                      setState(() {
                        error = true;
                        errorMessage = 'Write your name';
                      });
                    }else{
                      //set the uploading var true
                      //set the _uploadingWhat var 'photo'
                      setState(() {
                        _uploading = true;
                        _uploadingWhat = 'Profile Picture';
                      });

                      //Upload Picture
                      String _uid = FirebaseAuth.instance.currentUser.uid.toString();
                      String profileUrl = await _databaseService.uploadProfileImage(_photo, _uid);
                      print(profileUrl);

                      //set the uploading var true
                      //set the _uploadingWhat var 'User Information'
                      setState(() {
                        _uploading = true;
                        _uploadingWhat = 'User Information';
                      });


                      var rating = {'1':0,'2':0, '3':0, '4':0, '5':0, 'ratedTimes':0, 'rating':0.0};

                      //Create UserModel
                      UserModel myModel = new UserModel(dateOfSignUp: DateTime.now(), name: _nameController.text, phone: FirebaseAuth.instance.currentUser.phoneNumber.toString(), profilePictureURL: profileUrl, rating: rating, totalRequestsAccepted: 0);


                      //Upload User data to the database
                      await _databaseService.addNewUser(myModel, _uid);

                      //Set the uploading var false
                      //set the _uploadingWhat var ''
                      setState(() {
                        _uploading = false;
                        _uploadingWhat = '';
                      });

                      //change the registration state
                      Provider.of<RegistrationState>(context, listen: false).changeRegistrationState(true);

                    }

                  },
                ),

                SizedBox(height: 20.0,),

                Text('Terms and Conditions', textAlign: TextAlign.center, style: TextStyle(fontSize: 17.0, color: Color(0x88002E49), fontWeight: FontWeight.w400),),
                SizedBox(height: 10.0,),

              ],
            ),
          ),

          _uploading ?
          Container(
            color: Colors.black38,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width/2,
                height: MediaQuery.of(context).size.width/2,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_uploadingWhat, style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16.0, letterSpacing: 1.0),),
                    SizedBox(height: 15.0,),
                    SpinKitFadingCircle(
                      color: Color(0xFFD12043),
                      size: 40.0,
                    ),
                  ],
                ),
              ),
            ),
          ) :
          Container(),

          //The Choose Picture UI
          _imageGetClicked && !_uploading ? Container(
            color: Colors.black38,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width/1.5,
                height: MediaQuery.of(context).size.width/1.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  children: [
                    FlatButton(
                      child: Icon(Icons.close, color: Colors.redAccent,),
                      onPressed: (){
                        setState(() {
                          _imageGetClicked = false;
                        });
                      },
                    ),
                    SizedBox(height: 10.0,),

                    Center(
                      child: SpringButton(
                        SpringButtonType.OnlyScale,
                        Container(
                          width: (MediaQuery.of(context).size.width/1.5)-30.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          child: Center(
                            child:
                            Text(
                              'Camera',
                              style: TextStyle(color: Colors.grey[800], fontSize: 18, letterSpacing: 0.0, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        useCache: false,
                        onTap: () async{
                          getImage(ImageSource.camera).then((value){
                            print('Image get Result: $value');
                          });
                          setState(() {
                            _imageGetClicked = false;
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 10.0,),

                    Center(
                      child: SpringButton(
                        SpringButtonType.OnlyScale,
                        Container(
                          width: (MediaQuery.of(context).size.width/1.5)-30.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          child: Center(
                            child:
                            Text(
                              'Gallery',
                              style: TextStyle(color: Colors.grey[800], fontSize: 18, letterSpacing: 0.0, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        useCache: false,
                        onTap: () {
                          getImage(ImageSource.gallery).then((value){
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
          ) : !_imageGetClicked && _uploading ?
          Container(
            color: Colors.black38,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width/1.6,
                height: MediaQuery.of(context).size.width/1.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('uploading...', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22.0, letterSpacing: 0.0, color: Colors.grey[800]),),
                    SizedBox(height: 15.0,),
                    SpinKitFadingCircle(
                      color: Color(0xFFD12043),
                      size: 40.0,
                    ),
                  ],
                ),
              ),
            ),
          ) : Container(),

        ],
      ),
    );
  }
}
