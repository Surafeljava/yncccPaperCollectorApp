import 'package:flutter/foundation.dart';

class TokenCheckState with ChangeNotifier{

  bool tokenChecked = false;

  bool get getTokenCheckState => tokenChecked;

  void changeTokenCheckState(bool checked){
    tokenChecked = checked;
    notifyListeners();
  }

}