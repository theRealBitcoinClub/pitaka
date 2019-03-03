import 'package:flutter/material.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import "package:hex/hex.dart";
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:async';
import '../app.dart';
import '../../api/endpoints.dart';
import '../../helpers.dart';

class User {
  String firstName;
  String lastName;
  String emailAddress;
  String mobileNumber;
  DateTime birthDate;
}

class RegisterComponent extends StatefulWidget {
  @override
  RegisterComponentState createState() => new RegisterComponentState();
}

class RegisterComponentState extends State<RegisterComponent> {
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

  Future<Null> _authenticate() async {
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
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
    await FlutterKeychain.put(key: "publicKey", value: publicKey);
    await FlutterKeychain.put(key: "privateKey", value: privateKey);
  }

  final _formKey = GlobalKey<FormState>();
  User newUser = new User();

  String validateName(String value) {
    if (value.length < 3)
      return 'Name must be more than 2 charater';
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

  String validateMobile(String value) {
    if (value.length != 11)
      return 'Mobile Number must be of 11 digits';
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

  final TextEditingController _birthDateController =
      new TextEditingController();
  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(1900),
        lastDate: new DateTime.now());

    if (result == null) return;

    setState(() {
      _birthDateController.text = new DateFormat.yMd().format(result);
    });
  }

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

  bool _autoValidate = false;
  bool _submitting = false;

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

          String signature = await signTransaction("helloworld", privateKey);
          var userPayload = {
            "firstname": newUser.firstName,
            "lastname": newUser.lastName,
            "birthday": "2006-01-02",
            "email": newUser.emailAddress,
            "mobilenumber": newUser.mobileNumber,
            "public_key": publicKey,
            "txn_hash": "helloworld",
            "signature": signature
          };
          var user = await createUser(userPayload);
          await FlutterKeychain.put(key: "userId", value: user.id);

          // Login
          String loginSignature =
              await signTransaction("hello world", privateKey);
          var loginPayload = {
            "public_key": publicKey,
            "session_key": "hello world",
            "signature": loginSignature,
          };
          await loginUser(loginPayload);

          Application.router.navigateTo(context, "/account");
        }
      } else {
        _showSnackBar("Please agree to our Terms and Conditions");
      }
    } else {
      _showSnackBar("Please correct errors in the form");
      // If any data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
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
        autovalidate: _autoValidate,
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
              new TextFormField(
                keyboardType: TextInputType.phone,
                validator: validateMobile,
                onSaved: (value) {
                  newUser.mobileNumber = value;
                },
                decoration: const InputDecoration(
                  icon: const Icon(Icons.phone),
                  hintText: 'Enter your mobile number',
                  labelText: 'Mobile Number',
                ),
              ),
              new GestureDetector(
                  onTap: () {
                    _chooseDate(context, _birthDateController.text);
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
