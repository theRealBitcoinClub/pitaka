import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
        appBar: AppBar(
          title: Text('Receive'),
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              QrImage(
                data: 'sample',
                size: 0.8 * bodyHeight,
              )
            ]),
        bottomNavigationBar: buildBottomNavigation(context, path));
  }
}
