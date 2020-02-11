
import 'package:flutter/material.dart';
import 'dart:async';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/globals.dart' as globals;
import '../utils/globals.dart';


class Contact {
  String firstName;
  String lastName;
  String emailAddress;
  DateTime birthDate;
  String imei;
}

class ContactListComponent extends StatefulWidget {
  @override
  ContactListComponentState createState() => new ContactListComponentState();
}

class ContactListComponentState extends State<ContactListComponent> {
  String path = "/receive";
  int accountIndex = 0;
  final _formKey = GlobalKey<FormState>();
  String _selectedPaytacaAccount;
  static List data = List(); //edited line
  bool online = globals.online;
  bool isOffline = false;
  StreamSubscription _connectionChangeStream;
  bool _loading = false;   // For CircularProgressIndicator
  bool _isContactListEmpty = true;

  @override
  void initState()  {
    super.initState();
    // Subscribe to Notifier Stream from ConnectionStatusSingleton class in globals.dart
    // Fires whenever connectivity state changes
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);

    getAccounts();
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
  void dispose() {
    super.dispose();
  }

  Future<List> getAccounts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var _prefAccounts = prefs.get("accounts");
      List<Map> _accounts = [];
      for (final acct in _prefAccounts) {
        String accountId = acct.split(' | ')[1];
        var acctObj = new Map();
        acctObj['accountName'] = acct.split(' | ')[0];
        acctObj['accountId'] = accountId;
        _accounts.add(acctObj);
      }
      data = _accounts;
      return _accounts;
    } catch(e) {
      print("Error in getAccounts(): $e");
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Contact List'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                child: online ? new Icon(Icons.wifi): new Icon(Icons.signal_wifi_off)
              ) 
            )
          ],
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body: new Builder(builder: (BuildContext context) {
          if (_isContactListEmpty) {
            return Container(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "You're contact list is empty. Create by tapping the '+ person' icon button." ,
                  textAlign: TextAlign.center,
                ),
              )
            );
          }
          else {
            return new Stack(children: _buildContactListForm(context));
          }
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
          },
          child: Icon(Icons.person_add),
          backgroundColor: Colors.red,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: buildBottomNavigation(context, path)
      );
  }

  Widget addContactdButton (){
    return FloatingActionButton(
      onPressed: () {
        // Add your onPressed code here!
      },
      child: Icon(Icons.add),
      backgroundColor: Colors.red,
    );
  }

  // List<Widget> _buildForm(BuildContext context) {
  //   Form form = new Form(
  //     key: _formKey,
  //     child: new ListView(
  //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //       children: <Widget>[
  //         new SizedBox(
  //           height: 20.0,
  //         ),
  //         new SizedBox(
  //           height: 20.0,
  //         ),
  //       ],
  //     )
  //   );
  //   var ws = new List<Widget>();
  //   ws.add(form);
  //   return ws;
  // }

  User newUser = new User();

  String validateName(String value) {
    if (value.length < 2)
      return 'Name must be at least 2 characters';
    else
      return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

 void _validateInputs(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());

      if (_termsChecked) {
        // If all data are correct then save data to out variables
        _formKey.currentState.save();
        await generateKeyPair(context);

        if (authenticated == true) {
          setState(() {
            _submitting = true;
          });
          
          // Get the mobile number from previous route parameter
          mobileNumber = "${widget.mobileNumber}";

          var userPayload = {
            "firstname": newUser.firstName,
            "lastname": newUser.lastName,
            "birthday": "2006-01-02",
            "email": newUser.emailAddress,
            "mobile_number": mobileNumber,
          };
          String txnHash = generateTransactionHash(userPayload);
          print("The value of txnHash is: $txnHash");
          String signature = await signTransaction(txnHash, privateKey);

          userPayload["public_key"] = publicKey;
          userPayload["txn_hash"] = txnHash;
          userPayload["signature"] = signature;
          var user = await createUser(userPayload);
          
          // Catch duplicate email address in the error
          if (user.error == "duplicate_email") {
            showAlertDialog();
          }

          // Catch app version compatibility
          if (user.error == "outdated_app_version") {
            showOutdatedAppVersionDialog(context);
          }
          
          await globals.storage.write(key: "userId", value: user.id);
          // Login
          String loginSignature =
            await signTransaction("hello world", privateKey);
          var loginPayload = {
            "public_key": publicKey,
            "session_key": "hello world",
            "signature": loginSignature,
          };
          await loginUser(loginPayload);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('installed', true);
          Application.router.navigateTo(context, "/addpincode");
          databaseHelper.initializeDatabase();

        }
      } else {
        _showSnackBar("Please agree to our Terms and Conditions");
      }
    } else {
      _showSnackBar("Please correct errors in the form");
    }
  }

  void _showSnackBar(String message) {
    final snackBar =
        new SnackBar(content: new Text(message), backgroundColor: Colors.red);
    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
  }

  List<Widget> _buildContactListForm(BuildContext context) {
    Form form = new Form(
        key: _formKey,
        autovalidate: false,
        child: new ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              new SizedBox(
                height: 30.0,
              ),
              new Center(
                  child: new Text("Sign up to create your wallet",
                      style: TextStyle(
                        fontSize: 20.0,
                      ))),
              new SizedBox(
                height: 10.0,
              ),
              new TextFormField(
                keyboardType: TextInputType.text,
                validator: validateName,
                onSaved: (value) {
                  newUser.firstName = value;
                },
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person_outline),
                  hintText: 'Enter your first name',
                  labelText: 'First Name',
                ),
              ),
              new TextFormField(
                keyboardType: TextInputType.text,
                validator: validateName,
                onSaved: (value) {
                  newUser.lastName = value;
                },
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person),
                  hintText: 'Enter your last name',
                  labelText: 'Last Name',
                ),
              ),
              new TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
                onSaved: (value) {
                  newUser.emailAddress = value;
                },
                decoration: const InputDecoration(
                  icon: const Icon(Icons.email),
                  hintText: 'Enter your email address',
                  labelText: 'Email address',
                ),
              ),
              new SizedBox(
                height: 20.0,
              ),
              new SizedBox(
                height: 15.0,
              ),
              new RaisedButton(
                onPressed: () {
                  _validateInputs(context);
                },
                child: new Text('Submit'),
              )
            ]));

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

}


