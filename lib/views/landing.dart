import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import '../views/app.dart';
import '../utils/globals.dart' as globals;
import 'package:passcode_screen/passcode_screen.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:screen_state/screen_state.dart';


enum Choice{BIOMETRICS, PIN}

class LandingComponent extends StatefulWidget {
  @override
  LandingComponentState createState() => new LandingComponentState();
}

class LandingComponentState extends State<LandingComponent>
    with AfterLayoutMixin<LandingComponent> {

  Screen _screen;
  StreamSubscription<ScreenStateEvent> _subscription;

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
    globals.checkInternet();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    startListening();
  }

  void onData(ScreenStateEvent event) {
    //print(event);
    if (event == ScreenStateEvent.SCREEN_UNLOCKED) {
      askUser();
    }
  }


  final LocalAuthentication auth = LocalAuthentication();
  bool authenticated = false;
  final StreamController<bool> _verificationNotifier =
  StreamController<bool>.broadcast();

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
      if (e.code == auth_error.notAvailable) {
        _pinCode();
      }
      if (!mounted) return;
    }
  }

  void _onPassCodeEntered(String enteredPassCode) async{
    var passCode = await globals.storage.read(key: "pinCode");
    authenticated = passCode == enteredPassCode;
    _verificationNotifier.add(authenticated);
    if (authenticated == true) {
      Application.router.navigateTo(context, "/home");
    }
    else
      _pinCode();
  }

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }

  void startListening() {
    _screen = new Screen();
    try {
      _subscription = _screen.screenStateStream.listen(onData);
    } on ScreenStateException catch (exception) {
      print(exception);
    }
  }

  void stopListening() {
    _subscription.cancel();
  }

  void _onPasscodeCancelled() {
    exit(0);
  }

  void _pinCode() {
    var circleUIConfig = new CircleUIConfig();
    var keyboardUIConfig = new KeyboardUIConfig();
    Navigator.push(
        context,
        PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) =>
                PasscodeScreen(
                  title: 'Enter PIN Code',
                  passwordDigits: 6,  
                  circleUIConfig: circleUIConfig,
                  keyboardUIConfig: keyboardUIConfig,
                  cancelCallback: _onPasscodeCancelled,
                //  isValidCallback: ,
                  passwordEnteredCallback: _onPassCodeEntered,
                  cancelLocalizedText: 'Cancel',
                  deleteLocalizedText: 'Delete',
                  shouldTriggerVerification: _verificationNotifier.stream,
                )
        ));
  }

  Future askUser() async {
    switch (
    await showDialog(
        barrierDismissible: false,
        context: context,
        // ignore: deprecated_member_use
        child: new SimpleDialog(
          title: new Text("Choose Authentication Method"),
          children: <Widget>[
            new SimpleDialogOption(
              child: new Text("Biometrics"),
              onPressed: () {
                Navigator.pop(context, Choice.BIOMETRICS);
              },
            ),
            new SimpleDialogOption(
              child: new Text("Pin Code"),
              onPressed: () {
                Navigator.pop(context, Choice.PIN);
              },
            )
          ],
        ))) {
      case Choice.BIOMETRICS:
      //  determinePath(context);
          await _authenticate();
        break;
      case Choice.PIN:
        _pinCode();
        break;
    }
  }

  void determinePath(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var installed = prefs.getBool('installed');
    if (installed == null) {
      await globals.storage.deleteAll();
      Application.router.navigateTo(context, "/onboarding/request");
  //  Application.router.navigateTo(context, "/onboarding/register");
    } else {
      // await askUser();
      await _authenticate();
      if (authenticated == true) {
        Application.router.navigateTo(context, "/home");
        }
      }
    }
  }