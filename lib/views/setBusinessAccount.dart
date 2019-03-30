// SetBusinessAccountComponent

import 'package:flutter/material.dart';
import '../api/endpoints.dart';
import '../views/app.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class BusinessAccount {
  String name;
  String type;
  String tin;
  String address;
}

class SetBusinessAccountComponent extends StatefulWidget {
  @override
  SetBusinessAccountComponentState createState() => new SetBusinessAccountComponentState();
}

class SetBusinessAccountComponentState extends State<SetBusinessAccountComponent> {
  final _formKey = GlobalKey<FormState>();
  BusinessAccount businessInfo = new BusinessAccount();

  String validateCompanyName(String value) {
    if (value.length == 0) {
      return 'The field Company Name is required.';
    } else if (value.length < 6) {
      return 'Name must be more than 5 charater';
    } else {
      return null;
    }
  }

  String validateTin(String value) {
    print(value);
    if (value.length == 0) {
      return 'The field TIN is required.';
    } else if (value.length != 9) {
      return 'Invalid input for field TIN.';
    }else {
      return null;
    }
  }

  String validateType(String value) {
    if (value.length == 0) {
      return 'The field Business Type is required.';
    } else {
      return null;
    }
  }

  String validateAddress(String value) {
    if (value.length == 0)
      return 'The field Address is required.';
    else
      return null;
  }


  void _submitForm(BuildContext context) async {
    var valid = _formKey.currentState.validate();
    if (valid) {
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
      // Save the form
      _formKey.currentState.save();
      var response = await registerBusiness(businessInfo);
      print(response);
      //await FlutterKeychain.put(key: "defaultAccount", value: response.id);
      Application.router.navigateTo(context, "/home");
    }
  }

  List<Widget> _buildAccountForm(BuildContext context) {
    Form form = new Form(
      key: _formKey,
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new SizedBox(
            height: 30.0,
          ),
          new DropdownButton<String>(
            items: <String>['A', 'B', 'C', 'D'].map((String value) {
              return new DropdownMenuItem<String>(
                value: value,
                child: new Text(value),
              );
            }).toList(),
            onChanged: (_) {},
          ),
          new SizedBox(
            height: 30.0,
          ),
          new DropdownButton<String>(
            items: <String>['A', 'B', 'C', 'D'].map((String value) {
              return new DropdownMenuItem<String>(
                value: value,
                child: new Text(value),
              );
            }).toList(),
            onChanged: (_) {},
          ),
          new SizedBox(
            height: 30.0,
          ),
          new RaisedButton(
            onPressed: () {
                _submitForm(context);
              },
            child: new Text('Link Account'),
          )
        ],
      ));
    var ws = new List<Widget>();
    ws.add(form);
    return ws;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Set Business Account'),
          centerTitle: true,
        ),
        // drawer: buildDrawer(context),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildAccountForm(context));
        })
      );
  }
}
