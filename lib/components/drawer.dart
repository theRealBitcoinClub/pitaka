import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
                    accountName: Text(snapshot.data['name']),
                    accountEmail: Text(snapshot.data['email']),
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
                  );
                }
              } else {
                return UserAccountsDrawerHeader(
                  accountEmail: Text(''),
                  accountName: Text(''),
                );
              }
            }),
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
      ],
    ),
  );
}
