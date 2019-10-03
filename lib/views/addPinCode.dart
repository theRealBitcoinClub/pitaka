import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;
import '../views/app.dart';

void main() => runApp(AddPinCodeComponent());

class AddPinCodeComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retrieve Text Input',
      home: MyCustomForm(),
    );
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
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
    setState(() async{
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
        appBar: AppBar(
          title: Text('Retrieve Text Input'),
        ),
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

  // void initState() {
  //   super.initState();
  //   print("Saving pincode...");
  //   WidgetsBinding.instance.addPostFrameCallback((_) => storePincode());
  // }

}
