import 'dart:async';
import 'dart:convert';
import 'package:hex/hex.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../api/endpoints.dart';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import '../utils/globals.dart';
import '../utils/dialogs.dart';
import '../utils/globals.dart' as globals;


class ReceiveComponent extends StatefulWidget {
  @override
  ReceiveComponentState createState() => new ReceiveComponentState();
}

class ReceiveComponentState extends State<ReceiveComponent> {
  final _formKey = GlobalKey<FormState>();
  static List data = List();
  String path = "/receive";
  String _selectedPaytacaAccount;
  bool online = globals.online;
  bool isOffline = false;
  bool _loading = false;
  int accountIndex = 0;

  @override
  void initState()  {
    super.initState();
    // Subscribe to Notifier Stream from ConnectionStatusSingleton class in globals.dart
    // Fires whenever connectivity state changes
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    connectionStatus.connectionChange.listen(connectionChanged);

    // Run getAccounts() function upon widget build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        getAccounts();
      });
    });
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

  // Scan QRcode from Payment Proof after Send
  void scanQrcode() async {
    String qrcode = await FlutterBarcodeScanner.scanBarcode("#ff6666","Cancel", true); 

    // Decode and split the QRcode data
    var baseDecoded = base64.decode(qrcode);
    var gzipDecoded = new GZipDecoder().decodeBytes(baseDecoded);
    var utf8Decoded = utf8.decode(gzipDecoded);
    var qrArr = utf8Decoded.split('||');

    // Create fresh UDID from flutter_udid library
    String udid = await FlutterUdid.consistentUdid;
    
    // Check if QRcode data array has all the payload data created from "sender.dart" in sendFunds function
    if (qrArr.length == 4) {
      var stringified  = qrArr[2].toString();
      List hashArr = stringified.split(':-:');
      String senderOnline = hashArr[8];
      var payload;
      double amount = double.parse(hashArr[0]);
      String pubKey = qrArr[3];
      String fromAccount = hashArr[2];
      String txnHash = qrArr[0];
      String txnSignature = qrArr[1];
      // Get the date and time from array
      // And convert to datetime object
      var parsedDate = DateTime.parse(hashArr[1]);
      // Format the datetime object and convert bact to string
      //String txnDateTime = DateFormat('MMMM dd, yyyy  h:mm a').format(parsedDate);
      String txnDateTime = DateFormat("yyyy/MM/dd HH:mm a").format(parsedDate);

      String txnID = hashArr[6];
      // Convert signature and public key to bytes for verification
      var decodedSignature = HEX.decode(txnSignature);
      var decodedPublicKey = HEX.decode(pubKey);
      if (hashArr.length == 9) {
        // Check if the sender was online during sending
        if (senderOnline == "true") {
          // Set _loading to true to show circular progress bar
          setState(() {
            _loading = true;
          });
          // Try catching error and pop up success dialog when there is an error
          // If both sender and receiver are online they will update balances anyway
          try {
            // Create the payload
            payload = {
              'from_account': fromAccount,
              'to_account': _selectedPaytacaAccount,
              'asset': globals.phpAssetId,
              'amount': amount.toString(),
              'public_key': HEX.encode(decodedPublicKey), // Convert public key back to string
              'txn_hash': txnHash,
              'signature': HEX.encode(decodedSignature),  // Convert signature back to string
              'transaction_id': txnID,
              'transaction_datetime': txnDateTime,
              'signed_baproofOfPaymentSuccessDialoglance':  {},
              'device_id': udid,
            };
            // Call receiveAsset function from "endpoints.dart"
            var response = await receiveAsset(payload);
            // Set _loading to false to hide circular progress bar
            setState(() {
              _loading = false;
            });
            // Check response, pop up a dialog for failed or success 
            if (response.success == false) {
              proofOfPaymentFailedDialog(context);
            } else {
              proofOfPaymentSuccessDialog(context);
            }
          } catch(e) {
            print(e);
            proofOfPaymentSuccessDialog(context);
          }
        } else {
          // Set _loading to true to show circular progress bar
          setState(() {
            _loading = true;
          });
          // Check if amount sent if less than or equal to last balance
          double lBalance = double.parse(hashArr[3]);
          if (amount <= lBalance) {
            // Verify txnHash using signature and public key
            var firstValidation = await CryptoSign.verify(decodedSignature, txnHash, decodedPublicKey);
            print("The value of firstValidation during offline is: $firstValidation");
            if (firstValidation) {
              var timestamp = hashArr[5];
              var signValue = hashArr[4].toString();
              var lastSignedBalance = HEX.decode(signValue);
              var serverPublicKey = HEX.decode(globals.serverPublicKey);
              var concatenated = "${lBalance.toStringAsFixed(6)}$fromAccount$timestamp";
              List<int> bytes = utf8.encode(concatenated);
              var hashMessage = sha256.convert(bytes).toString();
              // Verify hashMessage using lastSignedBalance and serverPublicKey
              var secondValidation = await CryptoSign.verify(lastSignedBalance, hashMessage, serverPublicKey);
              print("The value of secondtValidation during offline is: $secondValidation");
              if (secondValidation) {
                // Create the payload
                payload = {
                  'from_account': fromAccount,
                  'to_account': _selectedPaytacaAccount,
                  'asset': globals.phpAssetId,
                  'amount': amount.toString(),
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
                  },
                  'device_id': udid,
                };
                // Call receiveAsset function from "endpoints.dart"
                var response = await receiveAsset(payload);
                // Set _loading to false to hide circular progress bar
                setState(() {
                  _loading = true;
                });
                // Check response, pop up a dialog for failed or success 
                if (response.success == false) {
                  proofOfPaymentFailedDialog(context);
                } else {
                  proofOfPaymentSuccessDialog(context);
                }
              } else {
                proofOfPaymentFailedDialog(context);
              }
            } else {
              proofOfPaymentFailedDialog(context);
            }
          }
        }
      }
    } else {
      proofOfPaymentFailedDialog(context);
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
        acctObj['accountName'] = acct.split(' | ')[0];
        acctObj['accountId'] = accountId;
        _accounts.add(acctObj);
      }
      data = _accounts;
      return _accounts;
    } catch(e) {
      print("Error in getAccounts(): $e");
    }
    return data;
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
                  errorText: state.errorText,
                ),
                child: new DropdownButtonHideUnderline(
                  child: new DropdownButton(
                    hint: Text('Select Account'),
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
          // Put qrcode and circular progress indicator inside stack
          // so they can overlap each other
          new Stack(
            children: <Widget>[
              Visibility(
                visible: _selectedPaytacaAccount != null ? true: false,
                child: QrImage(
                  data: _selectedPaytacaAccount != null ? "::paytaca::$_selectedPaytacaAccount::paytaca::": ""
                ),
              ),
              new Positioned(
                top: 150.0,
                left: 150.0,
                child: Visibility(
                  visible: _loading,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: 150),
                    child: new CircularProgressIndicator()
                  ),
                ),
              )
            ]
          ),
          new SizedBox(
            height: 20.0,
          ),
          buildButton(),
        ],
      )
    );
    var ws = new List<Widget>();
    ws.add(form);
    return ws;
  }
}
