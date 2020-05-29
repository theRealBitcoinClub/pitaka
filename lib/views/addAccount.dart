import 'dart:async';
import 'package:flutter/material.dart';
import '../views/app.dart';
import '../api/endpoints.dart';
import '../components/drawer.dart';
import '../utils/helpers.dart';
import '../utils/globals.dart';
import '../utils/dialogs.dart';
import '../utils/globals.dart' as globals;


class AddAccount {
  String name;
}

class AddAccountComponent extends StatefulWidget {
  @override
  AddAccountComponentState createState() => AddAccountComponentState();
}

class AddAccountComponentState extends State<AddAccountComponent> {
  StreamSubscription _connectionChangeStream;
  AddAccount newAccount = new AddAccount();
  final _formKey = GlobalKey<FormState>();
  String _accountType;
  bool _autoValidate = false;
  bool online = globals.online;
  bool isOffline = false;
  bool _submitting = false;


  String validateName(String value) {
    if (value.length < 3)
      return 'Name must be more than 2 charater';
    else
      return null;
  }

  void _validateInputs(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(FocusNode());
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
        "signature": signature,
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
    if (globals.online) {
      Form form = Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 30.0, left: 8.0, right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Account Type",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 5.0,),
                  DropdownButton(
                    hint: Text('Select Account Type'),
                    iconEnabledColor: Colors.red,
                    value: _accountType,
                    isExpanded: true,
                    isDense: true,
                    iconSize: 30.0,
                    items: [
                      "Personal", 
                      "Business", 
                    ].map(
                      (val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      },
                    ).toList(),
                    onChanged: (val) {
                      setState(
                        () {
                          _accountType = val;
                        },
                      );
                    },
                  ),
                ]
              ),
            ),
            SizedBox(height: 20.0,),
            _accountType == "Personal" ?
              Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0,),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.text,
                      validator: validateName,
                      onSaved: (value) {
                        newAccount.name = value;
                      },
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.person_outline, color: Colors.red,),
                        hintText: 'Enter account name',
                        labelText: 'Personal Account Name',
                      ),
                    ),
                    SizedBox(height: 30.0,),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.red,
                        splashColor: Colors.red[100],
                        textColor: Colors.white,
                        onPressed: () {
                          _validateInputs(context);
                        },
                        child: Text('Create'),
                      )
                    )
                  ],
                )
              )
            : _accountType == "Business" ?
              Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0,),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.text,
                      validator: validateName,
                      onSaved: (value) {
                        newAccount.name = value;
                      },
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.attach_money, color: Colors.red,),
                        hintText: 'Enter account name',
                        labelText: 'Business Account Name',
                      ),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      validator: validateName,
                      onSaved: (value) {
                        newAccount.name = value;
                      },
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.insert_link, color: Colors.red,),
                        hintText: 'Enter callback URL',
                        labelText: 'Callback URL',
                      ),
                    ),
                    SizedBox(height: 30.0,),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.red,
                        splashColor: Colors.red[100],
                        textColor: Colors.white,
                        onPressed: () {
                          _validateInputs(context);
                        },
                        child: Text('Create'),
                      )
                    )
                  ],
                )
              )
            :
              Container()
          ],
        )
      );
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
    } else {
      return <Widget> [
        Center(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
              child: Text(
                "This is not available in offline mode.",
                style: TextStyle(fontSize: 18.0)
              )
            )
          )
        )
      ];
    }
    
  }

  @override
  void initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
  }


  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      if(isOffline == false) {
        online = !online;
        globals.online = online;
        print("Online");
      } else {
        online = false;
        globals.online = online;
        print("Offline");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              child: online ? Icon(Icons.wifi): Icon(Icons.signal_wifi_off),
            )
          )
        ],
        centerTitle: true,
      ),
      drawer: buildDrawer(context),
      body: Builder(builder: (BuildContext context) {
        return Stack(children: _buildAccountForm(context));
      })
    );
  }
}
