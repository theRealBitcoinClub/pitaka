import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
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
import 'package:archive/archive.dart';
import '../utils/globals.dart';
import '../utils/print_wrapped.dart';


class ReceiveComponent extends StatefulWidget {
  @override
  ReceiveComponentState createState() => new ReceiveComponentState();
}

class ReceiveComponentState extends State<ReceiveComponent> {
  String path = "/receive";
  int accountIndex = 0;
  final _formKey = GlobalKey<FormState>();
  String _selectedPaytacaAccount;
  static List data = List(); //edited line
  bool online = globals.online;
  bool isOffline = false;

  @override
  void initState()  {
    super.initState();
    getAccounts();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      if(isOffline == false) {
        online = !online;
        globals.online = online;
        print("Online");
      } else {
        online = false;
        globals.online = online;
        print("Offline");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void scanQrcode() async {
    String qrcode = await FlutterBarcodeScanner.scanBarcode("#ff6666","Cancel", true);
    var baseDecoded = base64.decode(qrcode);
    var gzipDecoded = new GZipDecoder().decodeBytes(baseDecoded);
    var utf8Decoded = utf8.decode(gzipDecoded);
    var qrArr = utf8Decoded.split(':wallet:');
    if (qrArr.length == 3) {
      var stringified  = qrArr[1].toString();
      List hashArr = stringified.split(':-:');
      if(hashArr.length == 8){
        double amount = double.parse(hashArr[0]);
        double lBalance = double.parse(hashArr[3]);
        if(amount <= lBalance) {
          String pubKey = qrArr[2];
          String fromAccount = hashArr[2];
          String txnHash = qrArr[1];
          String txnSignature = qrArr[0];
          String txnDateTime = hashArr[1];
          String txnID = hashArr[6];
          var decodedSignature = HEX.decode(txnSignature); // Convert signature to bytes for verification
          var decodedPublicKey = HEX.decode(pubKey);  // Convert public key to bytes for verification
          var firstValidation = await CryptoSign.verify(decodedSignature, txnHash, decodedPublicKey);
          if (firstValidation) {
            var timestamp = hashArr[5];
            var signValue = hashArr[4].toString();
            var lastSignedBalance = HEX.decode(signValue);
            var serverPublicKey = HEX.decode(globals.serverPublicKey);
            var concatenated = "${lBalance.toStringAsFixed(6)}$fromAccount$timestamp";
            List<int> bytes = utf8.encode(concatenated);
            var hashMessage = sha256.convert(bytes).toString();
            var secondValidation = await CryptoSign.verify(lastSignedBalance, hashMessage, serverPublicKey);
            if (secondValidation) {
              var payload = {
                'from_account': fromAccount,
                'to_account': _selectedPaytacaAccount,
                'asset': globals.phpAssetId,
                'amount': amount,
                'public_key': HEX.encode(decodedPublicKey), // Convert public key back to string
                'txn_hash': txnHash,
                'signature': HEX.encode(decodedSignature),  // Convert signature back to string
                'transaction_id': txnID,
                'transaction_datetime': txnDateTime,
                'signed_balance':  {
                  'message': hashMessage,
                  'signature': HEX.encode(lastSignedBalance), // Convert signature back to string
                  'balance': lBalance,
                  'timestamp': timestamp,
                }
              };
              var response = await receiveAsset(payload);

              // Call printWrapped funtion from utils to print very long text
              // Use only for debugging, comment out when done
              //printWrapped("The value of payload from scanQrcode() - receive.dart is: $payload",);
              
              if (response.success == false) {
                _failedDialog();
              } else {
                _successDialog();
              }
            } else {
              _failedDialog();
            }
          } else {
            _failedDialog();
          }
        }
      }
    } else {
      _failedDialog();
    }
  }

   Future<List> getAccounts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var _prefAccounts = prefs.get("accounts");
      List<Map> _accounts = [];
      for (final acct in _prefAccounts) {
        String accountId = acct.split(' | ')[1];
        var acctObj = new Map();
        // var onlineBalance = acct.split(' | ')[2];
        acctObj['accountName'] = acct.split(' | ')[0];
        acctObj['accountId'] = accountId;
        // if (globals.online) {
        //   acctObj['balance'] = onlineBalance;
        // } else {
        //   var x = double.tryParse(onlineBalance);
        //   var resp = await globals.databaseHelper.offlineBalanceAnalyser(accountId, x);
        //   acctObj['balance'] = resp['computedBalance'].toString();
        // }
        _accounts.add(acctObj);
      }
      data = _accounts;
      return _accounts;
    } catch(e) {}
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
                child: online ? new Icon(Icons.wifi): new Icon(Icons.signal_wifi_off)
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
      return new ButtonTheme(
        height: 60,
        buttonColor: Colors.white,
        child: new OutlineButton(
          borderSide: BorderSide(
            color: Colors.black
          ),
          child: const Text('Scan Payment Proof', style: TextStyle(fontSize: 18)),
          onPressed: () {
            scanQrcode();
          }
        )
      );
    } else {
      return new Container();
    }
  }

  List<Widget> _buildForm(BuildContext context) {
    Form form = new Form(
      key: _formKey,
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new SizedBox(
            height: 20.0,
          ),
          new FormField(
            builder: (FormFieldState state) {
              return InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Select Account',
                ),

                child: new DropdownButtonHideUnderline(
                  child: new DropdownButton(
                    items: data.map((item) {
                      return DropdownMenuItem(
                        value: item['accountId'],
                        child: new Text("${item['accountName']}"),
                      );
                    }).toList(),
                    iconEnabledColor: Colors.red,
                    value: _selectedPaytacaAccount,
                    isDense: true,
                    onChanged: (newVal) {
                        setState(() {
                          _selectedPaytacaAccount = newVal;
                          state.didChange(newVal);
                        });
                    },
                  ),
                )
              );
            },
          ),
          new SizedBox(
            height: 20.0,
          ),
          Visibility(
            visible: _selectedPaytacaAccount != null ? true: false,
            child: QrImage(
              data: _selectedPaytacaAccount != null ? "::paytaca::$_selectedPaytacaAccount::paytaca::": ""
            ),
          ),

          new SizedBox(
            height: 20.0,
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
