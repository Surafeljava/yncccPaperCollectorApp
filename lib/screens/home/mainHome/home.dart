import 'package:app/screens/authenticate/tokenCheckState.dart';
import 'package:app/screens/registration/registrationState.dart';
import 'package:app/services/authService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  AuthService _authService = new AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: Text('LogOut'),
          onPressed: (){
            Provider.of<TokenCheckState>(context, listen: false).changeTokenCheckState(false);
            Provider.of<RegistrationState>(context, listen: false).changeRegistrationState(false);
            _authService.signOut();
          },
        ),
      ),
    );
  }
}
