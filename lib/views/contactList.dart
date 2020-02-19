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
import '../components/contactListView.dart' as listview;


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
  bool _isContactListEmpty = true;
  bool _showContactForm = false;
  bool _executeFuture = false;
  bool _popDialog = false;
  var contactDetails = new Map();

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
              new Builder(builder: (BuildContext context) {
                return new Container(
                  alignment: Alignment.center,
                  child: new FutureBuilder(
                    // Added condition, when both syncing and online are true get offline balances
                    future: getContactList(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data != null) {
                          var contacts = snapshot.data.contacts;
                          if (snapshot.data.success) {
                            return listview.buildContactList(contacts);
                          } 
                          // When connect timeout error, show message
                          // ANDing with globals.online prevents showing the dialog 
                          // during manually swithing to airplane mode
                          else if (snapshot.data.error == 'connect_timeout' && globals.online) {
                            return Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                "You don't seem to have internet connection, or it's too slow. " 
                                "Switch your phone to Airplane mode to keep using the app in offline mode.",
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          // When maintainance mode error, show message
                          // ANDing with globals.online prevents showing the dialog 
                          // during manually swithing to airplane mode
                          else if (snapshot.data.error == 'maintenance_mode' && globals.online) {
                            return Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                "Server is down for maintenance. " 
                                "Please try again later or switch your phone to Airplane mode to keep using the app in offline mode.",
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          // When app version error, show dialog
                          // ANDing with globals.online prevents showing the dialog 
                          // during manually swithing to airplane mode
                          else if (snapshot.data.error == 'outdated_app_version' && globals.online) {
                            Future.delayed(Duration(milliseconds: 100), () async {
                              _executeFuture = true;
                              if(_executeFuture){
                                showOutdatedAppVersionDialog(context);
                              }
                            });
                          } 
                          else {
                            return new CircularProgressIndicator();
                          }
                        } else {
                          return new CircularProgressIndicator();
                        }
                      } else {
                        return new CircularProgressIndicator();
                      }
                    }
                  )
                );
              });
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

  BuildContext _scaffoldContext;
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
          setState(() {
            _submitting = true;
          });

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
        setState(() {
          contactDetails = contact.contact;
        });
        print(contactDetails);
        print("${contact.contact['firstName']}");

        // Catch app version compatibility
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
          // If contactDetails is not empty show details.
          // If empty, show empty container with SizedBox to hide "null" text.
          // Added GestureDetector to the displayed contact details 
          // so when user tap will save to local database.
          contactDetails.isNotEmpty ?
          GestureDetector(
            onTap: () => print("Save this contact!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"),
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






// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';


// class ContactListComponent extends StatefulWidget {
//   // ExamplePage({ Key key }) : super(key: key);
//   @override
//   ContactListComponentState createState() => new ContactListComponentState();
// }

// class ContactListComponentState extends State<ContactListComponent> {
//  // final formKey = new GlobalKey<FormState>();
//  // final key = new GlobalKey<ScaffoldState>();
//   final TextEditingController _filter = new TextEditingController();
//   final dio = new Dio();
//   String _searchText = "";
//   List names = new List();
//   List filteredNames = new List();
//   Icon _searchIcon = new Icon(Icons.search);
//   Widget _appBarTitle = new Text( 'Search Example' );

//   ExamplePageState() {
//     _filter.addListener(() {
//       if (_filter.text.isEmpty) {
//         setState(() {
//           _searchText = "";
//           filteredNames = names;
//         });
//       } else {
//         setState(() {
//           _searchText = _filter.text;
//         });
//       }
//     });
//   }

//   @override
//   void initState() {
//     this._getNames();
//     super.initState();
//   }

//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildBar(context),
//       body: Container(
//         child: _buildList(),
//       ),
//       resizeToAvoidBottomPadding: false,
//     );
//   }

//   Widget _buildBar(BuildContext context) {
//     return new AppBar(
//       centerTitle: true,
//       title: _appBarTitle,
//       leading: new IconButton(
//         icon: _searchIcon,
//         onPressed: _searchPressed,

//       ),
//     );
//   }

//   Widget _buildList() {
//     if (!(_searchText.isNotEmpty)) {
//       List tempList = new List();
//       for (int i = 0; i < filteredNames.length; i++) {
//         if (filteredNames[i]['name'].toLowerCase().contains(_searchText.toLowerCase())) {
//           tempList.add(filteredNames[i]);
//         }
//       }
//       filteredNames = tempList;
//     }
//     return ListView.builder(
//       itemCount: names == null ? 0 : filteredNames.length,
//       itemBuilder: (BuildContext context, int index) {
//         return new ListTile(
//           title: Text(filteredNames[index]['name']),
//           onTap: () => print(filteredNames[index]['name']),
//         );
//       },
//     );
//   }

//   void _searchPressed() {
//     setState(() {
//       if (this._searchIcon.icon == Icons.search) {
//         this._searchIcon = new Icon(Icons.close);
//         this._appBarTitle = new TextField(
//           controller: _filter,
//           decoration: new InputDecoration(
//             prefixIcon: new Icon(Icons.search),
//             hintText: 'Search...'
//           ),
//         );
//       } else {
//         this._searchIcon = new Icon(Icons.search);
//         this._appBarTitle = new Text( 'Search Example' );
//         filteredNames = names;
//         _filter.clear();
//       }
//     });
//   }

//   void _getNames() async {
//     final response = await dio.get('https://swapi.co/api/people');
//     List tempList = new List();
//     for (int i = 0; i < response.data['results'].length; i++) {
//       tempList.add(response.data['results'][i]);
//     }
//     setState(() {
//       names = tempList;
//       names.shuffle();
//       filteredNames = names;
//     });
//   }


// }