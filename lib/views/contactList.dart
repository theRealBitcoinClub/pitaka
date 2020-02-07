
import 'package:flutter/material.dart';
import 'dart:async';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/globals.dart' as globals;
import '../utils/globals.dart';


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
            return new Stack(children: _buildForm(context));
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

  List<Widget> _buildForm(BuildContext context) {
    Form form = new Form(
      key: _formKey,
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new SizedBox(
            height: 20.0,
          ),
          new SizedBox(
            height: 20.0,
          ),
        ],
      )
    );
    var ws = new List<Widget>();
    ws.add(form);
    return ws;
  }
}
