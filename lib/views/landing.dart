import 'package:flutter/material.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:after_layout/after_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:async';
import '../views/app.dart';

class LandingComponent extends StatefulWidget {
  @override
  LandingComponentState createState() => new LandingComponentState();
}

class LandingComponentState extends State<LandingComponent>
    with AfterLayoutMixin<LandingComponent> {
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

  final LocalAuthentication auth = LocalAuthentication();
  bool authenticated = false;

  Future<Null> _authenticate() async {
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
  }

  void determinePath(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var installed = prefs.getBool('installed');
    if (installed == null) {
      await FlutterKeychain.clear();
      Application.router.navigateTo(context, "/onboarding/request");
    } else {
      await _authenticate();
      if (authenticated == true) {
        Application.router.navigateTo(context, "/home");
      }
    }
  }
}
