import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import '../app.dart';
import '../../api/endpoints.dart';
import '../../utils/dialogs.dart';


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
  String keys;
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

  String _validatePublicKey(String value) {
    if (value.length < 194) {
      return 'Private & Public keys must be 194 alphanumeric characters';
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

  void _validatePublicKeyInput(BuildContext context) async {
    bool proceed = false;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {
        _submitting = true;
      });

      print("Sending Public Key.......");
      print("########################### $keys ########################");

      // Extract public key from keys
      var publicKey = keys.split('::')[1];

      var payload = {
        "public_key": publicKey,
      };

      var resp = await sendPublicKey(payload);

      //   // Save mobile number in shared preferences
      //   SharedPreferences prefs = await SharedPreferences.getInstance();
      //   await prefs.setString('mobileNumber', newMobile.number);

        // Catch app version compatibility
        if (resp.error == "outdated_app_version") {
          showOutdatedAppVersionDialog(context);
        }
        
        if (resp.success) {
          proceed = true;
        } 

      // if (proceed) {
      //   Application.router
      //       .navigateTo(context, "/onboarding/verify/${newMobile.number}");
      // }
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
                        "Private & Public Key Verification",
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
                      validator: _validatePublicKey,
                      autofocus: false,
                      onSaved: (value) {
                        keys = value;
                      },
                      maxLength: 194,
                      style: TextStyle(
                        fontSize: 24.0
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter or Paste Private & Public Key',
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
                          _validatePublicKeyInput(context);
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
                        onPressed: () {
                          _validateInputs(context);
                        },
                        child: Text('Submit'),
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
