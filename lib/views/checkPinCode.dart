import 'dart:async';

import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;
import '../views/app.dart';
import 'package:virtual_keyboard/virtual_keyboard.dart';


class Pincode {
  String pincode;
}

class CheckPincodeComponent extends StatefulWidget {
  @override
  CheckPincodeComponentState createState() => new CheckPincodeComponentState();
}

class CheckPincodeComponentState extends State<CheckPincodeComponent> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _submitting = false;
  Pincode newPincode = new Pincode();
  bool _autoValidate = false;

  String _pincode;
  String _pincodeMatch;

    // Holds the text that user typed.
  String text = '';

  // True if shift enabled.
  bool shiftEnabled = false;

  // is true will show the numeric keyboard.
  bool isNumericMode = true;

  String _validatePincode(String value) {
    if (value.length < 4)
      return 'Pincode is exactly 4 digits';
    else
      return null;
  }

  void _checkForPincodeChanges() async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from                 labelText: 'Account Name',                labelText: 'Account Name',the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
      // Save the form
      _formKey.currentState.save();

      _pincode = _controller.text;
      final _readPincode = await globals.storage.read(key: "pincodeKey");
      // print("The pincode retrieve: $_readPincode.");
      // print("The pincode input value is: $text");
      if (text.length == 4) {
        if (_readPincode == text) {
          print("Success, pincode match!");
          Application.router.navigateTo(context, "/home");
          timer.cancel();
        }
      }
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

            Container(
              alignment: Alignment.center,
              child: Text(
                "Enter 4-digit Pincode", 
                style: TextStyle(fontSize: 22.0,),
              ),
            ),

            new SizedBox(
              height: 30.0,
            ),

            Container(
              alignment: Alignment.center,
              child: Text(
                text, 
                style: TextStyle(fontSize: 35.0,),
              ),
            ),

            new SizedBox(
              height: 60.0,
            ),
            Container(
            // Keyboard is transparent
            //color: Colors.red,
            child: VirtualKeyboard(
                fontSize: 28,
                // [0-9] + .
                type: VirtualKeyboardType.Numeric,
                // Callback for key press event
                onKeyPress: (key) {
                  _onKeyPress(key);
                }
            ),
          )
          ],
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Pincode Verification'),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildAccountForm(context));
        }));
  }

    /// Fired when the virtual keyboard key is pressed.
  _onKeyPress(VirtualKeyboardKey key) {
    if (key.keyType == VirtualKeyboardKeyType.String) {
      text = text + (shiftEnabled ? key.capsText : key.text);
    } else if (key.keyType == VirtualKeyboardKeyType.Action) {
      switch (key.action) {
        case VirtualKeyboardKeyAction.Backspace:
          if (text.length == 0) return;
          text = text.substring(0, text.length - 1);
          break;
        case VirtualKeyboardKeyAction.Return:
          text = text + '\n';
          break;
        case VirtualKeyboardKeyAction.Space:
          text = text + key.text;
          break;
        case VirtualKeyboardKeyAction.Shift:
          shiftEnabled = !shiftEnabled;
          break;
        default:
      }
    }
    // Update the screen
    setState(() {});
  }

  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _checkForPincodeChanges());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

}

