import 'package:flutter/material.dart';
import '../../views/app.dart';
import '../../api/endpoints.dart';
import '../../utils/helpers.dart';
import '../../utils/dialogs.dart';
import '../../utils/globals.dart' as globals;


class Account {
  String name;
}

class AccountComponent extends StatefulWidget {
  @override
  AccountComponentState createState() => AccountComponentState();
}

class AccountComponentState extends State<AccountComponent> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  Account newAccount = new Account();
  bool _autoValidate = false;

  String validateName(String value) {
    if (value.length < 3)
      return 'Name must be more than 2 charater';
    else
      return null;
  }

  void _validateInputs(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
      // Save the form
      _formKey.currentState.save();
      // Send request to create the account
      String userId = await globals.storage.read(key: "userId");
      String publicKey = await globals.storage.read(key: "publicKey");
      String privateKey = await globals.storage.read(key: "privateKey");
      String signature = await signTransaction("helloworld", privateKey);

      var accountPayload = {
        "creator": userId,
        "name": newAccount.name,
        "public_key": publicKey,
        "txn_hash": "helloworld",
        "signature": signature
      };

      setState(() {
        _submitting = true;
      });

      var response = await createAccount(accountPayload);
      
      // Catch app version compatibility
      if (response.error == "outdated_app_version") {
        showOutdatedAppVersionDialog(context);
      }

      if(response != null) {
        setState(() {
          _submitting = false;
        });
        await globals.storage.write(key: "defaultAccount", value: response.id);
        Application.router.navigateTo(context, "/home");
      }
    }
  }

  List<Widget> _buildAccountForm(BuildContext context) {
    Form form = Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            SizedBox(height: 30.0,),
            TextFormField(
              initialValue: 'Personal',
              keyboardType: TextInputType.text,
              validator: validateName,
              onSaved: (value) {
                newAccount.name = value;
              },
              decoration: const InputDecoration(
                icon: const Icon(Icons.person_outline, color: Colors.red,),
                hintText: 'Enter account name',
                labelText: 'Account Name',
              ),
            ),
            SizedBox(height: 30.0,),
            RaisedButton(
              color: Colors.red,
              splashColor: Colors.red[100],
              textColor: Colors.white,
              onPressed: () {
                _validateInputs(context);
              },
              child: Text('Create'),
            )
          ],
        ));
    var ws = List<Widget>();
    ws.add(form);
    if (_submitting) {
      var modal = Stack(
        children: [
          Opacity(
            opacity: 0.8,
            child: const ModalBarrier(dismissible: false, color: Colors.grey),
          ),
          Center(
            child: CircularProgressIndicator(),
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
        title: Text('Create Account'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return Stack(children: _buildAccountForm(context));
      })
    );
  }
}
