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
  bool _submitting = false;
  Pincode newPincode = new Pincode();
  bool _autoValidate = false;

  bool _pincodeMatch;

    // Holds the text that user typed.
  String text = '';

  // True if shift enabled.
  bool shiftEnabled = false;

  // is true will show the numeric keyboard.
  bool isNumericMode = true;

  void _checkForPincodeChanges() async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from                 labelText: 'Account Name',                labelText: 'Account Name',the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
      // Save the form
      _formKey.currentState.save();

      final _readPincode = await globals.storage.read(key: "pincodeKey");
      setState(() {
        if (text.length == 4) {
          if (_readPincode == text) {
            Application.router.navigateTo(context, "/home");
            timer.cancel();
          } else {
            _pincodeMatch = false;
          }
        } else {
          _pincodeMatch = true;
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
                "Enter 4-digit Pincode", 
                style: TextStyle(fontSize: 20.0,),
              ),
            ),

            new SizedBox(
              height: 30.0,
            ),

            Container(
              margin: const EdgeInsets.only(left: 86.0),
              alignment: Alignment.centerLeft,
              child: Text(
                text, 
                style: TextStyle(
                  fontSize: 35.0,
                  letterSpacing: 20.0,
                  decorationStyle: TextDecorationStyle.dashed,
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: CustomPaint( 
                    size: Size(42, 40),
                    painter: HorizontalLine(),
                  ),
                ),

                Center(
                  child: CustomPaint( 
                    size: Size(40, 40),
                    painter: HorizontalLine(),
                  ),
                ),

                Center(
                  child: CustomPaint( 
                    size: Size(40, 40),
                    painter: HorizontalLine(),
                  ),
                ),

                Center(
                  child: CustomPaint( 
                    size: Size(42, 40),
                    painter: HorizontalLine(),
                  ),
                ),
              ],
            ),

            _pincodeMatch == false ? 
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Wrong pincode! Please try again.", 
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
    if (text.length < 4) {
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
    // When text length is greater than 4 characters, disable the numeric keys except the backspace
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

class HorizontalLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(10, 0);
    final p2 = Offset(35, 0);
    final paint = Paint()
      ..color = Colors.red[900]
      ..strokeWidth = 2;
    canvas.drawLine(p1, p2, paint);
  }
  
  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}