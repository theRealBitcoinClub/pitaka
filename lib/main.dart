import 'dart:async';
import "package:hex/hex.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_reader/qr_reader.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paytaca',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Paytaca'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Future<String> _barcodeString;

  String publicKey;
  String privateKey;
  String userXID;

  void retrieveStoredValues() async {
    publicKey = await FlutterKeychain.get(key: "publicKey");
    privateKey = await FlutterKeychain.get(key: "privateKey");
    userXID = await FlutterKeychain.get(key: "userXID");
  }

  @override
  void initState() {
    super.initState();
    retrieveStoredValues();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  String _authorized = 'Not Authorized';

  Future<Null> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<Null> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<Null> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });
  }

  Uint8List publicKeyBytes;
  Uint8List privateKeyBytes;

  Future<Null> generateKeyPair() async {
    final keyPair = await CryptoSign.generateKeyPair();

    setState(() {
      publicKeyBytes = keyPair.publicKey;
      privateKeyBytes = keyPair.secretKey;
      publicKey = HEX.encode(keyPair.publicKey);
      privateKey = HEX.encode(keyPair.secretKey);
    });

    await FlutterKeychain.put(key: "publicKey", value: publicKey);
    await FlutterKeychain.put(key: "privateKey", value: privateKey);
  }

  Future<String> signTransaction(String txnHash) async {
    final signature = await CryptoSign.sign(txnHash, privateKeyBytes);
    return HEX.encode(signature);
  }

  Future<Null> createUser() async {
    var url = "http://af056012.ngrok.io/api/users/create";
    var payload = {
      "firstname": "Bernardo",
      "lastname": "Carpio",
      "birthday": "2006-01-02",
      "email": "joemar.ct+00" + _counter.toString() + "@gmail.com",
      "public_key": publicKey,
      "txn_hash": "helloworld",
      "signature": await signTransaction("helloworld")
    };
    final response = await http.post(
      url,
      body: json.encode(payload),
      headers: {"Content-Type": "application/json"}
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      setState(() {
        userXID = responseJson['xid'];
      });

      await FlutterKeychain.put(key: "userXID", value: userXID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.red
              ),
            ),
            ListTile(
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              }
            ),
            ListTile(
              title: Text('Send'),
              onTap: () {
                Navigator.pop(context);
              }
            ),
            ListTile(
              title: Text('Receive'),
              onTap: () {
                Navigator.pop(context);
              }
            )
          ],
        ),
      ),
      body: Center(
        child: new Container(
          child: new SingleChildScrollView(
            child: new ConstrainedBox(
              constraints: new BoxConstraints(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.display1,
                  ),
                  new QrImage(
                    data: '$_counter',
                    size: 200.0,
                  ),
                  new RaisedButton(
                    child: const Text('Scan'),
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
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return new Text(snapshot.data != null ? snapshot.data : '');
                  }),
                  Text('Can check biometrics: $_canCheckBiometrics\n'),
                  RaisedButton(
                    child: const Text('Check biometrics'),
                    onPressed: _checkBiometrics,
                  ),
                  Text('Available biometrics: $_availableBiometrics\n'),
                  RaisedButton(
                    child: const Text('Get available biometrics'),
                    onPressed: _getAvailableBiometrics,
                  ),
                  Text('Current State: $_authorized\n'),
                  RaisedButton(
                    child: const Text('Authenticate'),
                    onPressed: _authenticate,
                  ),
                  Text('Public key: $publicKey\n'),
                  Text('Private key: $privateKey\n'),
                  RaisedButton(
                    child: const Text('Generate Key Pair'),
                    onPressed: generateKeyPair,
                  ),
                  Text('User XID: $userXID\n'),
                  RaisedButton(
                    child: const Text('Create User'),
                    onPressed: createUser,
                  ),
                ],
              ),
            )
            )
          )
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
