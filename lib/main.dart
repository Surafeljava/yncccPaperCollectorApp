import 'package:app/screens/authenticate/tokenCheckState.dart';
import 'package:app/screens/home/mainHome/mapState.dart';
import 'package:app/screens/home/wrapper.dart';
import 'package:app/screens/registration/registrationState.dart';
import 'package:app/services/authService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider(
          create: (context) => AuthService().user,
        ),
        ChangeNotifierProvider(
          create: (context) => TokenCheckState(),
        ),
        ChangeNotifierProvider(
          create: (context) => RegistrationState(),
        ),
        ChangeNotifierProvider(
          create: (context) => MapState(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
        ),
        home: Wrapper(),
      ),
    );
  }
}
