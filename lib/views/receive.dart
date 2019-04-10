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
  
  @override
  void initState() {
    super.initState();
    this.getAccounts();
  }

  void scanQrcode() async {
    String qrcode = await FlutterBarcodeScanner.scanBarcode("#ff6666");
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
      } else {
        _failedDialog();
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
          new RaisedButton(
            child: const Text('Scan Proof'),
            onPressed: () {
              scanQrcode();
            },
          )
        ],
      )
    );
    var ws = new List<Widget>();
    ws.add(form);
    return ws;
  }
}
