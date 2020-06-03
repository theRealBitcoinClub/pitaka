
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import '../app.dart';
import '../../api/endpoints.dart';
import '../../utils/dialogs.dart';


class Code {
  String value;
}

class VerifyComponent extends StatefulWidget {
  final String mobileNumber;
  VerifyComponent({Key key, this.mobileNumber}) : super(key: key);

  @override
  VerifyComponentState createState() => VerifyComponentState();
}

class VerifyComponentState extends State<VerifyComponent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();
  BuildContext _scaffoldContext;
  FocusNode focusNode = FocusNode();
  Code newCode = Code();
  bool _submitting = false;
  
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
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {
        _submitting = true;
      });

      var codePayload = {
        "mobile_number": "${widget.mobileNumber}",
        "code": newCode.value,
      };

      var resp = await verifyOtpCode(codePayload);

      // Catch app version compatibility
      if (resp.error == "outdated_app_version") {
        showOutdatedAppVersionDialog(context);
      }

      if (resp.verified) {
        proceed = true;
      } else {
        showInvalidOTPCodelDialog(context);
      }

      if (proceed) {
        Application.router
            .navigateTo(context, "/onboarding/register/${widget.mobileNumber}");
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
        new SnackBar(content: new Text(message), backgroundColor: Colors.red);
    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
  }

  _reSendOTPCode() async {
    var payload = {
      "mobile_number": widget.mobileNumber,
    };

    var resp = await requestOtpCode(payload);

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
                  child: Text("Check your SMS inbox and type the code below. "),
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
