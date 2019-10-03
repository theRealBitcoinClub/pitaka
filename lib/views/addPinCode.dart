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
            child: Container(
                alignment: Alignment.center,
                child: new ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20.0),
                    children: <Widget>[
                      new Center(
                          child: new Text("Pincode Registration",
                              style: TextStyle(
                                fontSize: 24.0,
                              ))),
                      new SizedBox(
                        height: 10.0,
                      ),
                      new TextFormField(
                        controller: myController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.phone,
                        autofocus: true,
                        maxLength: 4,
                        style: TextStyle(fontSize: 24.0),
                        decoration: const InputDecoration(
                          hintText: 'Enter Pincode',
                          hintStyle: TextStyle(fontSize: 15.0),
                        ),
                      ),
                      new SizedBox(
                        height: 30.0,
                      ),
                      new RaisedButton(
                        onPressed: _storePincode,
                        child: new Text('Submit'),
                      ),
                      new SizedBox(
                        height: 97.0,
                      )
                    ]
                )
            )
        )
    );
  }
}
