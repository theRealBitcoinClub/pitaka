import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:swipedetector/swipedetector.dart';
import '../components/bottomNavigation.dart';
import '../components/drawer.dart';
import '../api/endpoints.dart';
import '../views/app.dart';
import '../helpers.dart';
import '../api/responses.dart';
import '../api/config.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SendComponent extends StatefulWidget {
  @override
  SendComponentState createState() => new SendComponentState();
}

String _randomString(int length) {
  var rand = new Random();
  var codeUnits = new List.generate(length, (index) {
    return rand.nextInt(33) + 89;
  });

  return new String.fromCharCodes(codeUnits);
}

class SendComponentState extends State<SendComponent> {
  String _barcodeString;
  String path = '/send';
  var _txnQrCode;
  int accountIndex = 0;
  List<Account> accounts = [];
  bool _submitting = false;
  int sendAmount;
  final _formKey = GlobalKey<FormState>();

  Future<List<Account>> getAccountsFromKeychain() async {
    String accounts = await FlutterKeychain.get(key: "accounts");
    List<Account> _accounts = [];
    for (final acct in accounts.split(',')) {
      var acctObj = new Account();
      acctObj.accountName = acct.split('|')[0];
      acctObj.accountId = acct.split('|')[1];
      _accounts.add(acctObj);
    }
    return _accounts;
  }

  Future<bool> sendFunds(
    String toAccount, int amount, BuildContext context) async {
    setState(() => _submitting = true);
    String publicKey = await FlutterKeychain.get(key: "publicKey");
    String privateKey = await FlutterKeychain.get(key: "privateKey");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String txnhash = _randomString(20);
    String signature = await signTransaction(txnhash, privateKey);
    var key = utf8.encode(hashCode);
    var hmacSha256 = new Hmac(sha256, key);
    var concatenated;
    var _txnDateTime;
    var now = new DateTime.now();
    _txnDateTime = DateTime.parse(now.toString());
    concatenated = "$amount:$publicKey:$_txnDateTime:$signature";
    setState(() => _txnQrCode = hmacSha256.convert(utf8.encode(concatenated)));
    prefs.setString("_txnQrCode", _txnQrCode.toString());
    var payload = {
      'from_account': accounts[accountIndex].accountId,
      'to_account': toAccount,
      'asset': phpAssetId,
      'amount': amount,
      'public_key': publicKey,
      "txn_hash": txnhash,
      "signature": signature
    };
    var response = await transferAsset(payload);
    Application.router.navigateTo(context, "/proofOfPayment");
    setState(() => _submitting = false);
    return response.success;
  }

  void scanBarcode() async {
    String barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666");
    setState(() => _barcodeString = barcode);
  }

  Future<String> getBarcode() async {
    return _barcodeString;
  }

  String validateAmount(String value) {
    if (value == null || value == "") {
      return 'This field is required.';
    } else if (value == '0') {
      return 'Please enter valid amount.';
    }else {
      return null;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Send'),
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildForm(context));
        }),
        bottomNavigationBar: buildBottomNavigation(context, path)
      );
  }

  List<Widget> _buildForm(BuildContext context) {
    Form form = new Form(
      key: _formKey,
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new SizedBox(
            height: 30.0,
          ),
          Center(
            child: FutureBuilder(
              future: getAccountsFromKeychain(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  accounts = snapshot.data;
                  String sourceAccount =
                    snapshot.data[accountIndex].accountName;
                  return SwipeDetector(
                    onSwipeLeft: () {
                      setState(() {
                        if (accountIndex <
                            (snapshot.data.length - 1)) {
                          accountIndex += 1;
                        }
                      });
                    },
                    onSwipeRight: () {
                      setState(() {
                        if (accountIndex > 0) {
                          accountIndex -= 1;
                        }
                      });
                    },
                    swipeConfiguration: SwipeConfiguration(
                      horizontalSwipeMaxHeightThreshold: 50.0,
                      horizontalSwipeMinDisplacement: 50.0,
                      horizontalSwipeMinVelocity: 200.0),
                      child: new Container(
                        padding: const EdgeInsets.only(
                          top: 50.0, bottom: 50.00),
                        child: Text(
                          'Send from $sourceAccount account',
                          style: new TextStyle(
                            fontSize: 18.0,
                          ),
                        )
                      )
                    );
                } else {
                  return Text('Fetching accounts...');
                }
              }
            )
          ),
          new Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: new RaisedButton(
              child: const Text('Scan QR Code'),
              onPressed: scanBarcode,
            )
          ),
          new FutureBuilder<String>(
            future: getBarcode(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Text(snapshot.data != null ? snapshot.data : ''),
                  Visibility(
                    child: new TextFormField(
                      validator: validateAmount,
                      decoration: new InputDecoration(labelText: "Enter the amount"),
                      keyboardType: TextInputType.number,
                      onSaved: (value) {
                        setState(() => sendAmount = int.parse(value));
                      },
                    ),
                    visible: snapshot.data != null
                  ),
                  Visibility(
                    child: new RaisedButton(
                      child: const Text("Send"),
                      onPressed: () {
                        var valid = _formKey.currentState.validate();
                        if (valid) {
                          _formKey.currentState.save();
                          sendFunds(snapshot.data, sendAmount, context);
                        }
                      }
                    ),
                    visible: snapshot.data != null)
                ],
              );
            }
          ),
        ],
      )
    );
    var ws = new List<Widget>();
    ws.add(form);
    if (_submitting) {
      var modal = new Stack(
        children: [
          new Opacity(
            opacity: 0.8,
            child: const ModalBarrier(dismissible: false, color: Colors.grey),
          ),
          new Center(
            child: new CircularProgressIndicator(),
          ),
        ],
      );
      ws.add(modal);
    }
    return ws;
  }
}
