import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;
import '../views/app.dart';
import 'package:virtual_keyboard/virtual_keyboard.dart';
import 'dart:async';

// class Pincode {
//   String pincode;
// }

// class AddPincodeComponent extends StatefulWidget {
//   @override
//   AddPincodeComponentState createState() => new AddPincodeComponentState();
// }

// class AddPincodeComponentState extends State<AddPincodeComponent> {
//   final _formKey = GlobalKey<FormState>();
//   final _controller = TextEditingController();
//   bool _submitting = false;
//   Pincode newPincode = new Pincode();
//   bool _autoValidate = false;

//   String _pincode;

//   String validatePincode(String value) {
//     if (value.length < 4)
//       return 'Pincode must be exactly 4 digits';
//     else
//       return null;
//   }

//   void _validateInputs(BuildContext context) async {
//     if (_formKey.currentState.validate()) {
//       // Close the on-screen keyboard by removing focus from                 labelText: 'Account Name',                labelText: 'Account Name',the form's inputs
//       FocusScope.of(context).requestFocus(new FocusNode());
//       // Save the form
//       _formKey.currentState.save();

//       setState(() {
//         _submitting = true;
//       });
//       _pincode = _controller.text;
//       await globals.storage.write(key: "pincodeKey", value: _pincode);
//       // For debug, check if pin code was save
//       final read = await globals.storage.read(key: "pincodeKey");
//       print("The pincode: $read was succesfully save.");
//       Application.router.navigateTo(context, "/account");
//     }
//   }

//   List<Widget> _buildAccountForm(BuildContext context) {
//     Form form = new Form(
//         key: _formKey,
//         autovalidate: _autoValidate,
//         child: new ListView(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           children: <Widget>[
//             new SizedBox(
//               height: 30.0,
//             ),
//             new TextFormField(
//               controller: _controller,
//               keyboardType: TextInputType.phone,
//               validator: validatePincode,
//               maxLength: 4,
//               autofocus: true,
//               onSaved: (value) {
//                 newPincode.pincode = value;
//               },
//               decoration: const InputDecoration(
//                 icon: const Icon(Icons.vpn_key),
//                 hintText: 'Enter pincode',
//               ),
//             ),
//             new SizedBox(
//               height: 30.0,
//             ),
//             new RaisedButton(
//               onPressed: () {
//                 _validateInputs(context);
//               },
//               child: new Text('Submit'),
//             )
//           ],
//         ));
//     var ws = new List<Widget>();
//     ws.add(form);
//     if (_submitting) {
//       var modal = new Stack(
//         children: [
//           new Opacity(
//             opacity: 0.8,
//             child: const ModalBarrier(dismissible: false, color: Colors.grey),
//           ),
//           new Center(
//             child: new CircularProgressIndicator(),
//           ),
//         ],
//       );
//       ws.add(modal);
//     }
//     return ws;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Register Pincode'),
//           automaticallyImplyLeading: false,
//           centerTitle: true,
//         ),
//         body: new Builder(builder: (BuildContext context) {
//           return new Stack(children: _buildAccountForm(context));
//         }));
//   }
// }



class Pincode {
  String pincode;
}

class AddPincodeComponent extends StatefulWidget {
  @override
  AddPincodeComponentState createState() => new AddPincodeComponentState();
}

class AddPincodeComponentState extends State<AddPincodeComponent> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  Pincode newPincode = new Pincode();
  bool _autoValidate = false;

  bool _pincodeMatch;

  String _pincode;

  // Holds the text that user typed.
  String text = '';
  // Displays the "*" as the pincode is type
  String textDisplay = '';

  // True if shift enabled.
  bool shiftEnabled = false;

  // is true will show the numeric keyboard.
  bool isNumericMode = true;

  // void _checkForPincodeChanges() async {
  //   if (_formKey.currentState.validate()) {
  //     // Close the on-screen keyboard by removing focus from                 labelText: 'Account Name',                labelText: 'Account Name',the form's inputs
  //     FocusScope.of(context).requestFocus(new FocusNode());
  //     // Save the form
  //     _formKey.currentState.save();

  //     final _readPincode = await globals.storage.read(key: "pincodeKey");
  //     setState(() {
  //       if (text.length == 4) {
  //         if (_readPincode == text) {
  //           Application.router.navigateTo(context, "/home");
  //           timer.cancel();
  //         } else {
  //           _pincodeMatch = false;
  //         }
  //       } else {
  //         _pincodeMatch = true;
  //       }
  //     });
  //   }
  // }


  void _validateInputs(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from                 labelText: 'Account Name',                labelText: 'Account Name',the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
      // Save the form
      _formKey.currentState.save();

      setState(() {
        _submitting = true;
      });
      _pincode = text;
      await globals.storage.write(key: "pincodeKey", value: _pincode);
      // For debug, check if pin code was save
      final read = await globals.storage.read(key: "pincodeKey");
      print("The pincode: $read was succesfully save.");
      Application.router.navigateTo(context, "/account");
    }
  }

  void _checkForPincodeChanges() async {
    
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
                  textDisplay,
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
            new RaisedButton(
              onPressed: () {
                _validateInputs(context);
              },
              child: new Text('Submit'),
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
          title: Text('Register Pincode'),
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
        // For the "*" display
        textDisplay = "";
        for (int i=0; i<text.length; i++) {
          textDisplay = textDisplay + "*";
        }
      } else if (key.keyType == VirtualKeyboardKeyType.Action) {
        switch (key.action) {
          case VirtualKeyboardKeyAction.Backspace:
            if (text.length == 0) return;
              text = text.substring(0, text.length - 1);
              // For the "*" display
              textDisplay = "";
              for (int i=0; i<text.length; i++) {
                textDisplay = textDisplay + "*";
              }          
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
            // For the "*" display
            textDisplay = "";
            for (int i=0; i<text.length; i++) {
              textDisplay = textDisplay + "*";
            }
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
