import 'package:flutter/material.dart';
import '../api/endpoints.dart';
import '../views/app.dart';
import '../utils/helpers.dart';
import '../components/drawer.dart';
import '../utils/globals.dart' as globals;
import '../utils/globals.dart';
import 'dart:async';
import '../utils/dialog.dart';


class AddAccount {
  String name;
}

class AddAccountComponent extends StatefulWidget {
  @override
  AddAccountComponentState createState() => new AddAccountComponentState();
}

class AddAccountComponentState extends State<AddAccountComponent> {

  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  AddAccount newAccount = new AddAccount();
  bool _autoValidate = false;
  bool online = globals.online;
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;


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
        "signature": signature,
        "app_version": globals.appVersion,
      };
      setState(() {
        _submitting = true;
      });
      var response = await createAccount(accountPayload);

      // Catch app version compatibility
      if (response.error == "app_version_outdated") {
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
      Form form = new Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
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
    } else {
      return <Widget> [
        new Center(
          child: new Padding(
              padding: EdgeInsets.all(8.0),
              child:new Container(
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
  /*  globals.checkConnection().then((status){
      setState(() {
        if (status == false) {
          online = false;  
          globals.online = online;
        } else {
          globals.online = online;
        }
      });
    });*/
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
                child: online ? new Icon(Icons.wifi): new Icon(Icons.signal_wifi_off),
            /*    onTap: (){
                  globals.checkConnection().then((status){
                    setState(() {
                      if (status == true) {
                        online = !online;  
                        globals.online = online;  
                      } else {
                        online = false;  
                        globals.online = online;
                      }
                    });
                  });
                }*/
              )
            )
          ],
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildAccountForm(context));
        }));
  }
}
