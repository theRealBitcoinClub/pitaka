import 'package:flutter/material.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../views/app.dart';

class LandingComponent extends StatefulWidget {
  @override
  LandingComponentState createState() => new LandingComponentState();
}

class LandingComponentState extends State<LandingComponent>
    with AfterLayoutMixin<LandingComponent> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(body: new Container(color: Colors.red));
  }

  @override
  void afterFirstLayout(BuildContext context) {
    determinePath(context);
  }

  // bool _canCheckBiometrics;
  // List<BiometricType> _availableBiometrics;
  // String _authorized = 'Not Authorized';

  // Future<Null> _checkBiometrics() async {
  //   bool canCheckBiometrics;
  //   try {
  //     canCheckBiometrics = await auth.canCheckBiometrics;
  //   } on PlatformException catch (e) {
  //     print(e);
  //   }
  //   if (!mounted) return;

  //   setState(() {
  //     _canCheckBiometrics = canCheckBiometrics;
  //   });
  // }

  // Future<Null> _getAvailableBiometrics() async {
  //   List<BiometricType> availableBiometrics;
  //   try {
  //     availableBiometrics = await auth.getAvailableBiometrics();
  //   } on PlatformException catch (e) {
  //     print(e);
  //   }
  //   if (!mounted) return;

  //   setState(() {
  //     _availableBiometrics = availableBiometrics;
  //   });
  // }

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
    String publicKey = await FlutterKeychain.get(key: "publicKey");
    print("Public key: $publicKey");
    if (publicKey == null) {
      Application.router.navigateTo(context, "/register");
    } else {
      await _authenticate();
      if (authenticated == true) {
        Application.router.navigateTo(context, "/home");
      }
    }
  }
}
