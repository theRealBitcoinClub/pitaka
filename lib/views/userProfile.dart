import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../views/app.dart';
import '../api/endpoints.dart';
import '../utils/helpers.dart';
import '../utils/globals.dart';
import '../utils/dialogs.dart';
import '../utils/database_helper.dart';
import '../utils/globals.dart' as globals;


class UserProfileComponent extends StatefulWidget {
  @override
  UserProfileComponentState createState() => new UserProfileComponentState();
}

class UserProfileComponentState extends State<UserProfileComponent> {
  StreamSubscription _connectionChangeStream;
  DatabaseHelper databaseHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountController = new TextEditingController();
  static bool _errorFound = false;
  static String _errorMessage;
  String newVal;
  String sessionKey = '';
  bool isOffline = false;
  bool _submitting = false;
  bool online = globals.online;
  bool disableSubmitButton = false;
  bool maxOfflineTime = globals.maxOfflineTime;
  int offlineTime = globals.offlineTime;

  Future<Map> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var firstName = prefs.getString('firstName');
    var lastName = prefs.getString('lastName');
    var mobileNumber = prefs.getString('mobileNumber');
    var mobileNumPart1 = mobileNumber.substring(3, 6);
    var mobileNumPart2 = mobileNumber.substring(6, 9);
    var mobileNumPart3 = mobileNumber.substring(9);
    var user = {
      'name': '$firstName $lastName',
      'initials': '${firstName[0]}${lastName[0]}'.toUpperCase(),
      'mobile_number': '0$mobileNumPart1 $mobileNumPart2 $mobileNumPart3'
    };
    return user;
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
    String barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true,  ScanMode.DEFAULT);
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
          title: Text('User Profile'),
          centerTitle: true,
          leading: IconButton(icon:Icon(Icons.arrow_back),
            onPressed:() => Navigator.pop(context, false),
          ),
        ),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildForm(context));
        }),
      );
  }

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
    Form form = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          // When maximum offline timeout (6 hours) is true show message transaction not allowed
          online == false ? 
            Container(
              padding: EdgeInsets.only(top: 250),
              child: new Text(
                "You're offline, authentication is not possible!",
                textAlign: TextAlign.center,
              ),
            ) 
          : Column( 
            children: <Widget>[
              Container(
                child: Text(
                  'PERSONAL INFO',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                alignment: Alignment.centerLeft,
                height: 30.0,
              ),
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.red,
                        ),
                        child: Container(
                          height: 100.0,
                        )
                      ),
                      Container(
                        height: 20.0
                      )
                    ],
                  ),
                  Column(
                    children:<Widget>[
                      Container(
                        height: 50.0
                      ),
                      Center(
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          maxRadius: 35.0,
                          child: new Image.asset(
                            'assets/images/default_profile_pic.png',
                          ), 
                        ),
                      )
                    ]
                  )
                ],
              ),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.body1,
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Icon(Icons.edit),
                      ),
                    ),
                    TextSpan(text: 'EDIT PROFILE'),
                  ],
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'NAME',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 5.0),
                  Text('JESUS CABRELLOS TAGANNA'),
                  SizedBox(height: 8.0),
                  Divider(color: Colors.grey,), 
                  SizedBox(height: 8.0),
                  Text(
                    'BIRTH DATE',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 5.0),
                  Text('03-29-1977'),
                  SizedBox(height: 8.0),
                  Divider(color: Colors.grey,),
                  SizedBox(height: 8.0),
                  Text(
                    'EMAIL',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 5.0),
                  Text('JTAGANNA@YAHOO.COM'),
                  SizedBox(height: 8.0),
                  Divider(color: Colors.grey,),
                  SizedBox(height: 8.0),
                  Text(
                    'CURRENT ADDRESS',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 5.0),
                  Text(''),
                  SizedBox(height: 8.0),
                  Divider(color: Colors.grey,),
                ]
              ),
              SizedBox(
                height: 30.0,
              ),
              // Button for registering email
              Visibility(
                visible: true,
                child: SizedBox(
                  width: double.infinity,
                  child: FlatButton.icon(
                    color: Colors.red,
                    icon: Icon(
                      Icons.email,
                      color: Colors.white,
                    ),
                    label: Text(
                      'REGISTER AN EMAIL',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      //Code to execute when Floating Action Button is clicked
                      //...
                    },
                  ),
                ),
              ),
              // Button for confirming email
              Visibility(
                visible: false,
                child: SizedBox(
                  width: double.infinity,
                  child: FlatButton.icon(
                    color: Colors.red,
                    icon: Icon(
                      Icons.contact_mail,
                      color: Colors.white,
                    ),
                    label: Text(
                      'VERIFY EMAIL',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      //Code to execute when Floating Action Button is clicked
                      //...
                    },
                  ),
                ),
              ),
              // Button for verifying identity
              Visibility(
                visible: false,
                child: SizedBox(
                  width: double.infinity,
                  child: FlatButton.icon(
                    color: Colors.red,
                    icon: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    label: Text(
                      'VERIFY IDENTITY',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      //Code to execute when Floating Action Button is clicked
                      //...
                    },
                  ),
                )
              )
            ]
            )
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
