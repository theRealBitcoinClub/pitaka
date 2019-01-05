import 'package:flutter/material.dart';
import '../views/app.dart';

Drawer buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text("Joemar Taganna"),
          accountEmail: Text("joemar@paytaca.com"),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                ? Colors.blue
                : Colors.white,
            child: Text(
              "JT",
              style: TextStyle(fontSize: 40.0),
            ),
          ),
        ),
        ListTile(
            title: Text('Home'),
            trailing: Icon(Icons.home),
            onTap: () {
              Application.router.navigateTo(context, "/home");
            }),
        ListTile(
            title: Text('Send'),
            trailing: Icon(Icons.send),
            onTap: () {
              Application.router.navigateTo(context, "/send");
            }),
        ListTile(
            title: Text('Receive'),
            trailing: Icon(Icons.inbox),
            onTap: () {
              Application.router.navigateTo(context, "/receive");
            }),
        ListTile(
            title: Text('Register'),
            trailing: Icon(Icons.person_outline),
            onTap: () {
              Application.router.navigateTo(context, "/register");
            }),
        ListTile(
            title: Text('Terms and Conditions'),
            trailing: Icon(Icons.person_outline),
            onTap: () {
              Application.router.navigateTo(context, "/terms");
            }),
        ListTile(
            title: Text('Create Account'),
            trailing: Icon(Icons.person_outline),
            onTap: () {
              Application.router.navigateTo(context, "/account");
            })
      ],
    ),
  );
}
