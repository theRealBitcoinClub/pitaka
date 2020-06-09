
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import '../app.dart';
import '../../api/endpoints.dart';
import '../../utils/dialogs.dart';
import '../../utils/globals.dart' as globals;


class Code {
  String value;
}

class RequestOTPComponent extends StatefulWidget {
  final String mobileNumber;
  final String publicKey;
  RequestOTPComponent({Key key, this.mobileNumber, this.publicKey}) : super(key: key);

  @override
  RequestOTPComponentState createState() => RequestOTPComponentState();
}

class RequestOTPComponentState extends State<RequestOTPComponent> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TextEditingController textController = TextEditingController();
  BuildContext _scaffoldContext;
  FocusNode focusNode = FocusNode();
  String _newToken;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(interceptBackButton);
    listenForNewToken();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(interceptBackButton);
    super.dispose();
  }

  // Generate firebase messaging token
  void listenForNewToken() async {
    _firebaseMessaging.getToken().then((token) {
      print("The value of token in generateToken() in requestOTP.dart is: $token");
      _newToken = token;
    });
  }

  bool interceptBackButton(bool stopDefaultButtonEvent) {
    print("Back navigation blocked!");
    return true;
  }

  final _formKey = GlobalKey<FormState>();
  Code newCode = Code();

  String validateCode(String value) {
    if (value.length != 6)
      return 'OTP code must not be exactly 6 digits';
    else
      return null;
  }

  void _validateInputs(BuildContext context) async {
    bool proceed = false;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        _submitting = true;
      });

      String publicKey = await globals.storage.read(key: "publicKey");

      var payload = {
        "public_key": publicKey,
        "code": newCode.value,
      };

      var resp = await restoreAccount(payload);

      // Catch app version compatibility
      if (resp.error == "outdated_app_version") {
        showOutdatedAppVersionDialog(context);
      }

      // Show dialog if code is invalid
      if (resp.error == "invalid_code") {
        setState(() {
          _submitting = false;
        });
        textController.clear();
        showInvalidOTPCodeAcctResDialog(context);
      }

      // Catch the maximum retries of requesting OTP code
      if (resp.error == "max_retries_reached") {
        showMaxRetriesReachedDialog(context);
      }

      if (resp.success) {
        proceed = true;
        // Save user details in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('firstName', resp.user["firstName"]);
        await prefs.setString('lastName', resp.user["lastName"]);
        await prefs.setString('mobileNumber', resp.user["mobileNumber"]);
        await prefs.setString('email', resp.user["email"]);
        await prefs.setString('birthDate', resp.user["birthday"]);
        await prefs.setString('deviceID', resp.user["deviceID"]);
        await prefs.setString('firebaseToken', resp.user["firebaseToken"]);
        // Check what level is user at
        if (resp.user["level"] == 2) {
          await prefs.setBool('level2', true);
          // Hide register and verify email buttons when level2firebaseToken
          await prefs.setBool('registerEmailBtn', false);
          await prefs.setBool('verifyEmailBtn', false);
          // Show verify identity button
          await prefs.setBool('verifyIdentityBtn', true);
        } else if (resp.user["level"] == 3) {
          await prefs.setBool('level3', true);
          // Hide all buttons when level3
          await prefs.setBool('registerEmailBtn', false);
          await prefs.setBool('verifyEmailBtn', false);
          await prefs.setBool('verifyIdentityBtn', false);
        }

        if (_newToken != null) {
          var payload = {
            "firebase_token": _newToken,
          };

          var response = await updateFirebaseMessagingToken(payload); 

          if (response.success) {
            print("Firebase messaging token updated in the server!");
            await prefs.setString('firebaseToken', _newToken);
          }
        }
      }

      if (proceed) {
        Application.router
            .navigateTo(context, "/addpincodeacctres");
      } else {
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
        SnackBar(content: Text(message), backgroundColor: Colors.red);
    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
  }

  _reSendOTPCode() async {
    String publicKey = await globals.storage.read(key: "publicKey");
    // Create payload
    var payload = {
      "public_key": publicKey,
    };
    // Send public key as payload to restore user
    var resp = await requestOTPAccountRestore(payload);

    // Show dialog if code is invalid
    if (resp.error == "invalid_code") {
      showInvalidCodelDialog(context);
      textController.clear();
    }

    if (resp.success) {
      showSimpleNotification(
        Text("Code was sent to your mobile number."),
        background: Colors.red[600],
      );
    }
  }

  List<Widget> _buildOtpCodeForm(BuildContext context) {
    Form form = Form(
      key: _formKey,
      autovalidate: false,
      child: Center(
          child: Container(
            alignment: Alignment.topCenter,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              children: <Widget>[
                SizedBox(height: 20.0),
                Center(
                  child: Text("We've sent OTP code to:"),
                ),
                Center(
                  child: Text(
                    "${widget.mobileNumber}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Center(
                  child: Text("Check your SMS inbox and type the code below."),
                ),
                SizedBox(height: 5.0,),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "If you did not receive the code,",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' click here to resend code.',
                          style: TextStyle(color: Colors.redAccent, fontSize: 14),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _reSendOTPCode();
                            },
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
                Center(
                  child: Text("Enter the Verification Code",
                    style: TextStyle(
                      fontSize: 20.0,
                    )
                  )
                ),
                SizedBox(height: 10.0,),
                TextFormField(
                  autofocus: true,
                  controller: textController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.phone,
                  validator: validateCode,
                  onSaved: (value) {
                    newCode.value = value;
                  },
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                  decoration: const InputDecoration(
                    hintText: '******',
                  ),
                  maxLength: 6,
                ),
                SizedBox(height: 30.0,),
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
                ),
                SizedBox(height: 50.0,)
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
        automaticallyImplyLeading: true,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Application.router
              .navigateTo(context, "/onboarding/request");
          }
        ), 
      ),
      body: Builder(builder: (BuildContext context) {
          _scaffoldContext = context;
          return Stack(children: _buildOtpCodeForm(context));
        }
      )
    );
  }
}
