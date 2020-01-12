import 'package:flutter/material.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import "package:hex/hex.dart";
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:async';
import '../app.dart';
import '../../api/endpoints.dart';
import '../../utils/helpers.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:pitaka/utils/database_helper.dart';
import '../../utils/globals.dart' as globals;
import 'package:passcode_screen/passcode_screen.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:easy_dialog/easy_dialog.dart';
import '../../utils/dialog.dart';


class User {
  String firstName;
  String lastName;
  String emailAddress;
  DateTime birthDate;
  String imei;
}

class RegisterComponent extends StatefulWidget {
  final String mobileNumber;
  RegisterComponent({Key key, this.mobileNumber}) : super(key: key);
  @override
  RegisterComponentState createState() => new RegisterComponentState();
}

class RegisterComponentState extends State<RegisterComponent> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  String iniPasscode = '';
  bool checkBiometrics = false;
  String mobileNumber = "";

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(interceptBackButton);
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

  final LocalAuthentication auth = LocalAuthentication();
  bool authenticated = false;
  // final StreamController<bool> _verificationNotifier =
  // StreamController<bool>.broadcast();

  Future<Null> _authenticate() async {
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // TODO - Automatically authenticate if the phone does not have fingerprint auth
        // Change this later to custom PIN code authentication
        authenticated = true;
      }
    }
    if (!mounted) return;
  }

  String publicKey;
  String privateKey;

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

  final _formKey = GlobalKey<FormState>();
  User newUser = new User();

  String validateName(String value) {
    if (value.length < 2)
      return 'Name must be at least 2 characters';
    else
      return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
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

  final TextEditingController _birthDateController = new TextEditingController();

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  BuildContext _scaffoldContext;
  FocusNode focusNode = FocusNode();
  bool _termsChecked = false;
  bool _submitting = false;

  var circleUIConfig = new CircleUIConfig();
  var keyboardUIConfig = new KeyboardUIConfig();

  onDialogClose() {
    // Not use
  }

  // Alert dialog for duplicate email address
  showAlertDialog() {
    EasyDialog(
      title: Text(
        "Duplicate Email Address!",
        style: TextStyle(fontWeight: FontWeight.bold),
        textScaleFactor: 1.2,
      ),
      description: Text(
        "The email address is already registered. Please use other email address",
        textScaleFactor: 1.1,
        textAlign: TextAlign.center,
      ),
      height: 160,
      closeButton: false,
      contentList: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FlatButton(
              padding: EdgeInsets.all(8),
              textColor: Colors.lightBlue,
              onPressed: () {
                Navigator.of(context).pop();
                // Use same mobile number after retry on duplicate email 
                Application.router.navigateTo(context, "/onboarding/register/$mobileNumber");
              },
              child: new Text("OK",
                textScaleFactor: 1.2,
                textAlign: TextAlign.center,
              ),),
           ],)
      ]
    ).show(context, onDialogClose);
  }

  void _validateInputs(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());

      if (_termsChecked) {
        // If all data are correct then save data to out variables
        _formKey.currentState.save();
        await generateKeyPair(context);

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
            "email": newUser.emailAddress,
            "mobile_number": mobileNumber,
          };
          String txnHash = generateTransactionHash(userPayload);
          print(txnHash);
          String signature = await signTransaction(txnHash, privateKey);

          userPayload["public_key"] = publicKey;
          userPayload["txn_hash"] = txnHash;
          userPayload["signature"] = signature;
          var user = await createUser(userPayload);
          
          // Catch duplicate email address in the error
          if (user.error == "duplicate_email") {
            showAlertDialog();
          }

          // Catch app version compatibility
          if (user.error == "outdated_app_version") {
            showOutdatedAppVersionDialog(context);
          }
          
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
        new SnackBar(content: new Text(message), backgroundColor: Colors.red);
    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
  }

  List<Widget> _buildRegistrationForm(BuildContext context) {
    Form form = new Form(
        key: _formKey,
        autovalidate: false,
        child: new ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              new SizedBox(
                height: 30.0,
              ),
              new Center(
                  child: new Text("Sign up to create your wallet",
                      style: TextStyle(
                        fontSize: 20.0,
                      ))),
              new SizedBox(
                height: 10.0,
              ),
              new TextFormField(
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
              new TextFormField(
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
              new TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
                onSaved: (value) {
                  newUser.emailAddress = value;
                },
                decoration: const InputDecoration(
                  icon: const Icon(Icons.email),
                  hintText: 'Enter your email address',
                  labelText: 'Email address',
                ),
              ),
              new GestureDetector(
                  onTap: () {
                    DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      onChanged: (date) {},
                      onConfirm: (date) {
                        setState(() {
                          _birthDateController.text = new DateFormat.yMd().format(date);
                        });
                      },
                      currentTime: DateTime.now(),
                      locale: LocaleType.en
                    );
                  },
                  behavior: HitTestBehavior.translucent,
                  child: new Container(
                    child: new IgnorePointer(
                      child: new TextFormField(
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
              new SizedBox(
                height: 20.0,
              ),
              new CheckboxListTile(
                  title: new GestureDetector(
                      onTap: () {
                        Application.router.navigateTo(context, "/terms");
                      },
                      child: new RichText(
                          text: new TextSpan(children: <TextSpan>[
                        new TextSpan(
                          text: 'Check the box to agree to our ',
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                        ),
                        new TextSpan(
                          text: 'Terms and Conditions',
                          style: new TextStyle(
                            color: Colors.blue,
                            fontSize: 16.0,
                          ),
                        )
                      ]))),
                  value: _termsChecked,
                  onChanged: (bool value) =>
                      setState(() => _termsChecked = value)),
              new SizedBox(
                height: 15.0,
              ),
              new RaisedButton(
                onPressed: () {
                  _validateInputs(context);
                },
                child: new Text('Submit'),
              )
            ]));

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

    return ws;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Welcome to Paytaca"),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: new Builder(builder: (BuildContext context) {
          _scaffoldContext = context;
          return new Stack(children: _buildRegistrationForm(context));
        }));
  }
}
