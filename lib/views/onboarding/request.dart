import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import '../../api/endpoints.dart';
import '../app.dart';

class Mobile {
  String number;
}

class RequestComponent extends StatefulWidget {
  @override
  RequestComponentState createState() => new RequestComponentState();
}

class RequestComponentState extends State<RequestComponent> {
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
    if (value.startsWith('09')){
      return null;
    } else {
      return 'Invalid phone number';
    }
  }

  BuildContext _scaffoldContext;
  FocusNode focusNode = FocusNode();

  bool _autoValidate = false;
  bool _submitting = false;

  void _validateInputs(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {
        _submitting = true;
      });

      newMobile.number = "+63" + newMobile.number.substring(1).replaceAll(" - ", "");
      var numberPayload = {"mobile_number": newMobile.number};
      var resp = await requestOtpCode(numberPayload);

      if (resp.success) {
        Application.router
            .navigateTo(context, "/onboarding/verify/${newMobile.number}");
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
                      fontSize: 20.0,
                      )
                    )
                  ),
                  new SizedBox(
                    height: 10.0,
                  ),
                  new TextFormField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.phone,
                    validator: validateMobile,
                    onSaved: (value) {
                      newMobile.number = value;
                    },
                    style: TextStyle(
                      fontSize: 24.0
                    ),
                    decoration: const InputDecoration(
                      hintText: '09** - *** - ****',
                    ),
                    controller: new MaskedTextController(
                      mask: '0000 - 000 - 0000'
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
