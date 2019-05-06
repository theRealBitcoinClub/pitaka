import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:pitaka/utils/helpers.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../views/app.dart';
import 'dart:async';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:hex/hex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/globals.dart' as globals;
import '../api/endpoints.dart';

class ReceiveComponent extends StatefulWidget {
  @override
  ReceiveComponentState createState() => new ReceiveComponentState();
}

class ReceiveComponentState extends State<ReceiveComponent> {
  String path = "/receive";
  int accountIndex = 0;
  final _formKey = GlobalKey<FormState>();
  String _selectedPaytacaAccount;
  List data = List(); //edited line
  bool online = globals.online;
  
  @override
  void initState() {
    super.initState();
    this.getAccounts();
    globals.checkConnection().then((status){
      setState(() {
        if (status == false) {
          online = false;  
          globals.online = online;
        } else {
          globals.online = online;
        }
      });
    });
    
  }

  void scanQrcode() async {
    String qrcode = await FlutterBarcodeScanner.scanBarcode("#ff6666");
    var qrArr = qrcode.split(':wallet:');
    if (qrArr.length == 3) {
      List hashArr = qrArr[1].split(':messsage:');
      if(hashArr.length == 5){
        double amount = double.parse(hashArr[0]);
        double lBalance = double.parse(hashArr[4]);
        if(amount <= lBalance) {
          String pubKey = qrArr[2];
          String fromAccount = hashArr[3];
          String txnHash = qrArr[2];
          String txnSignature = qrArr[0];
          var signature = HEX.decode(txnSignature);
          var publicKey = HEX.decode(pubKey);
          var valid = await CryptoSign.verify(signature, txnHash, publicKey);
          if (valid) {
            var now = DateTime.now();
            var _txnDate = DateTime.parse(hashArr[1]);
            Duration difference = now.difference(_txnDate);
            if (difference.inHours < 12) {
              var concatenated = "$lBalance$fromAccount${hashArr[1]}";
              var bytes = utf8.encode(concatenated);
              var hashMessage = sha256.convert(bytes).toString();
              String lastSignedBalance = await signTransaction(hashMessage, globals.serverPublicKey);
              var payload = {
                'from_account': fromAccount,
                'to_account': _selectedPaytacaAccount,
                'asset': globals.phpAssetId,
                'amount': amount,
                'public_key': publicKey,
                'txn_hash': txnHash,
                'signature': txnSignature,
                'signed_balance':  {
                  'message': hashMessage,
                  'signature': lastSignedBalance,
                  'balance': lBalance,
                  'timestamp': hashArr[1]
                }
              };
              print('this is the payload ----------------------');
              print(payload);
              // var response = await receiveAsset(payload);
              // if (response.success == false) {
              //   // setState(() {
              //     // _errorFound = true;
              //     // _errorMessage = response.error;
              //   // });
              // } else {
              //   Application.router.navigateTo(context, "/proofOfPayment");
              // }
              // // setState(() => _submitting = false);
              // // return response.success;
              // _successDialog();
            }
            // print(difference.inMinutes);
            // Use difference in minutes to monitor the freshness of the transaction.
            // return null;
          } else {
            _failedDialog();
          }
        }
      }
    } else {
      if (qrcode.length > 0) {
        _failedDialog();
      }
    }
  }

  Future<String> getAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _prefAccounts = prefs.get("accounts");
    List<Map> _accounts = [];
    for (final acct in _prefAccounts) {
      var acctObj = new Map();
      acctObj['accountName'] = acct.split(' | ')[0];
      acctObj['accountId'] = acct.split(' | ')[1];
      acctObj['balance'] = acct.split(' | ')[2];
      _accounts.add(acctObj);
    }
    setState(() {
      data = _accounts;
    });
    return 'Success';
  }

  Future<void> _failedDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Failure'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("The proof of payment you scanned is invalid.")
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
                Text('Proof of payment has been validated.')
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Receive'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                child: online ? new Icon(Icons.wifi): new Icon(Icons.signal_wifi_off),
                onTap: (){
                  globals.checkConnection().then((status){
                    setState(() {
                      if (status == true) {
                        online = !online;  
                        globals.online = online;  
                      } else {
                        online = false;  
                        globals.online = online;
                      }
                    });
                  });
                }
              ) 
            )
          ],
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildForm(context));
        }),
        bottomNavigationBar: buildBottomNavigation(context, path)
      );
  }

  Widget buildButton (){
    if (_selectedPaytacaAccount != null) {
      return new RaisedButton(
        child: const Text('Scan Proof'),
        onPressed: () {
          scanQrcode();
        },
      );
    } else {
      return new Container();
    }
  }

  List<Widget> _buildForm(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    Form form = new Form(
      key: _formKey,
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new SizedBox(
            height: 30.0,
          ),
          new FormField(
            builder: (FormFieldState state) {
              return InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Select Account',
                ),
                child: new DropdownButtonHideUnderline(
                  child: new DropdownButton(
                    value: _selectedPaytacaAccount,
                    isDense: true,
                    onChanged: (newVal) {
                      setState(() {
                        _selectedPaytacaAccount = newVal;
                        state.didChange(newVal);
                      });
                    },
                    items: data.map((item) {
                      return DropdownMenuItem(
                        value: item['accountId'],
                        child: new Text("${item['accountName']} ( ${double.parse(item['balance']).toStringAsFixed(2)} )"),
                      );
                    }).toList()
                  ),
                )
              );
            },
          ),
          QrImage(
            data: _selectedPaytacaAccount != null ? "::paytaca::$_selectedPaytacaAccount::paytaca::": null,
            size: 0.6 * bodyHeight,
          ),
          buildButton()
        ],
      )
    );
    var ws = new List<Widget>();
    ws.add(form);
    return ws;
  }
}
