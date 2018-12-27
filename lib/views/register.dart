import 'package:flutter/material.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import "package:hex/hex.dart";
import 'dart:typed_data';
import '../views/app.dart';

class RegisterComponent extends StatefulWidget {
  @override
  RegisterComponentState createState() => new RegisterComponentState();
}

class RegisterComponentState extends State<RegisterComponent> {
  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Text("Welcome to Paytaca!"),
            RaisedButton(
              child: const Text('Register'),
              onPressed: () {
                generateKeyPair(context);
              },
            ),
          ]),
    );
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

  Future<Null> generateKeyPair(BuildContext context) async {
    final keyPair = await CryptoSign.generateKeyPair();

    Uint8List publicKeyBytes = keyPair.publicKey;
    Uint8List privateKeyBytes = keyPair.secretKey;
    String publicKey = HEX.encode(publicKeyBytes);
    String privateKey = HEX.encode(privateKeyBytes);

    await FlutterKeychain.put(key: "publicKey", value: publicKey);
    await FlutterKeychain.put(key: "privateKey", value: privateKey);

    await _authenticate();
    if (authenticated == true) {
      Application.router.navigateTo(context, "/home");
    }
  }
}
