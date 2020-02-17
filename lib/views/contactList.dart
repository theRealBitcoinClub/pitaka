import 'package:flutter/material.dart';
import 'dart:async';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/globals.dart' as globals;
import '../utils/globals.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:easy_dialog/easy_dialog.dart';
import '../views/app.dart';
import '../utils/dialog.dart';
import '../api/endpoints.dart';


class Contact {
  String mobileNumber;
  String emailAddress;
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
  bool _showContactForm = false;

  @override
  void initState()  {
    super.initState();
    // Subscribe to Notifier Stream from ConnectionStatusSingleton class in globals.dart
    // Fires whenever connectivity state changes
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
  void dispose() {
    super.dispose();
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
            if (_showContactForm) {
              return new Stack(children: _buildContactListForm(context));
            }
            else {
              return new Container();
            }
          }
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              if (!_showContactForm) {
                _showContactForm = true;
                _isContactListEmpty = false;
              }
              else {
                _showContactForm = false;
              }
            }); 
          },
          child: Icon(Icons.person_add),
          backgroundColor: Colors.red,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: buildBottomNavigation(context, path)
      );
  }

  Contact newContact = new Contact();

  String validateMobile(String value) {
    if (value == '0000 - 000 - 0000') {
      return null;
    } else {
      if (value.startsWith('09')){
        return null;
      } else {
        return 'Invalid phone number';
      }
    }
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

  BuildContext _scaffoldContext;
  FocusNode focusNode = FocusNode();
  bool _submitting = false;

  var circleUIConfig = new CircleUIConfig();
  var keyboardUIConfig = new KeyboardUIConfig();

  onDialogClose() {
    // Not use
  }

  // Alert dialog for duplicate email address
  showAlertDialog() {
    EasyDialog(
      title: Text(
        "Duplicate Email Address!",
        style: TextStyle(fontWeight: FontWeight.bold),
        textScaleFactor: 1.2,
      ),
      description: Text(
        "The email address is already registered. Please use other email address",
        textScaleFactor: 1.1,
        textAlign: TextAlign.center,
      ),
      height: 160,
      closeButton: false,
      contentList: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FlatButton(
              padding: EdgeInsets.all(8),
              textColor: Colors.lightBlue,
              onPressed: () {
                Navigator.of(context).pop();
                // Use same mobile number after retry on duplicate email 
                Application.router.navigateTo(context, "/contactlist");
              },
              child: new Text("OK",
                textScaleFactor: 1.2,
                textAlign: TextAlign.center,
              ),),
           ],)
      ]
    ).show(context, onDialogClose);
  }

 void _validateInputs(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      // Close the on-screen keyboard by removing focus from the form's inputs
      FocusScope.of(context).requestFocus(new FocusNode());

        // If all data are correct then save data to out variables
        _formKey.currentState.save();
          setState(() {
            _submitting = true;
          });

          // Read the user ID from globals.storage and include in the payload
          String userId = await globals.storage.read(key: "userId");

          // Create contact payload
          var contactPayload = {
            "mobile_number": newContact.mobileNumber,
            "email": newContact.emailAddress,
            "user_id": userId,
          };

          var contact = await createContact(contactPayload);

          print("The value of contact.error is: ${contact.error}");
          print("The value of contact.success is: ${contact.success}");
          
          // Catch duplicate email address in the error
          if (contact.error == "duplicate_email") {
            showAlertDialog();
          }

          // Catch app version compatibility
          if (contact.error == "outdated_app_version") {
            showOutdatedAppVersionDialog(context);
          }

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('installed', true);
          Application.router.navigateTo(context, "/contactlist");
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
                  child: new Text("Create contact",
                      style: TextStyle(
                        fontSize: 20.0,
                      ))),
              new SizedBox(
                height: 10.0,
              ),
              new TextFormField(
                keyboardType: TextInputType.text,
                validator: validateMobile,
                onSaved: (value) {
                  newContact.mobileNumber = value;
                },
                maxLength: 11,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.phone_android),
                  hintText: '09** - *** - ****',
                  labelText: 'Mobile Number',
                ),
              ),
              new TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
                onSaved: (value) {
                  newContact.emailAddress = value;
                },
                decoration: const InputDecoration(
                  icon: const Icon(Icons.email),
                  hintText: 'example@email.com',
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

