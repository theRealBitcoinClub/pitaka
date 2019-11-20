import 'dart:async';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../components/bottomNavigation.dart';
import '../components/drawer.dart';
import '../api/endpoints.dart';
import '../views/app.dart';
import '../utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/globals.dart' as globals;
import '../utils/database_helper.dart';
import 'package:uuid/uuid.dart';
import '../utils/globals.dart';


class SendComponent extends StatefulWidget {
  @override
  SendComponentState createState() => new SendComponentState();
}

class SendComponentState extends State<SendComponent> {
  String _barcodeString = '';
  String path = '/send';
  int accountIndex = 0;
  bool _submitting = false;
  static double sendAmount;
  final _formKey = GlobalKey<FormState>();
  String selectedPaytacaAccount;
  String sourceAccount;
  String lastBalance;
  String lBalanceSignature;
  String lBalanceTime;
  String txnID;
  String qrCode;
  static List data = List();
  bool validCode = false;
  static bool _errorFound = false;
  static String _errorMessage;
  bool online = globals.online;
  DatabaseHelper databaseHelper = DatabaseHelper();
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;
  String newVal;
  bool maxOfflineTime = globals.maxOfflineTime;
  int offlineTime = globals.offlineTime;
  bool isSenderOnline;  // Variable for marking if the sender is online or offline
  
  Future<List> getAccounts(destinationAccountId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _prefAccounts = prefs.get("accounts");
    List<Map> _accounts = [];
    for (final acct in _prefAccounts) {
      String accountId = acct.split(' | ')[1];
      if(accountId != destinationAccountId) {
        var acctObj = new Map();
        var onlineBalance = acct.split(' | ')[2];
        acctObj['accountName'] = acct.split(' | ')[0];
        acctObj['accountId'] = accountId;
        acctObj['balanceSignature'] = acct.split(' | ')[3];
        acctObj['timestamp'] = acct.split(' | ')[4];
        if (globals.online) {
          acctObj['computedBalance'] = onlineBalance;
        } else {
          var lastBalance = double.tryParse(onlineBalance);
          var resp = await databaseHelper.offlineBalanceAnalyser(accountId, lastBalance);
          acctObj['computedBalance'] = resp['computedBalance'].toString();
          acctObj['lastBalance'] = lastBalance.toString();
        }
        _accounts.add(acctObj);
      }
    }
    data = _accounts;
    return _accounts;
  }

  @override
  void initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      if (isOffline == false) {
        online = !online;
        globals.online = online;
        syncing = true;
        globals.syncing = true;
        globals.maxOfflineTime = false;
        print("Online");

        Future.delayed(Duration(milliseconds: 100), () async {
          // Set offlineTime to zero
          globals.offlineTime = 0;
          _save(globals.offlineTime);
          var val = await _read();
          print("It's online, offline timestamp is: $val");
        });

      } else {
        online = false;
        globals.online = online;
        syncing = false;
        globals.syncing = false;
        print("Offline");

        // Wrap arround Future to get the value of previous timestamp
        Future.delayed(Duration(milliseconds: 100), () async {
          // Read the previous value of offlineTime
          var prevTime = await _read();
          print("Previous offline timestamp is: $prevTime");
          if (prevTime == 0) {
            // Get timestamp and save
            globals.offlineTime = DateTime.now().millisecondsSinceEpoch;
            _save(globals.offlineTime);
            var val = await _read();
            print("Get and save a new timestamp: $val");
            globals.timeDiff = 0;
            startTimer();
          }
        });
      }
    });
  }

  // Timer for maximum offline timeout
  Timer _timer;
  int _start = 0;
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
          if (globals.online == true) {
            globals.maxOfflineTime = false;
            timer.cancel();
          } else if (_start >= 21600 - globals.timeDiff) { // (60) 1 minute, change to 21600 for 6 hours
            globals.maxOfflineTime = true;
            timer.cancel();
          } else {
            _start = _start + 1;
            globals.maxOfflineTime = false;
            print(_start);
          }
        }));
  }

  _read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'offlineTimeKey';
    final value = prefs.getInt(key) ?? 0;
    return value;
  }

  _save(val) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'offlineTimeKey';
    final value = val;
    prefs.setInt(key, value);
  }

  final TextEditingController _accountController = new TextEditingController();


  Future<bool> sendFunds(
    String toAccount,
    double amount,
    BuildContext context,
    String lBalance,
    String lSignedBalance,
    String txnID,
    String lBalanceTimeStamp) async {
    _submitting = true;
    String destinationAccount = toAccount;
    String publicKey = await globals.storage.read(key: "publicKey");
    //print("\nThe value of publicKey is: $publicKey\n");
    String privateKey = await globals.storage.read(key: "privateKey");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Mark if the sender is online or offline and include in txnhash and QRcode
    // This will be used to check in the reciever in scanning QRcode for proof of payment
    if (globals.online == true) {
      isSenderOnline = true;
    } else {
      isSenderOnline = false;
    }

    var uuid = new Uuid();
    txnID = uuid.v1().substring(0,8).toUpperCase();


    var now = new DateTime.now();
    var txnDateTime = DateTime.parse(now.toString());
    var _txnReadableDateTime = DateFormat('MMMM dd, yyyy  h:mm a').format(
        DateTime.parse(now.toString())
    );

    var txnhash = "$amount:-:$txnDateTime:-:"
    "$selectedPaytacaAccount:-:$lBalance:-:$lSignedBalance:-:$lBalanceTimeStamp:-:$txnID:-:$_txnReadableDateTime:-:$isSenderOnline";

    // For debug, comment out when done
    // print("The value of txnhash is: $txnhash");

    String signature = await signTransaction(txnhash, privateKey);
    var qrcode = "$signature:wallet:$txnhash:wallet:$publicKey";
    prefs.setString("_txnQrCode", qrcode);
    prefs.setString("_txnDateTime", _txnReadableDateTime);
    prefs.setString("_txnAmount", amount.toString());
    prefs.setString("_txnID", txnID.substring(0,8).toUpperCase());
    List<int> stringBytes = utf8.encode(qrcode);
    List<int> gzipBytes = new GZipEncoder().encode(stringBytes);
    String proofOfPayment = base64.encode(gzipBytes);
    prefs.setString("_txnProofCode", proofOfPayment);
    var payload = {
      'from_account': selectedPaytacaAccount,
      'to_account': destinationAccount,
      'asset': globals.phpAssetId,
      'amount': amount.toString(),
      'public_key': publicKey,
      'txn_hash': txnhash,
      'signature': signature,
      'transaction_id': txnID,
      'transaction_datetime': _txnReadableDateTime,
      'proof_of_payment': proofOfPayment,
    };
    var response = await transferAsset(payload);
    // Check the error response from transferAsset in endpoints.dart
    // Call the function for alert dialog
    if (response.error == "DioErrorType.CONNECT_TIMEOUT") {
      showAlertDialog(context);
      // Return null so the second alert dialog won't show
      // Weird! Not sure where is that second dialog come from
      return null;
    }
    if (response.success == false) {
      _errorFound = true;
      _errorMessage = response.error;
    } else {
      Application.router.navigateTo(context, "/proofOfPayment");
    }
    _submitting = false;
    return response.success;
  }

  void scanBarcode() async {
    allowCamera();
    String barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true);
    setState(() {
      if (barcode.length > 0) {
        _barcodeString = barcode;
      } else {
        _barcodeString = '';
      }  
    });
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
      return destinationAccountId;
    } else {
      return null;
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
        if(selectedPaytacaAccount ==  map['accountId']){
          currentBalance = map['computedBalance'];
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

   changeAccount(String newVal) {
    String accountId = newVal.split('::sep::')[0];
    String balance = newVal.split('::sep::')[1];
    String signature = newVal.split('::sep::')[2];
    String timestamp = newVal.split('::sep::')[3];

    setState(() {
      selectedPaytacaAccount = accountId;
      sourceAccount = newVal;
      lastBalance = balance;
      lBalanceSignature = signature;
      lBalanceTime = timestamp;
     // state.didChange(newVal);
    });
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

bool disableSubmitButton = false;

// Alert dialog for slow internet speed connection
// This is called in sendFunds() when there is connection timeout error response
// from transferAsset() in endpoints.dart
showAlertDialog(BuildContext context) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed:  () {
      Navigator.pop(context);
      Application.router.navigateTo(context, "/send");
    }
  );
  Widget offlineModeButton = FlatButton(
    child: Text("Switch to Offline Mode"),
    onPressed:  () {
      Navigator.pop(context);
      setOfflineMode();
      Application.router.navigateTo(context, "/send");
    }
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Slow Internet Connection!"),
    content: Text("Your internet speed connection is too slow. " 
                  "Switch to offline mode to continue making transaction."
    ),
    actions: [
      cancelButton,
      offlineModeButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void setOfflineMode() {
  globals.online = false;
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
          // When maximum offline timeout (6 hours) is true show message transaction not allowed
          globals.maxOfflineTime == true ? 
            Container(
              padding: EdgeInsets.only(top: 250),
              child: new Text(
                "You've been offline for 6 hours, transaction not allowed. Please go online ASAP!",
                textAlign: TextAlign.center,
              ),
            ) 
          : new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new ButtonTheme(
                height: 60,
                buttonColor: Colors.white,
                child: new OutlineButton(
                  borderSide: BorderSide(
                    color: Colors.black
                  ),
                  child: const Text('Scan QR Code', style: TextStyle(fontSize: 18)),
                  onPressed: scanBarcode
                )
              )
            ),
          new FutureBuilder<String>(
            future: getBarcode(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if(snapshot.hasData) {
                if (snapshot.data != null) {
                  if (snapshot.data.length > 0 ) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new SizedBox(
                          height: 20.0,
                        ),
                        Visibility(
                          child:  new FormField(
                              validator: (value){
                                if (value == null) {
                                  return 'This field is required.';
                                } else {
                                  return null;
                                }
                              },
                              builder: (FormFieldState state) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                    errorText: state.errorText,
                                    labelText: 'Select Account',
                                  ),
                                  child: new DropdownButtonHideUnderline(
                                    child: new DropdownButton(
                                      value: sourceAccount,
                                      isDense: true,
                                      onChanged: (newVal){
                                        String accountId = newVal.split('::sep::')[0];
                                        String balance = newVal.split('::sep::')[1];
                                        String signature = newVal.split('::sep::')[2];
                                        String timestamp = newVal.split('::sep::')[3];

                                        setState(() {
                                          // selectedPaytacaAccount = null;
                                          // sourceAccount = null;
                                          // lastBalance = null;
                                          // lBalanceSignature = null;
                                          // lBalanceTime = null;

                                          selectedPaytacaAccount = accountId;
                                          sourceAccount = newVal;
                                          lastBalance = balance;
                                          lBalanceSignature = signature;
                                          lBalanceTime = timestamp;
                                          state.didChange(newVal);
                                        });
                                      },
                                      items: data.length < 0 ? null : data.map((item) {
                                        return DropdownMenuItem(
                                          value: "${item['accountId']}::sep::${item['lastBalance']}::sep::${item['balanceSignature']}::sep::${item['timestamp']}",
                                          child: new Text("${item['accountName']} ( ${double.parse(item['computedBalance']).toStringAsFixed(2)} )"),
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
                              sendAmount = null;
                              sendAmount = double.parse(value);
                            },
                          ),
                          visible: snapshot.data != null
                        ),
                        new SizedBox(
                          height: 20.0,
                        ),
                        Visibility(
                          child: Container(
                            child: new ButtonTheme(
                              height: 50,
                              buttonColor: Colors.white,
                              child: new OutlineButton(
                                borderSide: BorderSide(
                                  color: Colors.black
                                ),
                                child: const Text("Pay Now", style: TextStyle(fontSize: 18)),
                                onPressed: disableSubmitButton ? null : () {
                                  var valid = _formKey.currentState.validate();
                                  if (valid) {
                                    setState(() {
                                      disableSubmitButton = true;
                                    });
                                    _formKey.currentState.save();
                                    sendFunds(
                                      snapshot.data,
                                      sendAmount,
                                      context,
                                      lastBalance,
                                      lBalanceSignature,
                                      txnID,
                                      lBalanceTime,
                                    );
                                    // Dismiss keyboard after the "Pay Now" button is click
                                    FocusScopeNode currentFocus = FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                  }
                                }
                              )
                            )
                          ),
                          visible: snapshot.data != null)
                      ],
                    );
                  } else {
                    return Container();
                  }
                }
              } else {
                return Container();
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
          Center(
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
                  _errorMessage = '';
                  _errorFound = false;
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
