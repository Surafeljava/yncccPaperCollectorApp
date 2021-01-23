import 'package:flutter/foundation.dart';

class RegistrationState with ChangeNotifier{

  bool registered = false;

  bool get getRegisteredState => registered;

  void changeRegistrationState(bool reg){
    registered = reg;
    notifyListeners();
  }

}