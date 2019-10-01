import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

class AddPinCodeComponent extends StatefulWidget {
  @override
  State createState() => new AddPinCodeComponentState();
}

class AddPinCodeComponentState extends State<AddPinCodeComponent> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.green,
          hintColor: Colors.green,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: PinPut(
                    fieldsCount: 4,
                    onSubmit: (String pin) => _showSnackBar(pin, context),
                  ),
                ),
              ),
        )));
  }

  void _showSnackBar(String pin, BuildContext context) {
    final snackBar = SnackBar(
      duration: Duration(seconds: 5),
      content: Container(
          height: 80.0,
          child: Center(
            child: Text(
              'Pin Submitted. Value: $pin',
              style: TextStyle(fontSize: 25.0),
            ),
          )),
      backgroundColor: Colors.greenAccent,
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}