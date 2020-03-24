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
                return UserAccountsDrawerHeader(
                  accountName: Text(
                    snapshot.data['name'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text('0917 606 6774'),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? Colors.blue
                            : Colors.white,
                    child: Text(
                      snapshot.data['initials'],
                      style: TextStyle(fontSize: 40.0),
                    ),
                  ),
                  otherAccountsPictures: <Widget>[
                    StepProgressIndicator(
                        totalSteps: 6,
                        currentStep: 4,
                        size: 36,
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
                  ],
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
