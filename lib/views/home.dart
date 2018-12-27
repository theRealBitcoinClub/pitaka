import 'package:flutter/material.dart';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';

class HomeComponent extends StatefulWidget {
  @override
  State createState() => new HomeComponentState();
}

class HomeComponentState extends State<HomeComponent> {
  String path = "/home";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Paytaca'),
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body: Center(
            child: new Container(
                child: new SingleChildScrollView(
                    child: new ConstrainedBox(
          constraints: new BoxConstraints(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Text("Home")],
          ),
        )))),
        bottomNavigationBar: buildBottomNavigation(context, path));
  }
}
