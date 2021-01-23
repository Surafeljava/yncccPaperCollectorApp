import 'package:app/services/authService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spring_button/spring_button.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  AuthService _authService = new AuthService();

  bool error = false;
  String errorMessage = '';

  TextEditingController _phoneController;
  TextEditingController _otpController = new TextEditingController();

  String _phone = '';
  String _otp = '';

  bool verify = false;
  bool waitingSms = false;

  String _verificationId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _phoneController = new TextEditingController(
      text: '+251'
    );
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
                Text(verify ? 'VERIFY' : 'LOGIN', textAlign: TextAlign.center, style: TextStyle(fontSize: 30.0, color: Color(0xFF002E49), fontWeight: FontWeight.w600),),
                SizedBox(height: 25.0,),
                Text(verify ? 'Enter the OTP number sent to this number \n $_phone' : 'Login with your phone number', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0, color: Color(0x55002E49), fontWeight: FontWeight.w400),),
                SizedBox(height: 20.0,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    autofocus: false,
                    validator: (val) => val.isEmpty ? 'Empty Field' : null,
                    controller: verify ? _otpController : _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontSize: 20.0, color: Colors.black, letterSpacing: 2,),
                    onChanged: (val){
                      if(verify){
                        setState(() {
                          _otp = val;
                        });
                      }else{
                        setState(() {
                          _phone = val;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
                      hintText: verify ? 'OTP' : 'PHONE',
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

                SizedBox(height: 25.0,),

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
                        verify ? 'VERIFY' : 'CONTINUE',
                        style: TextStyle(color: Color(0xFF002E49), fontSize: 18, letterSpacing: 1.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  useCache: false,
                  onTap: (){

                    if(verify){
                      if(_otp.length<6){
                        setState(() {
                          error = true;
                          errorMessage = 'Enter the full OTP';
                        });
                      }else{
                        try{
                          _authService.signInWithOTP(_otp, _verificationId);
                        }catch(e){
                          setState(() {
                            error = true;
                            errorMessage = 'Wrong OTP';
                          });
                        }
                      }
                    }else{
                      if(_phone.length<=10){
                        setState(() {
                          error = true;
                          errorMessage = 'Enter a valid phone number';
                        });
                      }else{
                        setState(() {
                          error = false;
                          errorMessage = '';
                        });
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        setState(() {
                          waitingSms = true;
                        });

                        try{
                          verifyPhone();
                        }catch(e){
                          print('***************** ${e.toString()}');
                        }

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

          waitingSms ?
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black38,
          ) :
          Container(),

          waitingSms ?
          Center(
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
                  Text('Waiting...', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0, letterSpacing: 1.0),),
                  SizedBox(height: 15.0,),
                  SpinKitFadingCircle(
                    color: Color(0xFFD12043),
                    size: 40.0,
                  ),
                ],
              ),
            ),
          ) :
          Container(),
        ],
      ),
    );
  }


  //Phone Verification
  Future<void> verifyPhone() async {

    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      print('************ SIGNIN Function ************');
    };

    final PhoneVerificationFailed verificationfailed = (FirebaseAuthException authException) {
      print('**********: ${authException.message} :************');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this._verificationId = verId;
      setState(() {
        this.waitingSms = false;
        this.verify = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this._verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phone,
      timeout: const Duration(seconds: 20),
      verificationCompleted: verified,
      verificationFailed: verificationfailed,
      codeSent: smsSent,
      codeAutoRetrievalTimeout: autoTimeout,
    );

  }

}
