import 'package:flutter/material.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import '../api/endpoints.dart';
import '../views/app.dart';
import '../helpers.dart';

class Account {
  String name;
}

class AccountComponent extends StatefulWidget {
  @override
  AccountComponentState createState() => new AccountComponentState();
}

class AccountComponentState extends State<AccountComponent> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(interceptBackButton);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(interceptBackButton);
    super.dispose();
  }

  bool interceptBackButton(bool stopDefaultButtonEvent) {
    print("Back navigation blocked!");
    return true;
  }

  final _formKey = GlobalKey<FormState>();
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
      String userId = await FlutterKeychain.get(key: "userId");
      String publicKey = await FlutterKeychain.get(key: "publicKey");
      String privateKey = await FlutterKeychain.get(key: "privateKey");
      String signature = await signTransaction("helloworld", privateKey);
      var accountPayload = {
        "creator": userId,
        "name": newAccount.name,
        "public_key": publicKey,
        "txn_hash": "helloworld",
        "signature": signature
      };
      await createAccount(accountPayload);
      Application.router.navigateTo(context, "/home");
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
            new Center(
                child: new Text("One more step before you can use your wallet!",
                    style: TextStyle(
                      fontSize: 26.0,
                    ))),
            new SizedBox(
              height: 15.0,
            ),
            new Center(
                child: new Text(
                    "Paytaca supports multiple accounts per user -- each with separate address, balance, transaction history, and ownership mode.",
                    style: TextStyle(
                      fontSize: 18.0,
                    ))),
            new SizedBox(
              height: 15.0,
            ),
            new Center(
                child: new Text(
                    "Assign a name to your first account and hit the 'Create' button.",
                    style: TextStyle(
                      fontSize: 18.0,
                    ))),
            new SizedBox(
              height: 30.0,
            ),
            new TextFormField(
              keyboardType: TextInputType.text,
              validator: validateName,
              onSaved: (value) {
                newAccount.name = value;
              },
              decoration: const InputDecoration(
                icon: const Icon(Icons.person_outline),
                hintText: 'Enter account name',
                labelText: 'Account Name',
              ),
            ),
            new SizedBox(
              height: 30.0,
            ),
            new RaisedButton(
              onPressed: () {
                _validateInputs(context);
              },
              child: new Text('Create'),
            )
          ],
        ));
    var ws = new List<Widget>();
    ws.add(form);
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
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildAccountForm(context));
        }));
  }
}
