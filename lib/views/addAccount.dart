import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
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

class AddBusiness {
  String name;
  String type;
  String tin;
  String address;
}

class AddAccountComponent extends StatefulWidget {
  @override
  AddAccountComponentState createState() => AddAccountComponentState();
}

class AddAccountComponentState extends State<AddAccountComponent> {
  AddAccount newAccount = AddAccount();
  AddBusiness newBusiness = AddBusiness();
  final _formKey = GlobalKey<FormState>();
  String _accountType;
  String _businessType;
  bool _autoValidate = false;
  bool online = globals.online;
  bool isOffline = false;
  bool _submitting = false;
  bool _noBusinessTypeSelected = false;
  var controller = MaskedTextController(mask: '000-000-000-000');

  String validateName(String value) {
    if (value.length < 3)
      return 'Name must be more than 2 charater';
    else
      return null;
  }

  String validateAddress(String value) {
    if (value.length < 15)
      return 'Address must be complete';
    else
      return null;
  }

  String validateTIN(String value) {
    if (value.length < 12)
      return 'TIN number must be complete';
    else
      return null;
  }

  void _createPersonalAccount(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(FocusNode());
      // Save the form
      _formKey.currentState.save();

      // Retrive keypair, user ID and create signature
      String userId = await globals.storage.read(key: "userId");
      String publicKey = await globals.storage.read(key: "publicKey");
      String privateKey = await globals.storage.read(key: "privateKey");
      String signature = await signTransaction("helloworld", privateKey);

      var accountPayload = {
        "creator": userId,
        "name": newAccount.name,
        "public_key": publicKey,
        "txn_hash": "helloworld",
        "type": _accountType,
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

  void _registerBusiness(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(FocusNode());
      // Save the form
      _formKey.currentState.save();

      // Retrive keypair and create signature
      String publicKey = await globals.storage.read(key: "publicKey");
      String privateKey = await globals.storage.read(key: "privateKey");
      String signature = await signTransaction("helloworld", privateKey);

      // Create the payload
      var payload = {
        "name": newBusiness.name,
        "type": _businessType,
        "tin": newBusiness.tin,
        "address": newBusiness.address,
        "public_key": publicKey,
        "txn_hash": "helloworld",
        "signature": signature,
      };

      // Show progress indicator during request
      setState(() {
        _submitting = true;
      });

      // Call registerBusiness function in endpoint.dart
      var response = await registerBusiness(payload);

      // Catch app version compatibility
      if (response.error == "outdated_app_version") {
        showOutdatedAppVersionDialog(context);
      }

      // Catch app version compatibility
      if (response.error == "duplicate_tin") {
        showDuplicateTINDialog(context);
        setState(() {
          _submitting = false;
        });
      }

      if(response.success) {

        await globals.storage.write(key: "userBusinessId", value: response.id);


        // Retrive keypair, user ID and create signature
        String userId = await globals.storage.read(key: "userId");
        
        var accountPayload = {
          "creator": userId,
          "name": newBusiness.name,
          "public_key": publicKey,
          "txn_hash": "helloworld",
          "type": _accountType,
          "callback_url": "",
          "signature": signature,
        };

        var resp = await createAccount(accountPayload);

        // Catch app version compatibility
        if (resp.error == "outdated_app_version") {
          showOutdatedAppVersionDialog(context);
        }

        if(resp != null) {

          await globals.storage.write(key: "userBusinessAccountId", value: resp.id);

          // Retrive keypair, business ID's and create signature
          String account = await globals.storage.read(key: "userBusinessAccountId");
          String business = await globals.storage.read(key: "userBusinessId");

          var payload = {
            "account": account,
            "business": business,
            "public_key": publicKey,
            "txn_hash": "helloworld",
            "signature": signature,
          };
          // Call linkBusinessToAccount function in endpoint.dart
          var res = await linkBusinessToAccount(payload);
          // Hide progress indicator after successful request
          if (res.success) {
            setState(() {
              _submitting = false;
            });
            // After successful request navigate to home
            Application.router.navigateTo(context, "/home");
          }
        }
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
            SizedBox(height: 30.0,),
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
                          _createPersonalAccount(context);
                        },
                        child: Text('Create Personal Account'),
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
                    Stack(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 6.0,),
                          child: Icon(
                            Icons.business_center,
                            color: Colors.red,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 40.0,),
                          child: DropdownButton(
                            hint: Text('Select Business Type'),
                            iconEnabledColor: Colors.red,
                            value: _businessType,
                            isExpanded: true,
                            isDense: true,
                            iconSize: 30.0,
                            items: [
                              "Sole Proprietorship", 
                              "Partnership", 
                              "Corporation",
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
                                  _businessType = val;
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 38.0, left: 42.0,),
                          child: Visibility(
                            visible: _businessType == null && _noBusinessTypeSelected == true,
                            child: Container(
                              child: Text(
                                "This field is required",
                                style: TextStyle(color: Colors.red, fontSize: 12.0,),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      validator: validateName,
                      onSaved: (value) {
                        newBusiness.name = value;
                      },
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.business, color: Colors.red,),
                        hintText: 'Enter business name',
                        labelText: 'Name',
                      ),
                    ),
                    TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.phone,
                      validator: validateTIN,
                      onSaved: (value) {
                        newBusiness.tin = value;
                      },
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.dehaze, color: Colors.red,),
                        hintText: 'Enter TIN number',
                        labelText: 'TIN',
                      ),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      validator: validateAddress,
                      onSaved: (value) {
                        newBusiness.address = value;
                      },
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.location_city, color: Colors.red,),
                        hintText: 'Enter business address',
                        labelText: 'Address',
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
                          if (_businessType == null) {
                            setState(() {
                              _noBusinessTypeSelected = true;
                            });
                          }
                          _registerBusiness(context);
                        },
                        child: Text('Register Business'),
                      )
                    ),
                  ],
                )
              )
            :
              Container(),  
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
    connectionStatus.connectionChange.listen(connectionChanged);
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
