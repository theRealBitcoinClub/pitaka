import 'package:flutter/material.dart';
import 'dart:async';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/globals.dart' as globals;
import '../utils/globals.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import '../views/app.dart';
import '../utils/dialog.dart';
import '../api/endpoints.dart';
import '../utils/database_helper.dart';


// Used to access functions in database_helper.dart
DatabaseHelper databaseHelper = DatabaseHelper();

class Contact {
  String mobileNumber;
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
  bool _isContactListEmpty;
  bool _showContactForm = false;
  bool _executeFuture = false;
  bool _popDialog = false;
  var contactDetails = new Map();
  String _error;

  // Initialize a controller for TextFormField.
  // This is used to clear the contents of TextFormField at onPressed 
  TextEditingController _controller = TextEditingController();

  @override
  void initState()  {
    super.initState();
    // Subscribe to Notifier Stream from ConnectionStatusSingleton class in globals.dart
    // Fires whenever connectivity state changes
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);

    // Check if there is/are save contacts
    Future future = Future(() => getContacts());
    future.then((contacts) {
      if (contacts.contacts.length > 0) {
        setState(() {
          _isContactListEmpty = false;
        });
      }
      else {
        setState(() {
          _isContactListEmpty = true;
        });
      }
    });
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
        // For dismissing the dialog
        if (_executeFuture) {
          _executeFuture = false; // Kill or stop the future
          if (_popDialog) {
            _popDialog = false;
            Navigator.of(context,).pop();
          } 
        }
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
              return new Container(
                child: FutureBuilder(
                  future: getContacts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                    return ListView(
                      children: snapshot.data
                          .contacts.map<Widget>((contact) => ListTile(
                            title: Text(contact.firstName + ' ' + contact.lastName),
                            subtitle: Text(contact.mobileNumber),
                            leading: CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Text(contact.firstName[0],
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  )),
                                ),
                              ))
                          .toList(),
                    );
                  },
                )
              );
            }
          }
        }),
        // Toggle hide and show contact
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

  FocusNode focusNode = FocusNode();
  bool _submitting = false;

  var circleUIConfig = new CircleUIConfig();
  var keyboardUIConfig = new KeyboardUIConfig();

  void _validateInputs(BuildContext context) async {
      if (_formKey.currentState.validate()) {
        // Close the on-screen keyboard by removing focus from the form's inputs
        FocusScope.of(context).requestFocus(new FocusNode());

          // If all data are correct then save data to out variables
          _formKey.currentState.save();

          // Set _submitting to true for ModalBarrier and CircularProgressIndicator
          setState(() {
            _submitting = true;
          });

          // Parse the mobile number input to "+639XX XX XXXX" format
          if (newContact.mobileNumber == '0000 - 000 - 0000') {
          } else {
            newContact.mobileNumber = "+63" + newContact.mobileNumber.substring(1).replaceAll(" - ", "");
          }

          // Create contact payload
          var contactPayload = {
            "mobile_number": newContact.mobileNumber,
          };
          // Call createContact request in endpoints.dart 
          // to search registered mobile number
          var contact = await createContact(contactPayload);
          // If response success is true get contact details.
          // Store the contact details in contactDetails map.
          // If response success is false, get the error.
          // Store the error in _error string variable
          if (contact.success) {
            setState(() {
              contactDetails = contact.contact;
            });
          }
          else {
            _error = contact.error;
          }

          // Catch app version compatibility and show dialog
          if (contact.error == "outdated_app_version") {
            showOutdatedAppVersionDialog(context);
          }

          // SharedPreferences prefs = await SharedPreferences.getInstance();
          // await prefs.setBool('installed', true);
          // Application.router.navigateTo(context, "/contactlist");
          setState(() {
            _submitting = false;
          });
    }
  }

  void _saveContact(BuildContext context) async {
    await databaseHelper.updateContactList(contactDetails);
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
            controller: _controller,
            keyboardType: TextInputType.phone,
            validator: validateMobile,
            onSaved: (value) {
              newContact.mobileNumber = value;
            },
            maxLength: 11,
            decoration: const InputDecoration(
              icon: const Icon(Icons.search),
              hintText: '09** - *** - ****',
              labelText: 'Mobile Number',
            ),
          ),

          // If there is error, show accordingly
          _error != null ?
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "$_error",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          )
          :
          // If contactDetails is not empty show details.
          // If empty, show empty container with SizedBox to hide "null" text.
          // Added GestureDetector to the displayed contact details 
          // so when user tap will save to local database.
          contactDetails.isNotEmpty ?
          GestureDetector(
            onTap: () => _saveContact(context),
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(15.0, 15.0, 12.0, 4.0),
                      child: Text(
                        "${contactDetails['firstName']} ${contactDetails['lastName']}",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(15.0, 4.0, 8.0, 15.0),
                      child: Text(
                          "${contactDetails['mobileNumber']}",
                          style: TextStyle(fontSize: 16.0)
                      ),
                    ),
                  ],
                )
              ],
            )
          )
          :
          new Container(
            child: new SizedBox(
              height: 30.0,
            ),
          ),

          new RaisedButton(
            onPressed: () {
              _validateInputs(context);
              // Clear TextFormField
              _controller.clear();  
            },
            child: new Text('Submit'),
          )
        ]
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
  }
}