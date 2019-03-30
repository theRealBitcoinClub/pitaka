import 'package:flutter/material.dart';
import '../api/endpoints.dart';
import '../views/app.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class BusinessAccount {
  String name;
  String type;
  String tin;
  String address;
}

class BusinessRegistrationComponent extends StatefulWidget {
  @override
  BusinessRegistrationComponentState createState() => new BusinessRegistrationComponentState();
}

class BusinessRegistrationComponentState extends State<BusinessRegistrationComponent> {
  final _formKey = GlobalKey<FormState>();
  List<String> _businessType = <String>['Corporation','Sole Proprietorship', 'Partnership'];

  String _selectedType = 'Corporation';

  BusinessAccount businessInfo = new BusinessAccount();

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
    if (value.length == 0) {
      return 'The field TIN is required.';
    } else if (value.length != 11) {
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
    if (valid) {
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());
      // Save the form
      _formKey.currentState.save();
      await registerBusiness(businessInfo);
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
          new TextFormField(
            keyboardType: TextInputType.text,
            validator: validateCompanyName,
            onSaved: (value) {
                businessInfo.name = value;
            },
            decoration: const InputDecoration(
              icon: const Icon(Icons.business_center),
              hintText: 'Enter company name',
              labelText: 'Company Name',
            ),
          ),
          new SizedBox(
            height: 30.0,
          ),
          new FormField(
            builder: (FormFieldState state) {
              return InputDecorator(
                decoration: InputDecoration(
                  icon: const Icon(Icons.explore),
                  labelText: 'Business Type',
                ),
                isEmpty: _selectedType == '',
                child: new DropdownButtonHideUnderline(
                  child: new DropdownButton(
                    value: _selectedType,
                    isDense: true,
                    onChanged: (String newValue) {
                      setState(() {
                        _selectedType = newValue;
                        businessInfo.type = newValue;
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
          new SizedBox(
            height: 30.0,
          ),
          new TextFormField(
            keyboardType: TextInputType.number,
            onSaved: (value) {
                businessInfo.tin = value;
            },
            decoration: const InputDecoration(
              icon: const Icon(Icons.portrait),
              hintText: 'Enter TIN',
              labelText: 'TIN',
            ),
            validator: validateTin,
            controller: new MaskedTextController(
              mask: '000-000-000'
            )
          ),
          new SizedBox(
            height: 30.0,
          ),
          new TextFormField(
            keyboardType: TextInputType.text,
            onSaved: (value) {
                businessInfo.address = value;
            },
            decoration: const InputDecoration(
              icon: const Icon(Icons.place),
              hintText: 'Enter address',
              labelText: 'Address',
            ),
            validator: validateAddress,
          ),
          new SizedBox(
            height: 30.0,
          ),
          new RaisedButton(
            onPressed: () {
                _submitForm(context);
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
          title: Text('Register Business'),
          centerTitle: true,
        ),
        // drawer: buildDrawer(context),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildAccountForm(context));
        })
      );
  }
}
