import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../components/bottomNavigation.dart';
import '../components/drawer.dart';
import '../api/endpoints.dart';
import '../views/app.dart';
import '../helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/globals.dart' as globals;


class SendComponent extends StatefulWidget {
  @override
  SendComponentState createState() => new SendComponentState();
}

class SendComponentState extends State<SendComponent> {
  String _barcodeString = '';
  String path = '/send';
  int accountIndex = 0;
  bool _submitting = false;
  int sendAmount;
  final _formKey = GlobalKey<FormState>();
  String _selectedPaytacaAccount;
  List data = List();
  bool validCode = false;
  bool _errorFound = false;
  String _errorMessage;
  bool online = globals.online;
  
  Future<String> getAccounts(destinationAccountId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _prefAccounts = prefs.get("accounts");
    List<Map> _accounts = [];
    for (final acct in _prefAccounts) {
      String accountId = acct.split(' | ')[1];
      if(accountId != destinationAccountId) {
        var acctObj = new Map();
        acctObj['accountName'] = acct.split(' | ')[0];
        acctObj['accountId'] = accountId;
        acctObj['balance'] = acct.split(' | ')[2];
        _accounts.add(acctObj);
      }
    }
    setState(() {
      data = _accounts;
      _selectedPaytacaAccount= _accounts[0]['accountId'];
    });
    return 'Success';
  }

  @override
  void initState() {
    super.initState();
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
  

  Future<bool> sendFunds(String toAccount, int amount, BuildContext context) async {
    setState(() => _submitting = true);
    String destinationAccount = toAccount.split('::paytaca::')[1];
    String publicKey = await globals.storage.read(key: "publicKey");
    String privateKey = await globals.storage.read(key: "privateKey");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var now = new DateTime.now();
    var _txnDateTime = DateTime.parse(now.toString());
    var txnhash = "$amount:messsage:$_txnDateTime:message:$publicKey";
    // String message = "sample";
    // String temp = await signTransaction(message, privateKey);
    var _txnReadableDateTime = DateFormat('MMMM dd, yyyy  h:mm a').format(
      DateTime.parse(now.toString())
    );

    String signature = await signTransaction(txnhash, privateKey);
    var qrcode = "$signature:wallet:$txnhash:wallet:$publicKey";
    prefs.setString("_txnQrCode", qrcode);
    prefs.setString("_txnDateTime", _txnReadableDateTime);
    prefs.setString("_txnAmount", amount.toString());
    var payload = {
      'from_account': _selectedPaytacaAccount,
      'to_account': destinationAccount,
      'asset': globals.phpAssetId,
      'amount': amount,
      'public_key': publicKey,
      'txn_hash': txnhash,
      'signature': signature
      // 'signed_balance': {
      //   'message': message,
      //   'public_key': publicKey,
      //   'signature': temp
      // }
    };
    print(payload);
    var response = await transferAsset(payload);
    if (response.success == false) {
      setState(() {
        _errorFound = true;
        _errorMessage = response.error;
      });
    } else {
      Application.router.navigateTo(context, "/proofOfPayment");
    }
    setState(() => _submitting = false);
    return response.success;
  }

  void scanBarcode() async {
    allowCamera();
    String privateKey = await globals.storage.read(key: "privateKey");
    String publicKey = await globals.storage.read(key: "publicKey");
    String userid = await globals.storage.read(key: "userId");
    print('user id ---------------------');
    print(userid);
    print('public key -------------------');
    print(publicKey);
    print('private key ------------------');
    print(privateKey);
    String barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666");
    if (barcode.length > 0) {
      setState(() => _barcodeString = barcode);
    } else {
      setState(() => _barcodeString = '');
    }
  }

  void allowCamera() async {
    var permission = PermissionHandler();
    PermissionStatus cameraStatus = await permission.checkPermissionStatus(PermissionGroup.camera);
    if (cameraStatus == PermissionStatus.denied) {
          await permission.requestPermissions([PermissionGroup.camera]);
    }
  }

  Future<String> getBarcode() async {
    if (_barcodeString.contains(new RegExp(r'::paytaca::.*::paytaca::$'))) {
      var destinationAccountId = _barcodeString.split('::paytaca::')[1];
      await getAccounts(destinationAccountId);
      return _barcodeString;
    } else {
      return '';
    }
  }

  String validateAmount(String value) {
    if (value == null || value == "") {
      return 'This field is required.';
    } else if (value == '0') {
      return 'Please enter valid amount.';
    } else {
      var currentBalance;
      for(final map in data) {
        if(_selectedPaytacaAccount ==  map['accountId']){
          currentBalance = map['balance'];
          break;
        }
      }
      if (double.parse(currentBalance) < double.parse(value)) {
        return 'Insufficient balance';
      } else {
        if (double.parse(value) >= 100000) {
          return 'Max limit of Php 100,000.00 per transaction';
        } else {
          return null;
        }
        
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Send'),
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

  List<Widget> _buildForm(BuildContext context) {
    Form form = new Form(
      key: _formKey,
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new SizedBox(
            height: 30.0,
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
              if (snapshot.data != null) {
                if (snapshot.data.length > 0 ) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Visibility(
                        child:  new FormField(
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
                        visible: snapshot.data != null,
                      ),
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
                } else {
                  return Column();
                }
              }
              
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
    if (_errorFound) {
      var modal = new Stack(
        children: [
          AlertDialog(
            title: Text('Success'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('$_errorMessage')
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Got it!'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Application.router.navigateTo(context, "/send");
                  setState(() {
                    _errorMessage = '';
                    _errorFound = false;
                  });
                },
              ),
            ],
          )
        ]
      );
      ws.add(modal);
    }
    return ws;
  }
}
