import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import '../utils/globals.dart';
import '../utils/dialogs.dart';
import '../api/endpoints.dart';
import '../utils/database_helper.dart';
import '../utils/globals.dart' as globals;
import '../components/contactListView.dart' as contactlist;

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
  String _error;
  String _ownNumber;
  String selectedPaytacaAccount;
  int accountIndex = 0;
  bool online = globals.online;
  bool isOffline = false;
  bool _isContactListEmpty = true;
  bool _showContactForm = false;
  bool _executeFuture = false;
  bool _popDialog = false;
  bool _submitting = false;
  var contactDetails = new Map();
  final _formKey = GlobalKey<FormState>();
  static List data = List(); //edited line
  StreamSubscription _connectionChangeStream;
  
  // Initialize a controller for TextFormField.
  // This is used to clear the contents of TextFormField at onPressed 
  TextEditingController _controller = TextEditingController();
  // Used for contact instance
  Contact newContact = new Contact();

  @override
  void initState()  {
    super.initState();

    // Start listening to changes in TextFormField for mobile number input
    _controller.addListener((){

      // if (_controller.text.length == 11){
      //   _validateInputs(context);
      // }

      // Clear _error and contactDetails during new search
      // This will prevent the duplicating of error on registered mobile number after error occurs
      if (_controller.text.length == 0){
        _error = null;
        contactDetails = {};
      }
    });

    // Get stored mobile number
    getMobileNumber();
    
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

  @override
  void dispose() {
    _controller.dispose(); // release unused memory in RAM
    super.dispose();
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
            if (globals.online) {
              return new Stack(children: _buildContactListForm(context));
            }
            else {
              return Center(
                child: new Padding(
                  padding: EdgeInsets.all(8.0),
                  child:new Container(
                    child: Text(
                      "This is not available in offline mode.",
                    )
                  )
                )
              );
            }
          }
          else {     
            return Builder(builder: (BuildContext context) {
              return new Container(
                alignment: Alignment.center,
                child: new FutureBuilder(
                  future: getContacts(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        if (snapshot.data.contacts.length > 0) {
                          return contactlist.buildContactList(snapshot.data.contacts);
                        } 
                        else {
                          return Text(
                            "You're contact list is empty. Create by tapping the '+ person' icon button.",
                            textAlign: TextAlign.center,
                          );
                        }
                      } else {
                        return new CircularProgressIndicator();  
                      }
                    } else {
                      // return new Container();
                      return new CircularProgressIndicator();
                    }
                  }
                )
              );
            });
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
      // Uncomment to center the FloatingActionButtonLocation button
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: buildBottomNavigation(context, path)
    );
  }

  Future<String> getMobileNumber() async {
    // Get stored mobile number and used to compare the user input
    SharedPreferences prefs =  await SharedPreferences.getInstance();
    // Convert "+63" to "09" format
    _ownNumber = "0" + prefs.getString('mobileNumber').substring(3,13);
    return _ownNumber;
  }

  String validateMobile(String value) {
    if (value == '0000 - 000 - 0000') {
      return null;
    } else {
      // Check if user is searching its own number
      if (value == _ownNumber) {
        return "It's your own number!";
      }
      else if (value.startsWith('09')){
        return null;
      } else {
        return 'Invalid phone number';
      }
    }
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
              )
            )
          ),
          new SizedBox(
            height: 10.0,
          ),
          new TextFormField(
            autofocus: true,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    ),
                    // For save icon
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.save,
                              size: 40.0,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                ),
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

  String validateAmount(String value) {
    if (value == null || value == "") {
      return 'This field is required.';
    } else if (value == '0') {
      return 'Please enter valid amount.';
    } else {
      var currentBalance;
      for(final map in data) {
        if(selectedPaytacaAccount ==  map['accountId']){
          currentBalance = map['computedBalance'];
          break;
        }
      }
      if (double.parse(currentBalance) < double.parse(value)) {
        return 'Insufficient balance';
      } else {
        if (double.parse(value) >= 100000) {
          return 'Max limit of Php 100,000.00 per transaction';
        } else {
          return null;
        } 
      }
    }
  }

  void _saveContact(BuildContext context) async {
    // Save to local database
    var resp = await databaseHelper.updateContactList(contactDetails);

    // Display the unique constraint or duplicate error
    setState(() {
      if (resp == 'contact save') {
        _showContactForm = false;
      } 
      else {
        _error = resp;
      }
    });

    // Create contact payload
    var contactPayload = {
      "mobile_number": newContact.mobileNumber,
    };
    // Save to server's database
    var contact = await saveContact(contactPayload);

    if (contact.success) {
      _showContactForm = false;
      setState(() {
        contactDetails = contact.contact;
      });
    }

    // Clear the _error and contactDetails to show next searched contact
    _error = "";
    contactDetails = {};
  }

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
      var contact = await searchContact(contactPayload);
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
        setState(() {
          _error = contact.error;
        });
      }

      // Catch app version compatibility and show dialog
      if (contact.error == "outdated_app_version") {
        showOutdatedAppVersionDialog(context);
      }
      
      // Hide ModalBarrier and CircularProgressIndicator
      setState(() {
        _submitting = false;
      });

      // Clear mobile number TextFormField input after request
      _controller.clear();
    }
  }
}
