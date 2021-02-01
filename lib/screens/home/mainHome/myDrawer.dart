import 'package:app/models/userModel.dart';
import 'package:app/screens/authenticate/tokenCheckState.dart';
import 'package:app/screens/home/myActivities/editProfile.dart';
import 'package:app/screens/home/myActivities/myActivities.dart';
import 'package:app/screens/registration/registrationState.dart';
import 'package:app/services/authService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_button/spring_button.dart';

class MyDrawer extends StatefulWidget {

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  AuthService _authService = new AuthService();

  String uid = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      uid = FirebaseAuth.instance.currentUser.uid.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.doc('collectors/${FirebaseAuth.instance.currentUser.uid.toString()}').snapshots(),
        builder: (context, snapshot) {
          if(snapshot.data==null){
            return Center(
              child: CircularProgressIndicator(),
            );
          }else{
            UserModel user = UserModel.fromJson(snapshot.data);
            return Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 250.0,
                  margin: EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(user.profilePictureURL),
                          fit: BoxFit.cover
                      )
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(user.name, style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w500, letterSpacing: 1.0),),
                      ),

                      SizedBox(
                        height: 10.0,
                      ),

                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text('Phone', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, letterSpacing: 1.0, color: Colors.grey[400]),),
                      ),
                      SizedBox(height: 5.0,),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(user.phone, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400, letterSpacing: 1.0),),
                      ),

                      SizedBox(height: 15.0,),

                      Container(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text('Rating', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, letterSpacing: 1.0, color: Colors.grey[400]),),
                            SizedBox(width: 5.0,),
                            Text('(${user.rating['ratedTimes'].toString()})', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, letterSpacing: 1.0, color: Colors.grey[600]),),
                          ],
                        ),
                      ),

                      SizedBox(height: 5.0,),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(user.rating['rating'].toString(), style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400, letterSpacing: 1.0),),
                            SizedBox(width: 5.0,),
                            Icon(user.rating['rating']==0 ? Icons.star_border : (user.rating['rating']>0 && user.rating['rating']<1) ? Icons.star_half : Icons.star, color: Colors.amber,),
                            Icon(user.rating['rating']<=1 ? Icons.star_border : (user.rating['rating']>1 && user.rating['rating']<2) ? Icons.star_half : Icons.star, color: Colors.amber,),
                            Icon(user.rating['rating']<=2 ? Icons.star_border : (user.rating['rating']>2 && user.rating['rating']<3) ? Icons.star_half : Icons.star, color: Colors.amber,),
                            Icon(user.rating['rating']<=3 ? Icons.star_border : (user.rating['rating']>3 && user.rating['rating']<4) ? Icons.star_half : Icons.star, color: Colors.amber,),
                            Icon(user.rating['rating']<=4 ? Icons.star_border : (user.rating['rating']>4 && user.rating['rating']<5) ? Icons.star_half : Icons.star, color: Colors.amber,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.0,),

                SpringButton(
                  SpringButtonType.OnlyScale,
                  ListTile(
                    title: Text('Edit Profile', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, letterSpacing: 1.0),),
                    leading: Icon(Icons.edit, color: Colors.grey[800],),
                  ),
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditProfile(uid: uid,)));
                  },
                ),

                SpringButton(
                  SpringButtonType.OnlyScale,
                  ListTile(
                    title: Text('My Activities', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, letterSpacing: 1.0),),
                    subtitle: Text('2 UnPicked', style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, letterSpacing: 1.0, color: Colors.redAccent),),
                    leading: Icon(Icons.pending_actions, color: Colors.grey[800],),
                  ),
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyActivities()));
                  },
                ),

                Spacer(),

                ListTile(
                  title: Text('LogOut', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, letterSpacing: 1.0),),
                  leading: Icon(Icons.logout, color: Colors.grey[800],),
                  onTap: (){
                    Provider.of<TokenCheckState>(context, listen: false).changeTokenCheckState(false);
                    Provider.of<RegistrationState>(context, listen: false).changeRegistrationState(false);
                    _authService.signOut();
                  },
                ),
              ],
            );
          }
        }
      ),
    );
  }
}
