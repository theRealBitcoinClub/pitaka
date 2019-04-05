import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:swipedetector/swipedetector.dart';
import '../views/app.dart';
import 'dart:async';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import '../api/responses.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:hex/hex.dart';



class ReceiveComponent extends StatefulWidget {
  @override
  ReceiveComponentState createState() => new ReceiveComponentState();
}

class ReceiveComponentState extends State<ReceiveComponent> {
  String path = "/receive";
  int accountIndex = 0;
  
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

  void scanQrcode() async {
    String qrcode = await FlutterBarcodeScanner.scanBarcode("#ff6666");
    print(qrcode);
    var strings = qrcode.split(':wallet:');
    if (strings.length == 3) {
      var signature = HEX.decode(strings[0]);
      var publicKey = HEX.decode(strings[2]);
      String message = strings[1];
      var valid = await CryptoSign.verify(signature, message, publicKey);
      if (valid) {
        List info = message.split(":message:");
        var now = DateTime.now();
        var _txnDate = DateTime.parse(info[1]);
        Duration difference = now.difference(_txnDate);
        print(difference.inMinutes);
        // Use difference in minutes to monitor the freshness of the transaction.
        _successDialog();
        return null;
      }
    }
    _failedDialog();
    return null;
  }


  Future<void> _failedDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Failed'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Invalid code! Please try again.')
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay!'),
              onPressed: () {
                Navigator.of(context).pop();
                Application.router.navigateTo(context, "/receive");
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _successDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Payment transaction has been verified.')
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay!'),
              onPressed: () {
                Navigator.of(context).pop();
                Application.router.navigateTo(context, "/home");
              },
            ),
          ],
        );
      },
    );
  }

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
        body: new FutureBuilder(
            future: getAccountsFromKeychain(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return SwipeDetector(
                    onSwipeLeft: () {
                      setState(() {
                        if (accountIndex < (snapshot.data.length - 1)) {
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          snapshot.data[accountIndex].accountName,
                          style: new TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        QrImage(
                          data: snapshot.data[accountIndex].accountId,
                          size: 0.6 * bodyHeight,
                        ),
                        new RaisedButton(
                          child: const Text('Scan Proof'),
                          onPressed: () {
                            scanQrcode();
                          },
                        )
                      ]
                    )
                  );
              } else {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[new CircularProgressIndicator()]);
              }
            }),
        bottomNavigationBar: buildBottomNavigation(context, path));
  }
}
