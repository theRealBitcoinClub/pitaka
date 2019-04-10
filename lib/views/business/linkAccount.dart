// SetBusinessAccountComponent

import 'package:flutter/material.dart';
import '../../api/endpoints.dart';
import '../../views/app.dart';

class FormAccount {
  String paytacaAccount;
  String businessAccount;
}

class SetBusinessAccountComponent extends StatefulWidget {
  @override
  SetBusinessAccountComponentState createState() => new SetBusinessAccountComponentState();
}

class SetBusinessAccountComponentState extends State<SetBusinessAccountComponent> {
  final _formKey = GlobalKey<FormState>();
  FormAccount formInfo = new FormAccount();
  List<String> _businessType = <String>['Business1','Business2', 'Business3'];
  String _selectedType = 'Business1';

  List<String> _paytacaAccounts = <String>['Account1','Account2', 'Account3'];
  String _selectedPaytacaAccount = 'Account1';

  Future<void> _successDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
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

  String validateCompanyName(String value) {
    if (value.length == 0) {
      return 'The field Company Name is required.';
    } else if (value.length < 6) {
      return 'Name must be more than 5 charater';
    } else {
      return null;
    }
  }

  String validateTin(String value) {
    print(value);
    if (value.length == 0) {
      return 'The field TIN is required.';
    } else if (value.length != 9) {
      return 'Invalid input for field TIN.';
    }else {
      return null;
    }
  }

  String validateType(String value) {
    if (value.length == 0) {
      return 'The field Business Type is required.';
    } else {
      return null;
    }
  }

  String validateAddress(String value) {
    if (value.length == 0)
      return 'The field Address is required.';
    else
      return null;
  }


  void _submitForm(BuildContext context) async {
    var valid = _formKey.currentState.validate();
    print('a');
    if (valid) {
      print('b');
      _successDialog();
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
      // Save the form
      _formKey.currentState.save();
      var response = await registerBusiness(formInfo);
      print(response);
      //await FlutterKeychain.put(key: "defaultAccount", value: response.id);
      Application.router.navigateTo(context, "/home");
    }
  }

  List<Widget> _buildAccountForm(BuildContext context) {
    Form form = new Form(
      key: _formKey,
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new SizedBox(
            height: 30.0,
          ),
          new FormField(
            builder: (FormFieldState state) {
              return InputDecorator(
                decoration: InputDecoration(
                  icon: const Icon(Icons.business),
                  labelText: 'Business',
                ),
                isEmpty: _selectedType == '',
                child: new DropdownButtonHideUnderline(
                  child: new DropdownButton(
                    value: _selectedType,
                    isDense: true,
                    onChanged: (String newValue) {
                      setState(() {
                        _selectedType = newValue;
                        formInfo.businessAccount = newValue;
                        state.didChange(newValue);
                      });
                    },
                    items: _businessType.map((String value) {
                      return new DropdownMenuItem(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          new FormField(
            builder: (FormFieldState state) {
              return InputDecorator(
                decoration: InputDecoration(
                  icon: const Icon(Icons.account_balance_wallet),
                  labelText: 'Account',
                ),
                isEmpty: _selectedPaytacaAccount == '',
                child: new DropdownButtonHideUnderline(
                  child: new DropdownButton(
                    value: _selectedPaytacaAccount,
                    isDense: true,
                    onChanged: (String newValue) {
                      setState(() {
                        _selectedPaytacaAccount = newValue;
                        formInfo.paytacaAccount = newValue;
                        state.didChange(newValue);
                      });
                    },
                    items: _paytacaAccounts.map((String value) {
                      return new DropdownMenuItem(
                        value: value,
                        child: new Text(value),
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
          title: Text('Set Business Account'),
          centerTitle: true,
        ),
        // drawer: buildDrawer(context),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildAccountForm(context));
        })
      );
  }
}
