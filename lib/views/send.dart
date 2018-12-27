import 'package:flutter/material.dart';
import 'package:qr_reader/qr_reader.dart';
import '../components/bottomNavigation.dart';
import '../components/drawer.dart';

class SendComponent extends StatefulWidget {
  @override
  SendComponentState createState() => new SendComponentState();
}

class SendComponentState extends State<SendComponent> {
  Future<String> _barcodeString;
  String path = "/send";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Send'),
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              new RaisedButton(
                child: const Text('Scan QR Code'),
                onPressed: () {
                  setState(() {
                    _barcodeString = new QRCodeReader()
                        .setTorchEnabled(true)
                        .setHandlePermissions(true)
                        .setExecuteAfterPermissionGranted(true)
                        .scan();
                  });
                },
              ),
              new FutureBuilder<String>(
                  future: _barcodeString,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return new Text(snapshot.data != null ? snapshot.data : '');
                  }),
            ])),
        bottomNavigationBar: buildBottomNavigation(context, path));
  }
}
