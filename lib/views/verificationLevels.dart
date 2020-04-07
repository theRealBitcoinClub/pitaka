import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../views/app.dart';
import '../api/endpoints.dart';
import '../utils/helpers.dart';
import '../utils/globals.dart';
import '../utils/dialogs.dart';
import '../utils/database_helper.dart';
import '../utils/globals.dart' as globals;
import 'dart:math';


class VerificationLevelsComponent extends StatefulWidget {
  @override
  VerificationLevelsComponentState createState() => new VerificationLevelsComponentState();
}

class VerificationLevelsComponentState extends State<VerificationLevelsComponent> {
  StreamSubscription _connectionChangeStream;
  DatabaseHelper databaseHelper = DatabaseHelper();
  static bool _errorFound = false;
  static String _errorMessage;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountController = new TextEditingController();
  String newVal;
  String sessionKey = '';
  bool isOffline = false;
  bool _submitting = false;
  bool online = globals.online;
  bool disableSubmitButton = false;
  bool transactionLimitsTable = true;
  bool levelUp = false;
  bool maxOfflineTime = globals.maxOfflineTime;
  int offlineTime = globals.offlineTime;

  @override
  void initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      if (isOffline == false) {
        online = !online;
        globals.online = online;
        syncing = true;
        globals.syncing = true;
        globals.maxOfflineTime = false;
        print("Online");
      } else {
        online = false;
        globals.online = online;
        syncing = false;
        globals.syncing = false;
        print("Offline");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification Levels'),
        centerTitle: true,
        leading: IconButton(icon:Icon(Icons.arrow_back),
          onPressed:() => Navigator.pop(context, false),
        ),
      ),
      body: new Builder(builder: (BuildContext context) {
        return new Stack(children: _buildForm(context));
      }),
    );
  }

  List<Widget> _buildForm(BuildContext context) {
    Form form = new Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          OutlineButton(
            onPressed: () {
              setState(() {
                transactionLimitsTable = !transactionLimitsTable;
              });
            },
            child: Stack(
              children: <Widget>[
                transactionLimitsTable ?
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.keyboard_arrow_down, color: Colors.redAccent,)
                  )
                :
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.keyboard_arrow_up, color: Colors.redAccent,)
                  ),
                Padding(
                  padding: EdgeInsets.only(left: 25.0, top: 2.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Transaction Limits",
                      textAlign: TextAlign.left,
                    )
                  )
                )
              ],
            ),
            borderSide: BorderSide(color: Colors.grey[400]),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0)
            )
          ),
          SizedBox(height: 10,),
          Visibility(
            visible: transactionLimitsTable,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: FittedBox(
                child: DataTable(
                  columnSpacing: 0,
                  columns: [
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.only(top: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Transaction          ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                            Text(
                              'Limits                    ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            )
                          ]
                        )
                      )
                    ),
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.security, color: Colors.red[200],),
                            Text(
                              'Level 1',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )
                          ]
                        )
                      )
                    ),
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.only(top: 8.0), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.security, color: Colors.red[300],),
                            Text(
                              'Level 2',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )
                          ]
                        )
                      )
                    ),
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.security, color: Colors.red[400],),
                            Text(
                              'Level 3',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )
                          ]
                        )
                      )
                    ),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(
                        Text(
                          'Wallet Size', 
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ),
                      DataCell(Text('50K')),
                      DataCell(Text('75K')),
                      DataCell(Text('100K')),
                    ]),
                    DataRow(cells: [
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Incoming Limit',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text('- Monthly    '),
                            Text('- Yearly        '),
                          ] 
                        )
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(''),
                            Text('50K'),
                            Text('50K'),
                          ] 
                        )
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(''),
                            Text('100K'),
                            Text('100K'),
                          ] 
                        )
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(''),
                            Text('100K'),
                            Text('100K'),
                          ] 
                        )
                      ),
                    ]),
                    DataRow(cells: [
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Outgoing Limit',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text('- Daily          '),
                            Text('- Monthly    '),
                          ] 
                        )
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(''),
                            Text('40K'),
                            Text('100K'),
                          ] 
                        )
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(''),
                            Text('75K'),
                            Text('75K'),
                          ] 
                        )
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(''),
                            Text('100K'),
                            Text('100K'),
                          ] 
                        )
                      ),
                    ]),
                  ],
                ),
              )
            ),
          ),
          SizedBox(height: 30.0,),
          OutlineButton(
            onPressed: () {
              setState(() {
                levelUp = !levelUp;
              });            
            },
            child: Stack(
              children: <Widget>[
                levelUp ?
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.keyboard_arrow_down, color: Colors.redAccent,)
                  )
                :
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.keyboard_arrow_up, color: Colors.redAccent,)
                  ),
                Padding(
                  padding: EdgeInsets.only(left: 25.0, top: 2.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "How to Level Up",
                      textAlign: TextAlign.left,
                    )
                  )
                )
              ],
            ),
            borderSide: BorderSide(color: Colors.grey[400]),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0)
            )
          ),
          Visibility(
            visible: levelUp,
            child: Padding (
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20.0,),
                  Row(
                    children: <Widget>[
                      Icon(Icons.security, color: Colors.red[200],),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0,),
                        child: Text(
                          "Level 1",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      )
                    ]
                  ),
                  SizedBox(height: 10.0,),
                  Text(
                    "Register to Paytaca",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12.0,
                    ),
                  ),
                  SizedBox(height: 25.0,),
                  Row(
                    children: <Widget>[
                      Icon(Icons.security, color: Colors.red[300],),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0,),
                        child: Text(
                          "Level 2",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      )
                    ]
                  ),
                  SizedBox(height: 10.0,),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.email, color: Colors.redAccent,),
                                Text(
                                  "Register",
                                  style: TextStyle(fontSize: 10.0),
                                ),
                                Text(
                                  "email",
                                  style: TextStyle(fontSize: 10.0),
                                )                           
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 30.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "- -",
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Text(
                                " > ",
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Text(
                                "- -",
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.contact_mail, color: Colors.redAccent,),
                                Text(
                                  "Confirm",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                ),
                                Text(
                                  "email",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 30.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "   ",
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Text(
                                "   ",
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Text(
                                "   ",
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Column(
                              children: <Widget>[
                                //Icon(Icons.security, color: Colors.redAccent,),
                                Text(
                                  "",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                ),
                                Text(
                                  "",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 30.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "   ",
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Text(
                                "   ",
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Text(
                                "   ",
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Column(
                              children: <Widget>[
                                //Icon(Icons.security, color: Colors.redAccent,),
                                Text(
                                  "",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                ),
                                Text(
                                  "",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ]
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Text(
                    "Valid only for 1 year or until you reach the 100,000 incoming limit. "
                    "After this, your account will return to Level 1 status. "
                    "Fully verify your account to continue enjoying all Paytaca.",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12.0,
                    ),
                  ),
                  SizedBox(height: 25.0,),
                  Row(
                    children: <Widget>[
                      Icon(Icons.security, color: Colors.red[400],),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0,),
                        child: Text(
                          "Level 3",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      )
                    ]
                  ),
                  SizedBox(height: 10.0,),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.photo, color: Colors.redAccent,),
                                Text(
                                  "Take ID",
                                  style: TextStyle(fontSize: 10.0),
                                ),
                                Text(
                                  "photo",
                                  style: TextStyle(fontSize: 10.0),
                                )                           
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 30.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "- -",
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Text(
                                " > ",
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Text(
                                "- -",
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.account_box, color: Colors.redAccent,),
                                Text(
                                  "Take",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                ),
                                Text(
                                  "selfie",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 30.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "- -",
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Text(
                                " > ",
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Text(
                                "- -",
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.playlist_add, color: Colors.redAccent,),
                                Text(
                                  "Fill",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                ),
                                Text(
                                  "information",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 30.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "- -",
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Text(
                                " > ",
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Text(
                                "- -",
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.playlist_add_check, color: Colors.redAccent,),
                                Text(
                                  "Submit",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                ),
                                Text(
                                  "application",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ]
                    ),
                  )
                ]
              )
            )
          )
        ],
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
    if (_errorFound) {
      var modal = new Stack(
        children: [
          AlertDialog(
            title: Text('Success'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('$_errorMessage')
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Got it!'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Application.router.navigateTo(context, "/send");
                  _errorMessage = '';
                  _errorFound = false;
                },
              ),
            ],
          )
        ]
      );
      ws.add(modal);
    }
    if (_errorFound) {
      var modal = new Stack(
        children: [
          AlertDialog(
            title: Text('Success'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('$_errorMessage')
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Got it!'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Application.router.navigateTo(context, "/send");
                  _errorMessage = '';
                  _errorFound = false;
                },
              ),
            ],
          )
        ]
      );
      ws.add(modal);
    }
    return ws;
  }
}