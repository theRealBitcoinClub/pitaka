import 'package:flutter/material.dart';
import '../components/app.dart';

Drawer buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Text('Menu'),
          decoration: BoxDecoration(color: Colors.red),
        ),
        ListTile(
            title: Text('Dashboard'),
            onTap: () {
              Application.router.navigateTo(context, "/");
            }),
        ListTile(
            title: Text('Send'),
            onTap: () {
              Application.router.navigateTo(context, "/send");
            }),
        ListTile(
            title: Text('Receive'),
            onTap: () {
              Application.router.navigateTo(context, "/receive");
            })
      ],
    ),
  );
}
