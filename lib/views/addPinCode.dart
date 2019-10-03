import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;
import '../views/app.dart';

class AddPincodeComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Register Pincode'),
      ),
      body: AddPincodeForm(), 
    );
  }
}

// Define a custom Form widget.
class AddPincodeForm extends StatefulWidget {
  @override
  _AddPincodeFormState createState() => _AddPincodeFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _AddPincodeFormState extends State<AddPincodeForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  String pincodeKey;
  String pincode;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  _storePincode() {
    setState(() async {
      pincode = myController.text;
      await globals.storage.write(key: "pincodeKey", value: pincode);
      // For debug, check if pin code was save
      final read = await globals.storage.read(key: "pincodeKey");
      print("The pincode: $read was succesfully save.");
      Application.router.navigateTo(context, "/account");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: myController,
                  autocorrect: true,
                  decoration: InputDecoration(hintText: 'Enter pincode'),
                ),
              ),
              RaisedButton(
                onPressed: _storePincode,
                child: Text("Submit"),
              )
            ],
          ),
        ));
  }
}
