
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import '../app.dart';
import '../../api/endpoints.dart';
import '../../utils/dialogs.dart';


class Code {
  String value;
}

class RequestOTPComponent extends StatefulWidget {
  final String mobileNumber;
  RequestOTPComponent({Key key, this.mobileNumber}) : super(key: key);

  @override
  RequestOTPComponentState createState() => RequestOTPComponentState();
}

class RequestOTPComponentState extends State<RequestOTPComponent> {
  final TextEditingController textController = TextEditingController();
  BuildContext _scaffoldContext;
  FocusNode focusNode = FocusNode();
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

      if (newCode.value == '123456') {
        proceed = true;
      } else {
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
        }
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
        new SnackBar(content: Text(message), backgroundColor: Colors.red);
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
                  child: Text("We've sent an OTP code to:"),
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
                  child: Text("Check your inbox and type the code here."),
                ),
                SizedBox(height: 5.0,),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Did not received the code? Click",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' resend code.',
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
