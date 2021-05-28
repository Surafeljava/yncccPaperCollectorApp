import 'package:app/models/requestModel.dart';
import 'package:app/screens/home/mainHome/requestItemSingleView.dart';
import 'package:app/screens/home/mainHome/requestItemView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:spring_button/spring_button.dart';

class RequestsView extends StatefulWidget {
  @override
  _RequestsViewState createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> {
  PageController pageController = new PageController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('recyclingRequests')
                  .where('status', isEqualTo: 0)
                  .orderBy('dateOfRequest')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: double.infinity,
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(1, 2),
                              blurRadius: 10.0),
                        ]),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[200],
                      highlightColor: Colors.grey[100],
                      enabled: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 100.0,
                                height: 20.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 80.0,
                                height: 20.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Container(
                  height: MediaQuery.of(context).size.height * 0.28,
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.24,
                        width: double.infinity,
                        child: PageView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data.documents.length,
                          controller: pageController,
                          itemBuilder: (context, index) {
                            return SpringButton(
                              SpringButtonType.OnlyScale,
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                                padding: EdgeInsets.all(0.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black12,
                                          offset: Offset(1, 2),
                                          blurRadius: 10.0),
                                    ]),
                                child: RequestItemView(
                                  requestModel: RequestModel.fromJson(
                                      snapshot.data.documents[index]),
                                  requestSnapshot:
                                      snapshot.data.documents[index],
                                ),
                              ),
                              useCache: false,
                              scaleCoefficient: 0.95,
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => RequestItemSingleView(
                                          docId:
                                              snapshot.data.documents[index].id,
                                          requestSnapshot:
                                              snapshot.data.documents[index],
                                        )));
                              },
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: SmoothPageIndicator(
                          controller: pageController,
                          count: snapshot.data.documents.length,
                          axisDirection: Axis.horizontal,
                          effect: SlideEffect(
                              spacing: 8.0,
                              radius: 5.0,
                              dotWidth: 10.0,
                              dotHeight: 10.0,
                              paintStyle: PaintingStyle.fill,
                              strokeWidth: 0.0,
                              dotColor: Colors.grey,
                              activeDotColor: Colors.greenAccent),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      )
                    ],
                  ),
                );
              })
        ],
      ),
    );
  }
}
