import 'package:app/screens/home/myActivities/allActivity.dart';
import 'package:flutter/material.dart';

class MyActivities extends StatefulWidget {
  @override
  _MyActivitiesState createState() => _MyActivitiesState();
}

class _MyActivitiesState extends State<MyActivities> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          'Activities',
          style: TextStyle(
              fontWeight: FontWeight.w400, letterSpacing: 1.0, fontSize: 20.0),
        ),
      ),
      body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      getTabButton('All', 0),
                      Spacer(
                        flex: 1,
                      ),
                      getTabButton('Pending', 1),
                      Spacer(
                        flex: 1,
                      ),
                      getTabButton('Closed', 2),
                      Spacer(
                        flex: 4,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: selected == 0
                    ? AllActivity(
                        type: 0,
                      )
                    : selected == 1
                        ? AllActivity(
                            type: 1,
                          )
                        : AllActivity(
                            type: 2,
                          ),
              ),
            ],
          )),
    );
  }

  Widget getTabButton(String title, int index) {
    return TextButton(
      child: Text(
        '$title',
        style: TextStyle(
            color: selected == index ? Colors.green[300] : Colors.grey[400],
            fontSize: selected == index ? 17 : 16,
            letterSpacing: 0.5,
            fontWeight: selected == index ? FontWeight.w600 : FontWeight.w400),
      ),
      onPressed: () {
        setState(() {
          selected = index;
        });
      },
    );
  }
}
