import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import '../../api/endpoints.dart';
import '../app.dart';

class Mobile {
  String number;
}

class VerifyComponent extends StatefulWidget {
  @override
  VerifyComponentState createState() => new VerifyComponentState();
}

class VerifyComponentState extends State<VerifyComponent> {
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
  Mobile newMobile = new Mobile();

  String validateMobile(String value) {
    if (value.length != 11)
      return 'Mobile Number must be of 11 digits';
    else
      return null;
  }

  BuildContext _scaffoldContext;
  FocusNode focusNode = FocusNode();

  bool _autoValidate = false;
  bool _submitting = false;

  void _validateInputs(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {
        _submitting = true;
      });

      var numberPayload = {
        "mobile_number": newMobile.number
      };
      var resp = await requestOtpCode(numberPayload);
      
      if (resp.success) {
        Application.router.navigateTo(context, "/onboarding-register");
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

  List<Widget> _buildMobileNumberForm(BuildContext context) {
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
                  child: new Text("Please enter your mobile number",
                      style: TextStyle(
                        fontSize: 20.0,
                      ))),
              new SizedBox(
                height: 10.0,
              ),
              new TextFormField(
                keyboardType: TextInputType.phone,
                validator: validateMobile,
                onSaved: (value) {
                  newMobile.number = value;
                },
                decoration: const InputDecoration(
                  icon: const Icon(Icons.phone),
                  hintText: 'Enter your mobile number',
                  labelText: 'Mobile Number',
                ),
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
          return new Stack(children: _buildMobileNumberForm(context));
        }));
  }
}
