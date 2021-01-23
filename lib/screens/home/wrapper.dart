import 'package:app/models/userAuthModel.dart' as usr;
import 'package:app/screens/authenticate/authenticate.dart';
import 'package:app/screens/authenticate/checkToken.dart';
import 'package:app/screens/authenticate/tokenCheckState.dart';
import 'package:app/screens/home/mainHome/home.dart';
import 'package:app/screens/loading/connecting.dart';
import 'package:app/screens/registration/registrationPage.dart';
import 'package:app/screens/registration/registrationState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  bool registeredBefore = false;

  bool userChecked = false;

  bool checkingUser = false;

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<usr.User>(context);

    final bool tokenChecked = Provider.of<TokenCheckState>(context).getTokenCheckState;

    final bool registered = Provider.of<RegistrationState>(context).getRegisteredState;

    if(user==null){
      return Authenticate();
    }else{
      //TODO:Fix this if's
      if(!tokenChecked){
        return CheckToken();
      }else{
        checkUserInfo().then((value) {
          setState(() {
            registeredBefore = value;
          });
          setState(() {
            checkingUser = true;
          });
        });

        if((registered || registeredBefore) && checkingUser){
          return Home();
        }else if((!registered || registeredBefore) && !checkingUser){
          return Connecting();
        }else{
          return RegistrationPage();
        }

      }
    }
  }

  Future<bool> checkUserInfo() async{
    var firebaseUser = FirebaseAuth.instance.currentUser;
    if(firebaseUser==null){
      setState(() {
        userChecked = true;
      });
      return false;
    }else{
      var result = await FirebaseFirestore.instance.collection('collectors').doc(firebaseUser.uid).get();
      setState(() {
        userChecked = true;
      });
      return result.exists;
    }
  }
}
