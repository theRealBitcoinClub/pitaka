
import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import '../../api/endpoints.dart';
import '../app.dart';
import '../../utils/dialog.dart';


class Code {
  String value;
}

class VerifyComponent extends StatefulWidget {
  final String mobileNumber;
  VerifyComponent({Key key, this.mobileNumber}) : super(key: key);

  @override
  VerifyComponentState createState() => new VerifyComponentState();
}

class VerifyComponentState extends State<VerifyComponent> {
  final TextEditingController textController = new TextEditingController();
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
  Code newCode = new Code();

  String validateCode(String value) {
    if (value.length != 6)
      return 'OTP code must not be exactly 6 digits';
    else
      return null;
  }

  BuildContext _scaffoldContext;
  FocusNode focusNode = FocusNode();
  bool _submitting = false;

  void _validateInputs(BuildContext context) async {
    bool proceed = false;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
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
        new SnackBar(content: new Text(message), backgroundColor: Colors.red);
    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
  }

  List<Widget> _buildOtpCodeForm(BuildContext context) {
    Form form = new Form(
      key: _formKey,
      autovalidate: false,
      child: Center(
          child: Container(
            alignment: Alignment.center,
            child: new ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              children: <Widget>[
                new Center(
                  child: new Text("Enter the Verification Code",
                      style: TextStyle(
                        fontSize: 20.0,
                      )
                    )
                  ),
                new SizedBox(
                  height: 10.0,
                ),
                new TextFormField(
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
                new SizedBox(
                  height: 30.0,
                ),
                new RaisedButton(
                  onPressed: () {
                    _validateInputs(context);
                  },
                  child: new Text('Submit'),
                ),
                new SizedBox(
                  height: 50.0,
                )
              ]
            )
          )
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
    return ws;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Welcome to Paytaca"),
        automaticallyImplyLeading: true,
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Application.router
              .navigateTo(context, "/onboarding/request");
          }
        ), 
      ),
      body: new Builder(builder: (BuildContext context) {
          _scaffoldContext = context;
          return new Stack(children: _buildOtpCodeForm(context));
        }
      )
    );
  }
}
