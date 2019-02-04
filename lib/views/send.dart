import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_reader/qr_reader.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:swipedetector/swipedetector.dart';
import '../components/bottomNavigation.dart';
import '../components/drawer.dart';
import '../api/endpoints.dart';
import '../views/app.dart';
import '../helpers.dart';
import '../api/responses.dart';

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
  Future<String> _barcodeString;
  String path = '/send';

  int accountIndex = 0;
  List<Account> accounts = [];

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
    String publicKey = await FlutterKeychain.get(key: "publicKey");
    String privateKey = await FlutterKeychain.get(key: "privateKey");
    // String accounts = await FlutterKeychain.get(key: "accounts");
    final String txnhash = _randomString(20);
    String signature = await signTransaction(txnhash, privateKey);
    var payload = {
      'from_account': accounts[accountIndex].accountId,
      'to_account': toAccount,
      'asset': 'BABE6CFE-A5C7-445C-9225-B072B98EBEA6',
      'amount': amount,
      'public_key': publicKey,
      "txn_hash": txnhash,
      "signature": signature
    };
    var response = await transferAsset(payload);
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Funds Sent"),
              content: new Text("PHP $sendAmount was sent successfully!"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("OK"),
                  onPressed: () {
                    Application.router.navigateTo(context, "/home");
                  },
                ),
              ],
            ));
    return response.success;
  }

  int sendAmount;

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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                                  )));
                        } else {
                          return Text('Fetching accounts...');
                        }
                      })),
              new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: new RaisedButton(
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
                  )),
              new FutureBuilder<String>(
                  future: _barcodeString,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Text(snapshot.data != null ? snapshot.data : ''),
                        Visibility(
                            child: new TextField(
                              decoration: new InputDecoration(
                                  labelText: "Enter the amount"),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                sendAmount = int.parse(value);
                              },
                            ),
                            visible: snapshot.data != null),
                        Visibility(
                            child: new RaisedButton(
                                child: const Text("Send"),
                                onPressed: () {
                                  sendFunds(snapshot.data, sendAmount, context);
                                }),
                            visible: snapshot.data != null)
                      ],
                    );
                  }),
            ])),
        bottomNavigationBar: buildBottomNavigation(context, path));
  }
}
