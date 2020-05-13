import 'dart:async';
import 'package:flutter/material.dart';
import 'package:virtual_keyboard/virtual_keyboard.dart';
import '../views/app.dart';
import '../utils/globals.dart' as globals;


class Pincode {
  String pincode;
}

class AddPincodeAcctResComponent extends StatefulWidget {
  @override
  AddPincodeAcctResComponentState createState() => AddPincodeAcctResComponentState();
}

class AddPincodeAcctResComponentState extends State<AddPincodeAcctResComponent> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  Pincode newPincode = new Pincode();
  bool _autoValidate = false;
  bool _pincodeMatch;

  // Holds the text that user typed.
  String text1 = '';
  String text2 = '';
  // Displays the "*" as the pincode is type
  String textDisplay1 = '';
  String textDisplay2 = '';

  // True if shift enabled.
  bool shiftEnabled = false;

  // is true will show the numeric keyboard.
  bool isNumericMode = true;

  // Sets the two virtual keyboard, default is the first virtual keyboard
  bool virtualKeyboard1 = true;

  void _checkForPincodeChanges() async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from
      FocusScope.of(context).requestFocus(new FocusNode());
      // Save the form
      _formKey.currentState.save();

      setState(() {
        if (text1.length == 4) {
          virtualKeyboard1 = false;

          if (text2.length == 4) {

            if (text1 == text2) {
              _pincodeMatch = true;
              globals.storage.write(key: "pincodeKey", value: text1);
              // For debug, check if pin code was save
              final read = globals.storage.read(key: "pincodeKey");
              print("The pincode: $read was succesfully save.");
              Application.router.navigateTo(context, "/home");
              timer.cancel();
            } else {
              _pincodeMatch = false;
              virtualKeyboard1 = true;
              text1 = text2 = '';
              textDisplay1 = textDisplay2 = '';
            }
          } else {
            // Stay in second virtual keyboard
            virtualKeyboard1 = false;
          }
        } else {
          // Stay in first virtual keyboard
          virtualKeyboard1 = true;
        }
      });
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
                "Register 4-digit Pincode", 
                style: TextStyle(fontSize: 20.0,),
              ),
            ),

            new SizedBox(
              height: 30.0,
            ),

            Container(
              alignment: Alignment.center,
                child: Text(
                  textDisplay1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35.0,
                    letterSpacing: 20.0,
                  ),
                ),
            ),

            Container(
              alignment: Alignment.center,
              child: Text(
                "Re-enter pincode", 
                style: TextStyle(fontSize: 20.0,),
              ),
            ),

            new SizedBox(
              height: 30.0,
            ),

            Container(
              alignment: Alignment.center,
                child: Text(
                  textDisplay2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35.0,
                    letterSpacing: 20.0,
                  ),
                ),
            ),

            _pincodeMatch == false ? 
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Pincode does not match! Please try again.", 
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.red,
                  ),
                ),
              )
            : Container(
                alignment: Alignment.center,
                child: Text(
                  "", 
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),

            new SizedBox(
              height: 30.0,
            ),

            virtualKeyboard1 ?
            Container(
              // Keyboard is transparent
              //color: Colors.red,
              child: VirtualKeyboard(
                  fontSize: 28,
                  // [0-9] + .
                  type: VirtualKeyboardType.Numeric,
                  // Callback for key press event
                  onKeyPress: (key1) {
                    _onKeyPress1(key1);
                  }
              ),
            )
            :
            Container(
              // Keyboard is transparent
              //color: Colors.red,
              child: VirtualKeyboard(
                  fontSize: 28,
                  // [0-9] + .
                  type: VirtualKeyboardType.Numeric,
                  // Callback for key press event
                  onKeyPress: (key2) {
                    _onKeyPress2(key2);
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
          title: Text('Register New Pincode'),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildAccountForm(context));
        }));
  }

  // Fired when the virtual keyboard key is pressed.
  _onKeyPress1(VirtualKeyboardKey key1) {
    if (text1.length < 4) {
      if (key1.keyType == VirtualKeyboardKeyType.String) {
        text1 = text1 + (shiftEnabled ? key1.capsText : key1.text);
        // For the "*" display
        textDisplay1 = "";
        for (int i=0; i<text1.length; i++) {
          textDisplay1 = textDisplay1 + "*";
        }
      } else if (key1.keyType == VirtualKeyboardKeyType.Action) {
        switch (key1.action) {
          case VirtualKeyboardKeyAction.Backspace:
            if (text1.length == 0) return;
              text1 = text1.substring(0, text1.length - 1);
              // For the "*" display
              textDisplay1 = "";
              for (int i=0; i<text1.length; i++) {
                textDisplay1 = textDisplay1 + "*";
              }          
            break;
          case VirtualKeyboardKeyAction.Return:
            text1 = text1 + '\n';
            break;
          case VirtualKeyboardKeyAction.Space:
            text1 = text1 + key1.text;
            break;
          case VirtualKeyboardKeyAction.Shift:
            shiftEnabled = !shiftEnabled;
            break;
          default:
        }
      }
    // When text length is greater than 4 characters, disable the numeric keys except the backspace
    } else if (key1.keyType == VirtualKeyboardKeyType.Action) {
        switch (key1.action) {
          case VirtualKeyboardKeyAction.Backspace:
            if (text1.length == 0) return;
            text1 = text1.substring(0, text1.length - 1);
            // For the "*" display
            textDisplay1 = "";
            for (int i=0; i<text1.length; i++) {
              textDisplay1 = textDisplay1 + "*";
            }
            break;
          case VirtualKeyboardKeyAction.Return:
            text1 = text1 + '\n';
            break;
          case VirtualKeyboardKeyAction.Space:
            text1 = text1 + key1.text;
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

  // Fired when the virtual keyboard key is pressed.
  _onKeyPress2(VirtualKeyboardKey key2) {
    if (text2.length < 4) {
      if (key2.keyType == VirtualKeyboardKeyType.String) {
        text2 = text2 + (shiftEnabled ? key2.capsText : key2.text);
        // For the "*" display
        textDisplay2 = "";
        for (int i=0; i<text2.length; i++) {
          textDisplay2 = textDisplay2 + "*";
        }
      } else if (key2.keyType == VirtualKeyboardKeyType.Action) {
        switch (key2.action) {
          case VirtualKeyboardKeyAction.Backspace:
            if (text2.length == 0) return;
              text2 = text2.substring(0, text2.length - 1);
              // For the "*" display
              textDisplay2 = "";
              for (int i=0; i<text2.length; i++) {
                textDisplay2 = textDisplay2 + "*";
              }          
            break;
          case VirtualKeyboardKeyAction.Return:
            text2 = text2 + '\n';
            break;
          case VirtualKeyboardKeyAction.Space:
            text2 = text2 + key2.text;
            break;
          case VirtualKeyboardKeyAction.Shift:
            shiftEnabled = !shiftEnabled;
            break;
          default:
        }
      }
    // When text length is greater than 4 characters, disable the numeric keys except the backspace
    } else if (key2.keyType == VirtualKeyboardKeyType.Action) {
        switch (key2.action) {
          case VirtualKeyboardKeyAction.Backspace:
            if (text2.length == 0) return;
            text2 = text2.substring(0, text2.length - 1);
            // For the "*" display
            textDisplay2 = "";
            for (int i=0; i<text2.length; i++) {
              textDisplay2 = textDisplay2 + "*";
            }
            break;
          case VirtualKeyboardKeyAction.Return:
            text2 = text2 + '\n';
            break;
          case VirtualKeyboardKeyAction.Space:
            text2 = text2 + key2.text;
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

  // Create a timer to watch the text lenght
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 400), (Timer t) => _checkForPincodeChanges());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

}
