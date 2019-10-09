import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;
import '../views/app.dart';

class Pincode {
  String pincode;
}

class AddPincodeComponent extends StatefulWidget {
  @override
  AddPincodeComponentState createState() => new AddPincodeComponentState();
}

class AddPincodeComponentState extends State<AddPincodeComponent> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _submitting = false;
  Pincode newPincode = new Pincode();
  bool _autoValidate = false;

  String _pincode;

  String validatePincode(String value) {
    if (value.length < 4)
      return 'Pincode must be exactly 4 digits';
    else
      return null;
  }

  void _validateInputs(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from                 labelText: 'Account Name',                labelText: 'Account Name',the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
      // Save the form
      _formKey.currentState.save();

      setState(() {
        _submitting = true;
      });
      _pincode = _controller.text;
      await globals.storage.write(key: "pincodeKey", value: _pincode);
      // For debug, check if pin code was save
      final read = await globals.storage.read(key: "pincodeKey");
      print("The pincode: $read was succesfully save.");
      Application.router.navigateTo(context, "/account");
    }
  }

  List<Widget> _buildAccountForm(BuildContext context) {
    Form form = new Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            new SizedBox(
              height: 30.0,
            ),
            new TextFormField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              validator: validatePincode,
              maxLength: 4,
              autofocus: true,
              onSaved: (value) {
                newPincode.pincode = value;
              },
              decoration: const InputDecoration(
                icon: const Icon(Icons.vpn_key),
                hintText: 'Enter pincode',
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
            )
          ],
        ));
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Register Pincode'),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildAccountForm(context));
        }));
  }
}
