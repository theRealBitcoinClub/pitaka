import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/app.dart';


Future<Map> getUserDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var level2 = (prefs.getBool('level2') ?? false);
  var level3 = (prefs.getBool('level3') ?? false);
  var firstName = prefs.getString('firstName');
  var lastName = prefs.getString('lastName');
  var mobileNumber = prefs.getString('mobileNumber');
  var mobileNumPart1 = mobileNumber.substring(3, 6);
  var mobileNumPart2 = mobileNumber.substring(6, 9);
  var mobileNumPart3 = mobileNumber.substring(9);
  var user = {
    'name': '$firstName $lastName',
    'initials': '${firstName[0]}${lastName[0]}'.toUpperCase(),
    'mobile_number': '0$mobileNumPart1 $mobileNumPart2 $mobileNumPart3',
    'level2': level2,
    'level3': level3
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
                  height: 230.0,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  snapshot.data['name'],
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                new SizedBox(
                                  height: 8.0,
                                ),
                                Text(
                                  snapshot.data['mobile_number'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                )
                              ]
                            ),
                            GestureDetector(
                              onTap: () {
                                Application.router.navigateTo(context, "/userprofile");
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 30.0,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ]
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            OutlineButton(
                              onPressed: () {
                                Application.router.navigateTo(context, "/verificationlevels");
                              },
                              borderSide: BorderSide(
                                color: Colors.white
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                              ),
                              padding: EdgeInsets.fromLTRB(6.0, 1.0, 6.0, 1.0),
                              child: Text(
                                "View Benefits",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 6.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  maxRadius: 10.0,
                                  child: Icon(
                                    Icons.check,
                                    size: 16.0,
                                    color: Colors.red,
                                  ),
                                ),
                                Expanded(
                                    child: Divider(
                                      color: Colors.white,
                                      thickness: 3.0,
                                    )
                                ),
                                snapshot.data['level2'] ?
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    maxRadius: 10.0,
                                    child: Icon(
                                      Icons.check,
                                      size: 16.0,
                                      color: Colors.red,
                                    ),
                                  )
                                :
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    maxRadius: 10.0,
                                  ),
                                Expanded(
                                    child: Divider(
                                      color: Colors.white,
                                      thickness: 3.0,
                                    )
                                ),
                                snapshot.data['level3'] ?
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    maxRadius: 10.0,
                                    child: Icon(
                                      Icons.check,
                                      size: 16.0,
                                      color: Colors.red,
                                    ),
                                  )
                                :
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    maxRadius: 10.0,
                                  ),
                              ]
                            ),
                            new SizedBox(
                              height: 5.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Level 1",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.0,
                                  )
                                ),
                                Text(
                                  "Level 2",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.0,
                                  )
                                ),
                                Text(
                                  "Level 3",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.0,
                                  )
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
