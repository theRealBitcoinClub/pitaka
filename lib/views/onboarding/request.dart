import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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

  String validateMobile(String value) {
    if (value == '0000 - 000 - 0000') {
      return null;
    } else if (value.length < 11) {
      return 'Mobile number must be 11 characters';
    } else {
      if (value.startsWith('09')){
        return null;
      } else {
        return 'Invalid phone number';
      }
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

  void _showSnackBar(String message) {
    final snackBar =
        new SnackBar(content: new Text(message), backgroundColor: Colors.red);
    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
  }

  List<Widget> _buildMobileNumberForm(BuildContext context) {
    Form form = new Form(
        key: _formKey,
        autovalidate: false,
        child: Center(
            child: Container(
              alignment: Alignment.center,
              child:new ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20.0),
                children: <Widget>[
                 new Center(
                    child: new Text(
                      "Mobile Number Verification",
                      style: TextStyle(
                      fontSize: 24.0,
                      )
                    )
                  ),
                  new SizedBox(
                    height: 10.0,
                  ),
                  new TextFormField(
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
                    height: 97.0,
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
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: new Builder(builder: (BuildContext context) {
          _scaffoldContext = context;
          return new Stack(children: _buildMobileNumberForm(context));
        }
      )
    );
  }
}
