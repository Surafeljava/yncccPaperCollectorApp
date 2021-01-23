import 'package:app/screens/authenticate/tokenCheckState.dart';
import 'package:app/services/databaseService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_button/spring_button.dart';

class CheckToken extends StatefulWidget {
  @override
  _CheckTokenState createState() => _CheckTokenState();
}

class _CheckTokenState extends State<CheckToken> {

  bool error = false;
  String errorMessage = '';

  TextEditingController _tokenTextController = new TextEditingController();

  String token = '';

  DatabaseService _databaseService = new DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 1,),
            Text('Are you YNCCC \nMember?', textAlign: TextAlign.center, style: TextStyle(fontSize: 30.0, color: Color(0xFF002E49), fontWeight: FontWeight.w600),),
            SizedBox(height: 25.0,),
            Text('Enter the temporary Token given by YNCCC', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0, color: Color(0x55002E49), fontWeight: FontWeight.w400),),
            SizedBox(height: 20.0,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextFormField(
                autofocus: false,
                validator: (val) => val.isEmpty ? 'Empty Field' : null,
                controller: _tokenTextController,
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: 20.0, color: Colors.black, letterSpacing: 2,),
                onChanged: (val){
                  setState(() {
                    token = val;
                  });
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
                  hintText: 'TOKEN',
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


            SizedBox(height: 40.0,),

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
                    'CONTINUE',
                    style: TextStyle(color: Color(0xFF002E49), fontSize: 18, letterSpacing: 1.0, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              useCache: false,
              onTap: () async{
                //Check if the token field is not empty
                if(_tokenTextController.text.isEmpty){
                  setState(() {
                    error = true;
                    errorMessage = 'Enter the Token!';
                  });
                }else{
                  //check if the Token is true then go to SignUp
                  bool checked = await _databaseService.checkToken(_tokenTextController.text);

                  if(checked){
                    Provider.of<TokenCheckState>(context, listen: false).changeTokenCheckState(true);
                  }else{
                    setState(() {
                      error = true;
                      errorMessage = 'Invalid Token!';
                    });
                  }
                }
              },
            ),

            Spacer(flex: 2,),

            Text('Terms and Conditions', textAlign: TextAlign.center, style: TextStyle(fontSize: 17.0, color: Color(0x88002E49), fontWeight: FontWeight.w400),),
            SizedBox(height: 10.0,)

          ],
        ),
      ),
    );
  }
}
