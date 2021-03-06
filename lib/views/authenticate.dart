import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../components/bottomNavigation.dart';
import '../components/drawer.dart';
import '../api/endpoints.dart';
import '../views/app.dart';
import '../utils/helpers.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/globals.dart' as globals;
import '../utils/database_helper.dart';
import '../utils/globals.dart';
import '../utils/dialogs.dart';


class AuthenticateComponent extends StatefulWidget {
  @override
  AuthenticateComponentState createState() => new AuthenticateComponentState();
}

class AuthenticateComponentState extends State<AuthenticateComponent> {
  String path = '/send';
  bool _submitting = false;
  final _formKey = GlobalKey<FormState>();
  static bool _errorFound = false;
  static String _errorMessage;
  bool online = globals.online;
  DatabaseHelper databaseHelper = DatabaseHelper();
  bool isOffline = false;
  String newVal;
  bool maxOfflineTime = globals.maxOfflineTime;
  int offlineTime = globals.offlineTime;

  String sessionKey = '';

  

  @override
  void initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    connectionStatus.connectionChange.listen(connectionChanged);
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
      } else {
        online = false;
        globals.online = online;
        syncing = false;
        globals.syncing = false;
        print("Offline");
      }
    });
  }

  Future<bool> sendAuthentication() async {
    // Set _submitting to true for progress indicator to display while sending the request
    _submitting = true;
    // Get private and public key
    String publicKey = await globals.storage.read(key: "publicKey");
    String privateKey = await globals.storage.read(key: "privateKey");
    // Sign the sessionKey scanned from barcode with the private key
    String signature = await signTransaction(sessionKey, privateKey);
    // Create the payload
    var payload = {
      'session_key': sessionKey,
      'public_key': publicKey,
      'signature': signature,
      'app_version': globals.appVersion,
    };
    // Call authWebApp() from endpoints.dart
    var response = await authWebApp(payload);

    // Catch app version compatibility
    if (response.error == "outdated_app_version") {
      showOutdatedAppVersionDialog(context);
    }

    // Check the error response from authWebApp in endpoints.dart
    // Call the function for alert dialog
    if (response.error == "request_error") {
      showAlertDialog(context);
      // Return null so the second alert dialog won't show
      return null;
    }
    if (response.success == false) {
      _errorFound = true;
      _errorMessage = response.error;
    } else {
      Application.router.navigateTo(context, "/home");
    }
    // Set _submitting to false after sending the request and return the response
    _submitting = false;
    return response.success;
  }

  void scanBarcode() async {
    allowCamera();
    String barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true);
    setState(() {
      if (barcode.length > 0) {
        sessionKey = barcode;
        sendAuthentication();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Authenticate'),
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
  Widget okButton = FlatButton(
    child: Text("Try again"),
    onPressed:  () {
      Navigator.pop(context);
      Application.router.navigateTo(context, "/authenticate");
    }
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Request Failure!"),
    content: Text("There was an error in sending the request!"
    ),
    actions: [
      okButton,
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
          online == false ? 
            Container(
              padding: EdgeInsets.only(top: 250),
              child: new Text(
                "You're offline, authentication is not possible!",
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
