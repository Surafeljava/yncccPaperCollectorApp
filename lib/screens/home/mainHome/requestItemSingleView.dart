import 'package:app/models/requestModel.dart';
import 'package:app/services/databaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spring_button/spring_button.dart';

class RequestItemSingleView extends StatefulWidget {

  final String docId;
  final QueryDocumentSnapshot requestSnapshot;

  RequestItemSingleView({@required this.docId, @required this.requestSnapshot});

  @override
  _RequestItemSingleViewState createState() => _RequestItemSingleViewState();
}

class _RequestItemSingleViewState extends State<RequestItemSingleView> {

  DatabaseService _databaseService = new DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text('Request View', style: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 1.0, fontSize: 20.0),),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('recyclingRequests').doc(widget.docId).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.data==null){
            return Center(
              child: CircularProgressIndicator(),
            );
          }else{
            RequestModel rModel = RequestModel.fromJson(snapshot.data);
            return Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height*0.3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(rModel.photoURL),
                      fit: BoxFit.cover
                    )
                  ),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.doc(rModel.fromUser.path).snapshots(),
                  builder: (context, snapshot2) {
                    if(snapshot2.data!=null){
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(snapshot2.data['name'], style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w500, letterSpacing: 1.0),),
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
                              child: Text(snapshot2.data['phone'], style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400, letterSpacing: 1.0),),
                            ),
                          ],
                        ),
                      );
                    }
                    return Container();
                  }
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text('Size', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, letterSpacing: 1.0, color: Colors.grey[400]),),
                  ),
                ),
                SizedBox(height: 5.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text('${rModel.mass} Kgs', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400, letterSpacing: 1.0),),
                  ),
                ),

                Spacer(),

                rModel.status == 0 ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpringButton(
                      SpringButtonType.OnlyScale,
                      Container(
                        height: 35.0,
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.green,
                          gradient: LinearGradient(
                              colors: [
                                Color(0xFF85FF40),
                                Color(0xFF0CE69C)
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight
                          ),
                        ),
                        child: Center(child: Text('ACCEPT', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.0, color: Color(0xFF002E49)),)),
                      ),
                      onTap: () async{
                        //Accept (change the status to 1)
                        await _databaseService.acceptTheRequest(widget.requestSnapshot.id);
                      },
                    ),
                  ],
                ) : rModel.status == 1 ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SpringButton(
                      SpringButtonType.OnlyScale,
                      Container(
                        height: 35.0,
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.green,
                          gradient: LinearGradient(
                              colors: [
                                Colors.grey[200],
                                Colors.grey[400]
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight
                          ),
                        ),
                        child: Center(child: Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.0, color: Color(0xFF002E49)),)),
                      ),
                      onTap: () async{
                        //Canceled (change the status to 0) remove the accepted by reference
                        await _databaseService.cancelRequest(widget.requestSnapshot.id);
                      },
                    ),
                    SpringButton(
                      SpringButtonType.OnlyScale,
                      Container(
                        height: 35.0,
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.green,
                          gradient: LinearGradient(
                              colors: [
                                Color(0xFF85FF40),
                                Color(0xFF0CE69C)
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight
                          ),
                        ),
                        child: Center(child: Text('PICKED UP', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1.0, color: Color(0xFF002E49)),)),
                      ),
                      onTap: () async{
                        //Picked Up (change the status to 2)
                        await _databaseService.pickUpRequest(widget.requestSnapshot.id);
                      },
                    ),
                  ],
                ) : (rModel.rating['rated'] && rModel.status >= 1) ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(rModel.rating['rating'].toString(), style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400, letterSpacing: 1.0),),
                    SizedBox(width: 5.0,),
                    Icon(rModel.rating['rating']==0 ? Icons.star_border : (rModel.rating['rating']>0 && rModel.rating['rating']<1) ? Icons.star_half : Icons.star, color: Colors.amber,),
                    Icon(rModel.rating['rating']<=1 ? Icons.star_border : (rModel.rating['rating']>1 && rModel.rating['rating']<2) ? Icons.star_half : Icons.star, color: Colors.amber,),
                    Icon(rModel.rating['rating']<=2 ? Icons.star_border : (rModel.rating['rating']>2 && rModel.rating['rating']<3) ? Icons.star_half : Icons.star, color: Colors.amber,),
                    Icon(rModel.rating['rating']<=3 ? Icons.star_border : (rModel.rating['rating']>3 && rModel.rating['rating']<4) ? Icons.star_half : Icons.star, color: Colors.amber,),
                    Icon(rModel.rating['rating']<=4 ? Icons.star_border : (rModel.rating['rating']>4 && rModel.rating['rating']<5) ? Icons.star_half : Icons.star, color: Colors.amber,),
                  ],
                ) : Container(
                  child: Text('Not Rated!', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400, letterSpacing: 1.0),),
                ),

                SpringButton(
                  SpringButtonType.OnlyScale,
                  ListTile(
                    title: Text('See Location', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, letterSpacing: 1.0),),
                    leading: Icon(Icons.location_on, color: Colors.grey[800],),
                  ),
                  onTap: (){
                    //Todo: see location on the map
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
