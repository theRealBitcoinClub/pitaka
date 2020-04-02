import 'dart:async';
import 'dart:typed_data';
import "package:hex/hex.dart";
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/dialogs.dart';
import './../api/endpoints.dart';
import './../utils/helpers.dart';
import '../utils/globals.dart' as globals;
import '../views/app.dart';



class VerifyEmailFormComponent extends StatefulWidget {
  @override
  VerifyEmailFormComponentState createState() => VerifyEmailFormComponentState();
}

class VerifyEmailFormComponentState extends State<VerifyEmailFormComponent> {
  GlobalKey<FormState> _key = new GlobalKey();
  final LocalAuthentication auth = LocalAuthentication();
  bool _validate = false;
  bool authenticated = false;
  String code;
  String email;
  String publicKey;
  String privateKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
        centerTitle: true,
        leading: IconButton(icon:Icon(Icons.arrow_back),
          onPressed:() => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(15.0),
          child: Form(
            key: _key,
            autovalidate: _validate,
            child: FormUI(),
          ),
        ),
      ),
    );
  }

  Widget FormUI() {
    getEmail();
    return Column(
      children: <Widget>[
        SizedBox(height: 10.0,),
        Text("We sent a verification email to:"),
        Text(
          "$email",
          style: TextStyle(fontWeight: FontWeight.bold,),
        ),
        Text("Check your email and type the code here."),
        Center(
          child: RichText(
            text: TextSpan(
              text: "Did not receive email? Click",
              style: TextStyle(
                color: Colors.black, 
                fontSize: 14
              ),
              children: <TextSpan>[
                TextSpan(text: ' resend email.',
                  style: TextStyle(
                    color: Colors.redAccent, 
                    fontSize: 14
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _reSendEmailVerification();
                    }
                )
              ]
            ),
          ),
        ),
        SizedBox(height: 20.0),
        TextFormField(
          maxLength: 16,
          autofocus: true,
          decoration: InputDecoration(
            icon: const Icon(Icons.code),
            hintText: 'Enter 16-character code',
            labelText: 'Code',
          ),
          keyboardType: TextInputType.emailAddress,
          validator: validateName,
          onSaved: (String val) {
            code = val;
          }
        ),
        SizedBox(height: 15.0),
        SizedBox(
          width: double.infinity,
          child: RaisedButton(
            color: Colors.red,
            splashColor: Colors.red[100],
            textColor: Colors.white,
            onPressed: _sendToServer,
            child: new Text('Submit'),
          )
        )
      ],
    );
  }

  void getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
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

  String validateName(String value) {
    if (value.length < 16)
      return 'Code is exactly 16 characters';
    else
      return null;
  }

  _sendToServer() async {
    if (_key.currentState.validate()) {
      // No any error in validation
      _key.currentState.save();

      // Generate KeyPair and UDID
      await generateKeyPair(context);

      var codePayload = {
        "code": "$code",
      };

      String txnHash = codePayload['code'];
      String signature = await signTransaction(txnHash, privateKey);

      codePayload["public_key"] = publicKey;
      codePayload["txn_hash"] = txnHash;
      codePayload["signature"] = signature;
      
      var emailCode = await verifyEmail(codePayload);

      // If success is true pop the page, display email and change button to verify
      if (emailCode.success) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('registerEmailBtn', false);
        await prefs.setBool('verifyEmailBtn', false);
        await prefs.setBool('verifyIdentityBtn', true);
        Navigator.of(context).pop();
        Application.router.navigateTo(context, "/userprofile");
      }
      // Catch error in sending email
      else if (emailCode.error == "invalid_code") {
        showInvalidCodelDialog(context);
      }

    } else {
      // validation error
      setState(() {
        _validate = true;
      });
    }
  }

  _reSendEmailVerification() async {
    var payload = {
      "email": "",
    };

    var resp = await reSendEmailVerification(payload);

    // Catch error in sending email
    if (resp.error == "error_sending_email") {
      showErrorSendingEmailDialog(context);
    }
    // Catch error in duplicate email
    else if (resp.error == "existing_email") {
      showDuplicateEmailDialog(context);
    }
  }
}