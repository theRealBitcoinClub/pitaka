import 'package:flutter/material.dart';
import './../api/endpoints.dart';
import '../utils/dialogs.dart';


class RegisterEmailFormComponent extends StatefulWidget {
  @override
  RegisterEmailFormComponentState createState() => RegisterEmailFormComponentState();
}

class RegisterEmailFormComponentState extends State<RegisterEmailFormComponent> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String name, email, mobile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register an Email'),
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
    return Column(
      children: <Widget>[
        SizedBox(height: 30.0,),
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

  String validateEmail(String value) {
    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Email is Required";
    } else if(!regExp.hasMatch(value)){
      return "Invalid Email";
    }else {
      return null;
    }
  }

  _sendToServer() async {
    if (_key.currentState.validate()) {
      // No any error in validation
      _key.currentState.save();

      var emailPayload = {
        "email": "Mobile $mobile",
      };
      
      var user = await registerEmail(emailPayload);

      print("${user.error}");

      // Catch error in sending email
      if (user.error == "error_sending_email") {
        showErrorSendingEmailDialog(context);
      }
      else if (user.error == "email_existing") {
        
      }

    } else {
      // validation error
      setState(() {
        _validate = true;
      });
    }
  }
}