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
          Text(
            "Transaction Limits",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: FittedBox(
              child: DataTable(
                columnSpacing: 0,
                columns: [
                  DataColumn(
                    label: Text(
                      'Transaction Limits',
                      style: TextStyle(fontWeight: FontWeight.bold,),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Level 1',
                      style: TextStyle(fontWeight: FontWeight.bold,),
                    )
                  ),
                  DataColumn(
                    label: Text(
                      'Level 2',
                      style: TextStyle(fontWeight: FontWeight.bold,),
                    )
                  ),
                  DataColumn(
                    label: Text(
                      'Level 3',
                      style: TextStyle(fontWeight: FontWeight.bold,),
                    )
                  ),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text('Wallet Size')),
                    DataCell(Text('50K')),
                    DataCell(Text('75K')),
                    DataCell(Text('100K')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Incoming Limit')),
                    DataCell(Text('50K')),
                    DataCell(Text('75K')),
                    DataCell(Text('100K')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Outgoing Limit')),
                    DataCell(Text('50K')),
                    DataCell(Text('75K')),
                    DataCell(Text('100K')),
                  ]),
                ],
              ),
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