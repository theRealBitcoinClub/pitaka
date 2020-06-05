import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import "package:hex/hex.dart";
import 'package:intl/intl.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:pitaka/utils/database_helper.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import '../app.dart';
import '../../api/endpoints.dart';
import '../../utils/helpers.dart';
import '../../utils/dialogs.dart';
import '../../utils/globals.dart' as globals;


class User {
  String firstName;
  String lastName;
  DateTime birthDate;
  String imei;
  String udid;
  String token;
}

class RegisterComponent extends StatefulWidget {
  final String mobileNumber;
  RegisterComponent({Key key, this.mobileNumber}) : super(key: key);
  @override
  RegisterComponentState createState() => new RegisterComponentState();
}

class RegisterComponentState extends State<RegisterComponent> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  User newUser = new User();
  FocusNode focusNode = FocusNode();
  BuildContext _scaffoldContext;
  final _formKey = GlobalKey<FormState>();
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _birthDateController = new TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var circleUIConfig = new CircleUIConfig();
  var keyboardUIConfig = new KeyboardUIConfig();
  String udid;
  String publicKey;
  String privateKey;
  String iniPasscode = '';
  String mobileNumber = "";
  bool _submitting = false;
  bool authenticated = false;
  bool _termsChecked = false;
  bool checkBiometrics = false;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(interceptBackButton);
    generateToken();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(interceptBackButton);
    super.dispose();
  }

  bool interceptBackButton(bool stopDefaultButtonEvent) {
    print("Back navigation blocked!");
    return true;
  }

  Future<Null> _authenticate() async {
    try {
      authenticated = await auth.authenticateWithBiometrics(
        localizedReason: 'Scan your fingerprint to authenticate',
        useErrorDialogs: true,
        stickyAuth: false);
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        authenticated = true;
      }
    }
    if (!mounted) return;
  }

  Future<Null> generateKeyPair(BuildContext context) async {
    final keyPair = await CryptoSign.generateKeyPair();

    Uint8List publicKeyBytes = keyPair.publicKey;
    Uint8List privateKeyBytes = keyPair.secretKey;
    publicKey = HEX.encode(publicKeyBytes);
    privateKey = HEX.encode(privateKeyBytes);

    await _authenticate();
    await globals.storage.write(key: "publicKey", value: publicKey);
    await globals.storage.write(key: "privateKey", value: privateKey);
  }

  // Generate UDID to be stored
  Future<Null> generateUdid(BuildContext context) async {
    // Generate using the flutter_udid library
    udid = await FlutterUdid.consistentUdid;
    print("The value of udid in generateUdid() in register.dart is: $udid");
    // Store UDID in global storage
    await globals.storage.write(key: "udid", value: udid);
  }

  // Generate firebase messaging token
  void generateToken() async {
    // Get device token
    _firebaseMessaging.getToken().then((token) {
    print("The value of token in generateToken() in register.dart is: $token");

    // Store token in global storage
    globals.storage.write(key: "token", value: token);
    });
  }

  String validateName(String value) {
    if (value.length < 2)
      return 'Name must be at least 2 characters';
    else
      return null;
  }

  String validateBirthdate(String value) {
    var formattedBirthDate = convertToDate(_birthDateController.text);
    if (formattedBirthDate == null)
      return 'Birthdate is required';
    else
      return null;
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  void _validateInputs(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());

      if (_termsChecked) {
        // If all data are correct then save data to out variables
        _formKey.currentState.save();
        // Generate KeyPair, UDID and Firebase token
        await generateKeyPair(context);
        await generateUdid(context);

        if (authenticated == true) {
          setState(() {
            _submitting = true;
          });
          
          // Get the mobile number from previous route parameter
          mobileNumber = "${widget.mobileNumber}";

          var userPayload = {
            "firstname": newUser.firstName,
            "lastname": newUser.lastName,
            "birthday": "2006-01-02",
            "mobile_number": mobileNumber,
          };

          String txnHash = generateTransactionHash(userPayload);
          String signature = await signTransaction(txnHash, privateKey);
          String token = await globals.storage.read(key: "token");

          userPayload["public_key"] = publicKey;
          userPayload["txn_hash"] = txnHash;
          userPayload["signature"] = signature;
          userPayload["device_id"] = udid;
          userPayload["firebase_messaging_token"] = token;

          var user = await createUser(userPayload);

          // Catch app version compatibility
          if (user.error == "outdated_app_version") {
            showOutdatedAppVersionDialog(context);
          }
          // Store user ID in global storage
          await globals.storage.write(key: "userId", value: user.id);
          // Login
          String loginSignature =
            await signTransaction("hello world", privateKey);
          var loginPayload = {
            "public_key": publicKey,
            "session_key": "hello world",
            "signature": loginSignature,
          };
          await loginUser(loginPayload);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('installed', true);
          Application.router.navigateTo(context, "/addpincode");
          databaseHelper.initializeDatabase();

          // Show dialog for taking note of private key
          savePrivatePublicKeyDialog(context);

        }
      } else {
        _showSnackBar("Please agree to our Terms and Conditions");
      }
    } else {
      _showSnackBar("Please correct errors in the form");
    }
  }

  void _showSnackBar(String message) {
    final snackBar =
        SnackBar(content: new Text(message), backgroundColor: Colors.red);
    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
  }

  List<Widget> _buildRegistrationForm(BuildContext context) {
    Form form = Form(
        key: _formKey,
        autovalidate: false,
        child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              SizedBox(height: 30.0,),
              Center(
                  child: Text("Sign up to create your wallet",
                      style: TextStyle(
                        fontSize: 20.0,
                      ))),
              SizedBox(height: 10.0,),
              TextFormField(
                keyboardType: TextInputType.text,
                validator: validateName,
                onSaved: (value) {
                  newUser.firstName = value;
                },
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person_outline),
                  hintText: 'Enter your first name',
                  labelText: 'First Name',
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                validator: validateName,
                onSaved: (value) {
                  newUser.lastName = value;
                },
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person),
                  hintText: 'Enter your last name',
                  labelText: 'Last Name',
                ),
              ),
              GestureDetector(
                  onTap: () {
                    DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      onChanged: (date) {},
                      onConfirm: (date) {
                        setState(() {
                          _birthDateController.text = DateFormat.yMd().format(date);
                        });
                      },
                      currentTime: DateTime.now(),
                      locale: LocaleType.en
                    );
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    child: IgnorePointer(
                      child: TextFormField(
                          controller: _birthDateController,
                          focusNode: focusNode,
                          keyboardType: TextInputType.text,
                          validator: validateBirthdate,
                          onSaved: (value) {
                            newUser.birthDate =
                                convertToDate(_birthDateController.text);
                          },
                          decoration: const InputDecoration(
                            icon: const Icon(Icons.calendar_today),
                            hintText: 'Enter your birthdate',
                            labelText: 'Birthdate',
                          )),
                    ),
                  )),
              SizedBox(height: 20.0,),
              CheckboxListTile(
                  title: GestureDetector(
                      onTap: () {
                        Application.router.navigateTo(context, "/terms");
                      },
                      child: RichText(
                          text: TextSpan(children: <TextSpan>[
                        TextSpan(
                          text: 'Check the box to agree to our ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                        ),
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16.0,
                          ),
                        )
                      ]))),
                  value: _termsChecked,
                  onChanged: (bool value) =>
                      setState(() => _termsChecked = value)),
              SizedBox(height: 15.0,),
              RaisedButton(
                color: Colors.red,
                splashColor: Colors.red[100],
                onPressed: () {
                  _validateInputs(context);
                },
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white,),
                ),
              )
            ]));

    var ws = List<Widget>();
    ws.add(form);

    if (_submitting) {
      var modal = Stack(
        children: [
          Opacity(
            opacity: 0.8,
            child: const ModalBarrier(dismissible: false, color: Colors.grey),
          ),
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      );
      ws.add(modal);
    }

    return ws;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Paytaca"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        _scaffoldContext = context;
        return Stack(children: _buildRegistrationForm(context));
      })
    );
  }
}
