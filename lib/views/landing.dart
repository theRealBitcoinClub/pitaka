import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../views/app.dart';
import '../utils/globals.dart' as globals;
import '../utils/globals.dart';


class LandingComponent extends StatefulWidget {
  @override
  LandingComponentState createState() => new LandingComponentState();
}

class LandingComponentState extends State<LandingComponent>
  with AfterLayoutMixin<LandingComponent> {
  
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;

  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        color: Colors.red,
        image: new DecorationImage(
          image: new AssetImage("assets/images/background1.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: new Center(
          child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
              width: 160.0,
              height: 160.0,
              child: new CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation(Colors.red),
                  strokeWidth: 4.0),
              decoration: new BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                      fit: BoxFit.fill,
                      image: new AssetImage("assets/icon/icon.png"))))
        ],
      )),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    determinePath(context);
  }

  @override
  void initState() {
    super.initState();
    // Subscribe to Notifier Stream from ConnectionStatusSingleton class in globals.dart
    // Fires whenever connectivity state changes
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
  }
  // Handle's internet connection On/Off state
  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      if(isOffline == false) {
        online = !online;
        globals.online = online;
        syncing = true;
        globals.syncing = true;
        print("Online");
      } else {
        online = false;
        globals.online = online;
        syncing = false;
        globals.syncing = false;
        print("Offline");
      }
    });
  }

  final LocalAuthentication auth = LocalAuthentication();
  bool authenticated = false;

  Future<Null> _authenticate() async {
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: true);
      if (!authenticated) {
        exit(0);
      }
    } on PlatformException catch (e) {
      print(e);
      authenticated = true;
    }
  }

  void determinePath(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var installed = prefs.getBool('installed');
    if (installed == null) {
      await globals.storage.deleteAll();
      Application.router.navigateTo(context, "/onboarding/request");
    } else {
      await _authenticate();
      if (authenticated == true) {
        print("Checking for pincode...");
        final readPincode = await globals.storage.read(key: "pincodeKey");
        if (readPincode == null) {
          print("No pincode exist!");
        } else {
          print("Pincode exist.");
          Application.router.navigateTo(context, "/checkpincode");
        }
      }
    }
  }
}
