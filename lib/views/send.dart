import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../api/endpoints.dart';
import '../views/app.dart';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import '../utils/helpers.dart';
import '../utils/globals.dart' as globals;
import '../utils/database_helper.dart';
import '../utils/globals.dart';
import '../utils/dialog.dart';


class SendComponent extends StatefulWidget {
  @override
  SendComponentState createState() => new SendComponentState();
}

class SendComponentState extends State<SendComponent> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  StreamSubscription _connectionChangeStream;
  static bool _errorFound = false;
  static String _errorMessage;
  static double sendAmount;
  static List data = List();
  final _formKey = GlobalKey<FormState>();
  String _barcodeString = '';
  String path = '/send';
  String selectedPaytacaAccount;
  String _sourceAccount;
  String lastBalance;
  String lBalanceSignature;
  String lBalanceTime;
  String txnID;
  String qrCode;
  String toAccount;
  String destinationAccountId;
  String newVal;
  bool validCode = false;
  bool online = globals.online;
  bool isOffline = false;
  bool maxOfflineTime = globals.maxOfflineTime;
  bool isSenderOnline;  // Variable for marking if the sender is online or offline
  bool _isInternetSlow = false;
  bool _showForm = false;
  bool _isMaintenanceMode = false;
  bool disableSubmitButton = false;
  bool _submitting = false;
  bool _isScanningQr = false;
  int accountIndex = 0;
  int offlineTime = globals.offlineTime;

  @override
  void initState() {
    super.initState();
    // Subscribe to Notifier Stream from ConnectionStatusSingleton class in globals.dart
    // Fires whenever connectivity state changes
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);

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

  @override
  void dispose() {
    super.dispose();
  }

  Future<List> getAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _prefAccounts = prefs.get("accounts");
    List<Map> _accounts = [];

    if (_isScanningQr) {
      destinationAccountId = _barcodeString.split('::paytaca::')[1];
    }
    else {
      destinationAccountId = "";
    }

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
      })
    );
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

  Future<bool> sendFunds(
    String toAccount,
    double amount,
    BuildContext context,
    String lBalance,
    String lSignedBalance,
    String txnID,
    String lBalanceTimeStamp) async {

    _submitting = true;
    // Get keypair from global storage
    String publicKey = await globals.storage.read(key: "publicKey");
    String privateKey = await globals.storage.read(key: "privateKey");
    // Create fresh UDID from flutter_udid library
    String udid = await FlutterUdid.consistentUdid;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    toAccount = destinationAccountId;

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
    var _txnReadableDateTime = DateFormat("yyyy/MM/dd HH:mm a").format(
      DateTime.parse(now.toString())
    );

    // Create the transaction string
    var txnstr = "$amount:-:$txnDateTime:-:"
      "$selectedPaytacaAccount:-:$lBalance:-:$lSignedBalance:-:$lBalanceTimeStamp:-:"
      "$txnID:-:$_txnReadableDateTime:-:$isSenderOnline";
    // Create the transaction hash
    var bytes = utf8.encode(txnstr);
    var txnhash = sha256.convert(bytes).toString();

    print("The value of txnhash in sendFund() in send.dart is: $txnhash");
    
    String signature = await signTransaction(txnhash, privateKey);

    var qrcode = "$txnhash||$signature||$txnstr||$publicKey";
    prefs.setString("_txnQrCode", qrcode);
    prefs.setString("_txnDateTime", _txnReadableDateTime);
    prefs.setString("_txnAmount", amount.toString());
    prefs.setString("_txnID", txnID.substring(0,8).toUpperCase());
    List<int> stringBytes = utf8.encode(qrcode);
    List<int> gzipBytes = new GZipEncoder().encode(stringBytes);
    String proofOfPayment = base64.encode(gzipBytes);
    prefs.setString("_txnProofCode", proofOfPayment);
    // Create the payload
    var payload = {
      'from_account': selectedPaytacaAccount,
      'to_account': toAccount,
      'asset': globals.phpAssetId,
      'amount': amount.toString(),
      'public_key': publicKey,
      'txn_hash': txnhash,
      'signature': signature,
      'transaction_id': txnID,
      'transaction_datetime': _txnReadableDateTime,
      'proof_of_payment': proofOfPayment,
      'txn_str' : txnstr,
      'device_id': udid,
    };

    var response = await transferAsset(payload);

    // Catch invalid device ID error
    if (response.error == "invalid_device_id") {
      showUnregisteredUdidDialog(context);
    }

    // Catch app version compatibility
    if (response.error == "outdated_app_version") {
      showOutdatedAppVersionDialog(context);
    }
    // Check if server is in maintenance mode
    if (response.error == "maintenance_mode") {
      _isMaintenanceMode = true;
    }
    // Check the error response from transferAsset in endpoints.dart
    // Call the function for alert dialog
    if (response.error == "DioErrorType.CONNECT_TIMEOUT") {
      setState(() {
        _isInternetSlow = true;
        _submitting = false;
      });
      // showAlertDialog(context);
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
    _isScanningQr = true;
    _showForm = true;
    allowCamera();
    String barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.DEFAULT);
    setState(() {
      if (barcode.length > 0) {
        _barcodeString = barcode;
      } else {
        _barcodeString = '';
      }  
    });

    // Don't show form if barcode sacnner is cancelled
    if (barcode == "-1") {
      _showForm = false;
    }
    
    getAccounts();
  }

  void allowCamera() async {
    var permission = PermissionHandler();
    PermissionStatus cameraStatus = await permission.checkPermissionStatus(PermissionGroup.camera);
    if (cameraStatus == PermissionStatus.denied) {
          await permission.requestPermissions([PermissionGroup.camera]);
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

  List<Widget> _buildForm(BuildContext context) {
    // Added the code below for the display error during sending offline
    if (!globals.online) {
      getAccounts();
    }
    Form form = new Form(
      key: _formKey,
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new SizedBox(
            height: 30.0,
          ),
          // When server is under maintenance show this message
          _isMaintenanceMode ?
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 250),
              child: Text(
                "Server is down for maintenance. " 
                "Please try again later or switch your phone to Airplane mode to keep using the app in offline mode.",
                textAlign: TextAlign.center,
              ), 
            )
          : // Another condition
          // When maximum offline timeout (6 hours) is true show message transaction not allowed
          globals.maxOfflineTime == true ? 
            Container(
              padding: EdgeInsets.only(top: 250),
              child: new Text(
                "You've been offline for 6 hours, transaction not allowed. Please go online ASAP!",
                textAlign: TextAlign.center,
              ),
            )
          :  
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Visibility(
                child: Container(
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
                visible: !_showForm,
              ),
              Visibility(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                  child: Text(
                    "OR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ),
                visible: !_showForm,
              ),
              Visibility(
                child: Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: new ButtonTheme(
                    height: 60,
                    buttonColor: Colors.white,
                    child: new OutlineButton(
                      borderSide: BorderSide(
                        color: Colors.black
                      ),
                      child: const Text('Send through Contact', style: TextStyle(fontSize: 18)),
                      onPressed: () => Application.router.navigateTo(context, "/contactlist")
                    )
                  )
                ),
                visible: !_showForm,
              ),
            ]
          ),
          _showForm ?
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new SizedBox(
                  height: 20.0,
                ),
                Visibility(
                  child: new FormField(
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
                        ),
                        child: new DropdownButtonHideUnderline(
                          child: new DropdownButton(
                            hint: Text('Select Account'),
                            iconEnabledColor: Colors.red,
                            value: _sourceAccount,
                            isDense: true,
                            onChanged: (newVal){
                              String accountId = newVal.split('::sep::')[0];
                              String balance = newVal.split('::sep::')[1];
                              String signature = newVal.split('::sep::')[2];
                              String timestamp = newVal.split('::sep::')[3];
                              setState(() {
                                selectedPaytacaAccount = accountId;
                                lastBalance = balance;
                                lBalanceSignature = signature;
                                lBalanceTime = timestamp;
                                _sourceAccount = newVal;
                                state.didChange(newVal);
                              });
                            },
                            items: data.map((item) {
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
                  visible: data != null,
                ),
                Visibility(
                  child: new TextFormField(
                    validator: validateAmount,
                    decoration: new InputDecoration(labelText: "Enter the amount"),
                    keyboardType: TextInputType.phone,
                    onSaved: (value) {
                      sendAmount = null;
                      sendAmount = double.parse(value);
                    },
                  ),
                  visible: data != null,
                ),
                _isInternetSlow ?
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "You don't seem to have internet connection, or it's too slow. " 
                      "Switch your phone to Airplane mode to keep using the app in offline mode.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  )
                :
                new Container(),
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
                              toAccount,
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
                  visible: data != null,
                )
              ]
            )
            :
            Container()
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
