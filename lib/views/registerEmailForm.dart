import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './../api/endpoints.dart';
import '../utils/dialogs.dart';
import '../views/app.dart';

class RegisterEmailFormComponent extends StatefulWidget {
  @override
  RegisterEmailFormComponentState createState() =>
      RegisterEmailFormComponentState();
}

class RegisterEmailFormComponentState
    extends State<RegisterEmailFormComponent> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _loading = false;
  bool _validate = false;
  String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register an Email'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      // Changed the return body to work with modal progress indicator
      body: Builder(builder: (BuildContext context) {
        return Stack(children: _buildForm(context));
      }),
    );
  }

  List<Widget> _buildForm(BuildContext context) {
    Form form = Form(
      key: _key,
      autovalidate: _validate,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                icon: const Icon(Icons.email),
                hintText: 'Enter your email address',
                labelText: 'Email address',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: validateEmail,
              onSaved: (String val) {
                email = val;
              },
            ),
            SizedBox(height: 15.0),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                color: Colors.red,
                splashColor: Colors.red[100],
                textColor: Colors.white,
                onPressed: () {
                  _sendToServer();
                  // Dismiss the keyboard after clicking the button
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: new Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );

    var l = new List<Widget>();
    l.add(form);

    if (_loading) {
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
      l.add(modal);
    }
    return l;
  }

  String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }

  _sendToServer() async {
    if (_key.currentState.validate()) {
      // No any error in validation
      _key.currentState.save();

      setState(() {
        _loading = true;
      });

      var emailPayload = {
        "email": "$email",
      };

      var user = await registerEmail(emailPayload);

      // If success is true pop the page, display email and change button to verify
      if (user.success) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('registerEmailBtn', false);
        await prefs.setBool('verifyEmailBtn', true);
        await prefs.setBool('verifyIdentityBtn', false);
        // Pop twice to go back first userProfile page
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Application.router.navigateTo(context, "/userprofile");
        // When response is success, dismiss loading progress
        setState(() {
          _loading = false;
        });
      }
      // Catch error in sending email
      else if (user.error == "error_sending_email") {
        // When there is error, dismiss loading progress
        setState(() {
          _loading = false;
        });
        showErrorSendingEmailDialog(context);
      }
      // Catch error in duplicate email
      else if (user.error == "existing_email") {
        // When there is error, dismiss loading progress
        setState(() {
          _loading = false;
        });
        showDuplicateEmailDialog(context);
      }
    } else {
      // validation error
      setState(() {
        _validate = true;
      });
    }
  }
}
