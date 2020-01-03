import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/endpoints.dart';
import '../../views/app.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/dialog.dart';

// business/connect-account

// {
//     "account": "F332DFCE-1874-434B-BEB4-F3A68326A61E",
//     "business": "6C142F31-0DEE-4EFE-93D1-892037DAB4E2",
//     "public_key": "a3d6f34c9c3cf11e10c1103b1304da4fa247cb0b1f8ffbecbcc77d7297fefa4a",
//     "txn_hash": "connect_to_account",
//     "signature": "ba97363f0d9e515d272ecc95db7bd818356062dbfb9644c5f008b4bb7b815fcfabf950efe53b19af595c9131c22961e1b8279d577737bcededac601f57d63a0a"
// }

class FormAccount {
  String account;
  String business;
}

class SetBusinessAccountComponent extends StatefulWidget {
  @override
  SetBusinessAccountComponentState createState() => new SetBusinessAccountComponentState();
}

class SetBusinessAccountComponentState extends State<SetBusinessAccountComponent> {
  final _formKey = GlobalKey<FormState>();
  FormAccount formInfo = new FormAccount();
  String _selectedType;
  String _selectedPaytacaAccount;
  List businesses = List();
  List accounts = List();
  bool _submitting = false;

  Future<String> getBusinesses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var resp = prefs.getString('businessList-false');
    setState(() {
      businesses = json.decode(resp);
    });
    return 'Success';
  }

  Future<String> getAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var resp = prefs.getString('accountsList');
    setState(() {
      accounts = json.decode(resp);
    });
    return 'Success';
  }

  @override
  void initState() {
    super.initState();
    this.getBusinesses();
    this.getAccounts();
  }

  Future<void> _successDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your selected business and account are now linked.')
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Got It!'),
              onPressed: () {
                Navigator.of(context).pop();
                Application.router.navigateTo(context, "/businesstools");
              },
            ),
          ],
        );
      },
    );
  }

  void _submitForm(BuildContext context) async {
    var valid = _formKey.currentState.validate();
    if (valid) {
      FocusScope.of(context).requestFocus(new FocusNode());
      _formKey.currentState.save();
      var info = {
        "account": formInfo.account,
        "business": formInfo.business,
        "app_version": globals.appVersion,
      };
      setState(() {
        _submitting = true;
        });
      var response = await linkBusinessToAccount(info);

      // Catch app version compatibility
      if (response.error == "app_version_outdated") {
        showOutdatedAppVersionDialog(context);
      }

      if(response.success) {
        setState(() {
          _submitting = false;
        });
        _successDialog();
      }
    }
  }

  List<Widget> formBuilder(){
    var ws = <Widget>[
      new SizedBox(
        height: 30.0,
      ),
      new FormField(
        validator: (value){
          if (value == null) {
            return 'Field required.';
          } else {
            return null;
          }
        },
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
              icon: const Icon(Icons.business),
              labelText: 'Business',
              errorText: state.errorText
            ),
            isEmpty: _selectedType == '',
            child: new DropdownButtonHideUnderline(
              child: new DropdownButton(
                value: _selectedType,
                isDense: true,
                onChanged: (newValue) {
                  setState(() {
                    _selectedType = newValue;
                    formInfo.business = newValue;
                    state.didChange(newValue);
                  });
                },
                items: businesses.map((value) {
                  return new DropdownMenuItem(
                    value: value['id'],
                    child: new Text(value['title']),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      new FormField(
        validator: (value){
          if (value == null) {
            return 'Field required.';
          } else {
            return null;
          }
        },
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
              icon: const Icon(Icons.account_balance_wallet),
              labelText: 'Account',
              errorText: state.errorText
            ),
            isEmpty: _selectedPaytacaAccount == '',
            child: new DropdownButtonHideUnderline(
              child: new DropdownButton(
                value: _selectedPaytacaAccount,
                isDense: true,
                onChanged: (newValue) {
                  setState(() {
                    _selectedPaytacaAccount = newValue;
                    formInfo.account = newValue;
                    state.didChange(newValue);
                  });
                },
                items: accounts.map((value) {
                  return new DropdownMenuItem(
                    value: value['id'],
                    child: new Text(value['name']),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      new SizedBox(
        height: 30.0,
      ),
      new RaisedButton(
        onPressed: () {
            _submitForm(context);
          },
        child: new Text('Link Account'),
      )
    ];
    return ws;
  }


  List<Widget> _buildAccountForm(BuildContext context) {
    Form form = new Form(
      key: _formKey,
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: formBuilder(),
      ));
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

  Widget bodyFunc (){
    if (accounts.length == 0 && businesses.length == 0) {
      return Center(
        child: Container(
          constraints: BoxConstraints(
              maxHeight: 300.0,
              maxWidth: 300.0,
          ),
          child: ListView(
            children: <Widget> [
              new Text(
                "You must have at least one business and one account to link.",
                textAlign: TextAlign.center,
                style: new TextStyle(fontSize: 18.0)
              ),
              new SizedBox(
                height: 30.0,
              ),
              new RaisedButton(
                onPressed: () {
                  Application.router.navigateTo(context, "/registerbusiness");
                },
                child: new Text('Register Business'),
              ),
            ]
          )
        )
      );
    } else if (accounts.length == 0) {
      return Center(
        child: Container(
          constraints: BoxConstraints(
              maxHeight: 300.0,
              maxWidth: 300.0,
          ),
          child: ListView(
            children: <Widget> [
              new Text(
                "No more available accounts to link.",
                textAlign: TextAlign.center,
                style: new TextStyle(fontSize: 18.0)
              ),
              new SizedBox(
                height: 30.0,
              ),
              new RaisedButton(
                child: Text('Create Account'),
                onPressed: () {
                  Application.router.navigateTo(context, "/addAccount");
                },
              ),
            ]
          )
        )
      );
    } else if (businesses.length == 0) {
      return Center(
        child: Container(
          constraints: BoxConstraints(
              maxHeight: 300.0,
              maxWidth: 300.0,
          ),
          child: Padding (
            padding: EdgeInsets.all(20.0),
            child: ListView(
              children: <Widget> [
                new Text(
                  "No businesses to link. Register one now.",
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontSize: 18.0)
                ),
                new SizedBox(
                  height: 30.0,
                ),
                RaisedButton(
                  child: Text('Register Business'),
                  onPressed: () {
                    Application.router.navigateTo(context, "/registerbusiness");
                  },
                ),
              ]
            )
          )
        )
      );
    } else {
      return new Builder(builder: (BuildContext context) {
        return new Stack(children: _buildAccountForm(context));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Set Business Account'),
          centerTitle: true,
        ),
        body: bodyFunc()
      );
  }
}
