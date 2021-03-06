import "package:hex/hex.dart";
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_udid/flutter_udid.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import '../app.dart';
import '../../api/endpoints.dart';
import '../../utils/dialogs.dart';
import '../../utils/globals.dart' as globals;


class Mobile {
  String number;
}

class RequestComponent extends StatefulWidget {
  @override
  RequestComponentState createState() => new RequestComponentState();
}

class RequestComponentState extends State<RequestComponent> {
  BuildContext _scaffoldContext;
  Mobile newMobile = new Mobile();
  FocusNode focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountController = new TextEditingController();
  String udid;
  String seedPhrase;
  String privateKey;
  String publicKey;
  bool _submitting = false;
  bool _showPrivateKeyInput = false;

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

  String validateMobile(String value) {
    if (value == '0000 - 000 - 0000') {
      return null;
    } else if (value.length < 11) {
      return 'Mobile number must be 11 numeric characters';
    } else {
      if (value.startsWith('09')){
        return null;
      } else {
        return 'Invalid phone number';
      }
    }
  }

  String _validateSeedPhrase(String value) {
    List seedWords = value.split(" ");
    if (seedWords.length < 12 || seedWords.length > 12) {
      return 'Seed phrase is exactly 12 words';
    }  else {
      return 'Seed phrase is not 12 words';
    }
  }

  void _validateInputs(BuildContext context) async {
    bool proceed = false;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {
        _submitting = true;
      });

      if (newMobile.number == '0000 - 000 - 0000') {
        proceed = true;
      } else {
        newMobile.number = "+63" + newMobile.number.substring(1).replaceAll(" - ", "");
        var numberPayload = {
          "mobile_number": newMobile.number,
        };
        var resp = await requestOtpCode(numberPayload);

        // Save mobile number in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('mobileNumber', newMobile.number);

        // Catch app version compatibility
        if (resp.error == "outdated_app_version") {
          showOutdatedAppVersionDialog(context);
        }
        
        if (resp.success) {
          proceed = true;
        } 
        // Catch duplicate mobile number in the error
        else if(resp.error == "duplicate_mobile_number") {
          showDuplicateMobileNumberDialog(context);
        }
      }

      if (proceed) {
        Application.router
            .navigateTo(context, "/onboarding/verify/${newMobile.number}");
      }
    } else {
      _showSnackBar("Please correct errors in the form");
    }
  }

  Future<Null> _validateSeedPhraseInput(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {
        _submitting = true;
      });

      // Generate using the flutter_udid library
      udid = await FlutterUdid.consistentUdid;
      print("The value of udid in generateUdid() in register.dart is: $udid");
      // Store UDID in global storage
      await globals.storage.write(key: "udid", value: udid);

      // Decode private & public keys through seed phrase
      var seed = bip39.mnemonicToSeed(seedPhrase, 32);

      // Generate private and public keys from seed
      Sodium.cryptoSignSeedKeypair(seed).then((value) {
        publicKey = HEX.encode(value['pk']);
        privateKey = HEX.encode(value['sk']);
      });

      // Added delay to catch the public & private keys values
      await Future.delayed(Duration(seconds: 5));

      // Store private and public keys in global storage
      await globals.storage.write(key: "publicKey", value: publicKey);
      await globals.storage.write(key: "privateKey", value: privateKey);

      // Create payload
      var payload = {
        "public_key": publicKey,
      };
      // Send public key as payload to restore user
      var resp = await requestOTPAccountRestore(payload);

        // Catch app version compatibility
      if (resp.error == "outdated_app_version") {
        showOutdatedAppVersionDialog(context);
      }

      // Show dialog if no found public key match
      if (resp.error == "public_key_not_found") {
        showPublicKeyNotFoundDialog(context);
        _accountController.clear();
        setState(() {
          _submitting = false;
        });
      }
      
      if (resp.success) {
        // Mark installed to true 
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('installed', true);

        Application.router
          .navigateTo(context, "/requestotp/${resp.mobileNumber}");
        databaseHelper.initializeDatabase();

        setState(() {
          _submitting = false;
        });
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

  void _privateKeyInput() {
    setState(() {
      if (_showPrivateKeyInput) {
        _showPrivateKeyInput = false;
      } else {
        _showPrivateKeyInput = true;
      } 
    });
    // Dismiss the keyboard after clicking the button
    FocusScope.of(context).requestFocus(FocusNode());
  }

  List<Widget> _buildMobileNumberForm(BuildContext context) {
    Form form = Form(
      key: _formKey,
      autovalidate: false,
      child: Center(
        child: Container(
          alignment: Alignment.topCenter,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[
              _showPrivateKeyInput ?
                Column(
                  children: <Widget>[
                    SizedBox(height: 30.0,),
                    Center(
                      child: Text(
                        "Restore from Seed Phrase",
                        style: TextStyle(
                        fontSize: 24.0,
                        ),
                        textAlign: TextAlign.center,
                      )
                    ),
                    SizedBox(height: 10.0,),
                    TextFormField(
                      controller: _accountController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.multiline,
                      validator: _validateSeedPhrase,
                      autofocus: false,
                      onSaved: (value) {
                        seedPhrase = value;
                      },
                      //maxLength: 148,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'RobotoMono',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Type or paste the seed phrase here',
                        hintStyle: TextStyle(
                          fontSize: 15.0
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0,),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.red,
                        splashColor: Colors.red[100],
                        onPressed: () {
                          _validateSeedPhraseInput(context);
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white,),
                        ),
                      ),
                    ),
                    SizedBox(height: 25.0,),
                  ]
                )
              :
                Column(
                  children: <Widget>[
                    SizedBox(height: 30.0,),
                    Center(
                      child: Text(
                        "Mobile Number Verification",
                        style: TextStyle(
                        fontSize: 24.0,
                        )
                      )
                    ),
                    SizedBox(height: 10.0,),
                    TextFormField(
                      controller: _accountController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.phone,
                      validator: validateMobile,
                      autofocus: true,
                      onSaved: (value) {
                        newMobile.number = value;
                      },
                      maxLength: 11,
                      style: TextStyle(
                        fontSize: 24.0
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter Mobile Number',
                        hintStyle: TextStyle(
                          fontSize: 15.0
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0,),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.red,
                        splashColor: Colors.red[100],
                        onPressed: () {
                          _validateInputs(context);
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white,),
                        ),
                      ),
                    ),
                    SizedBox(height: 25.0,),
                  ]
                ),
              _showPrivateKeyInput ?
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Cancel? ",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Back to Mobile Number Input.",
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                        recognizer: TapGestureRecognizer()..onTap = () =>_privateKeyInput(),
                      )
                    ],
                  ),
                )
              :
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Do you already have an account? ",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Restore an account.",
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                        recognizer: TapGestureRecognizer()..onTap = () =>_privateKeyInput(),
                      )
                    ],
                  ),
                )
            ]
          )
        )
      )
    );

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
        ),      // if (newMobile.number == '0000 - 000 - 0000') {
      //   proceed = true;
      // } else {
      //   newMobile.number = "+63" + newMobile.number.substring(1).replaceAll(" - ", "");
        body: Builder(builder: (BuildContext context) {
          _scaffoldContext = context;
          return Stack(children: _buildMobileNumberForm(context));
        }
      )
    );
  }
}
