import 'package:flutter/material.dart';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';

class ReceiveComponent extends StatefulWidget {
  @override
  ReceiveComponentState createState() => new ReceiveComponentState();
}

class ReceiveComponentState extends State<ReceiveComponent> {
  String path = "/receive";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Receive'),
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body: Center(child: Text("Receive")),
        bottomNavigationBar: buildBottomNavigation(context, path));
  }
}
