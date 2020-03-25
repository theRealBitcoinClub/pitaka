import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../views/app.dart';


Future<Map> getUserDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var firstName = prefs.getString('firstName');
  var lastName = prefs.getString('lastName');
  var user = {
    'name': '$firstName $lastName',
    'initials': '${firstName[0]}${lastName[0]}'.toUpperCase(),
    'email': prefs.getString('email')
  };
  return user;
}

Drawer buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        FutureBuilder(
          future: getUserDetails(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return Container(
                  height: 250.0,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.red,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new CircleAvatar(
                              backgroundColor: Colors.white,
                              maxRadius: 35.0,
                              child: Text(
                                snapshot.data['initials'],
                                style: TextStyle(fontSize: 40.0),
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  snapshot.data['name'],
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '0917 606 6774',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                )
                              ]
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                Icons.keyboard_arrow_right,
                                size: 35.0,
                                color: Colors.white,
                              ),
                            ),
                          ]
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Text(
                            //   "View Benefits",
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontSize: 12.0,
                            //   ),
                            // ),
                            // FlatButton(
                            //   textColor: Colors.white,
                            //   padding: EdgeInsets.all(2.0),
                            //   onPressed: () {
                            //     /*...*/
                            //   },
                            //   child: Text(
                            //     "View Benefits",
                            //     style: TextStyle(fontSize: 12.0),
                            //   ),
                            // ),

                            OutlineButton(
                              onPressed: () {
                                /*...*/
                              },
                              borderSide: BorderSide(
                                color: Colors.white
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                              ),
                              padding: EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 1.0),
                              child: Text(
                                "View Benefits",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                StepProgressIndicator(
                                  totalSteps: 3,
                                  currentStep: 1,
                                  size: 30,
                                  selectedColor: Colors.black,
                                  unselectedColor: Colors.grey[200],
                                  customStep: (index, color, _) => color == Colors.black
                                  ? Container(
                                      color: color,
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                  )
                                  : Container(
                                      color: color,
                                      child: Icon(
                                        Icons.remove,
                                      ),
                                  ),
                                )
                              ]
                            )
                          ]
                        )
                      ]
                    )
                  )
                );
              }
            } else {
              return UserAccountsDrawerHeader(
                accountEmail: Text(''),
                accountName: Text(''),
              );
            }
            return Container();
          }
        ),
        ListTile(
          title: Text('Accounts'),
          trailing: Icon(Icons.account_balance_wallet),
          onTap: () {
            Application.router.navigateTo(context, "/home");
        }),
        ListTile(
          title: Text('Pay'),
          trailing: Icon(Icons.send),
          onTap: () {
            Application.router.navigateTo(context, "/send");
        }),
        ListTile(
          title: Text('QR Code'),
          trailing: Icon(Icons.inbox),
          onTap: () {
            Application.router.navigateTo(context, "/receive");
        }),
        ListTile(
          title: Text('Create Account'),
          trailing: Icon(Icons.person_outline),
          onTap: () {
            Application.router.navigateTo(context, "/addAccount");
        }),
        ListTile(
          title: Text('Aunthenticate'),
          trailing: Icon(Icons.person_pin),
          onTap: () {
            Application.router.navigateTo(context, "/authenticate");
        }),
        ListTile(
          title: Text('Contact List'),
          trailing: Icon(Icons.contacts),
          onTap: () {
            Application.router.navigateTo(context, "/contactlist");
        }),
      ],
    ),
  );
}
