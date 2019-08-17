import 'package:flutter/material.dart';
import '../../components/drawer.dart';
import '../../views/app.dart';
import '../../api/endpoints.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/globals.dart';
import 'dart:async';

class BusinessToolsComponent extends StatefulWidget {
  @override
  BusinessToolsComponentState createState() => new BusinessToolsComponentState();
}

class BusinessToolsComponentState extends State<BusinessToolsComponent> {
  bool _loading = true;
  bool online = globals.online;
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;

  Future<String> getReferences() async {
    await getBusinesReferences();
    setState(() {
      _loading = false;
    });
    return 'Success';
  }

  @override
  void initState() {
    super.initState();
    this.getReferences();
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
  /*  globals.checkConnection().then((status){
      setState(() {
        if (status == false) {
          online = false;  
          globals.online = online;
        } else {
          globals.online = online;
        }
      });
    });*/
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      if(isOffline == false) {
        online = false;
        globals.online = online;
        print("Online");
      } else {
        online = false;
        globals.online = online;
        print("Offline");
      }
    });
  }

  List<Map<String, dynamic>> tools = [
    {
      'title': 'Businesses',
      'subtitle': 'List of businesses',
      'path': '/businesses'
    },
    {
      'title': 'Register Business',
      'subtitle': 'Apply for business registration',
      'path': '/registerbusiness'
    },
    {
      'title': 'Set Business Account',
      'subtitle': 'Link a registered business to an account',
      'path': '/setbusinessaccount'
    }
  ];

  Widget buildBody(BuildContext context, int index) {
    return Card(
      color: Colors.white,
      elevation: 2.0,
      child: ListTile(
        title: Text("${tools[index]['title']}"),
        subtitle: Text("${tools[index]['subtitle']}"),
        onTap: (){
          Application.router.navigateTo(context, "${tools[index]['path']}");
        },
      )
    );
  }

  Widget bodyFunc() {
    if (globals.online) {
      if (_loading == true) {
        return new Center(child: CircularProgressIndicator());
      } else {
        return new ListView.builder
        (
          itemCount: tools.length,
          itemBuilder: (BuildContext ctxt, int index) => buildBody(ctxt, index)
        );
      }
    }  else {
      return new Center(
        child: new Padding(
            padding: EdgeInsets.all(8.0),
            child:new Container(
            child: Text(
              "This is not available in offline mode.",
              style: TextStyle(fontSize: 18.0)
            )
          )
        )
      );
    }
    
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Business Tools'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                child: online ? new Icon(Icons.wifi): new Icon(Icons.signal_wifi_off),
               /* onTap: (){
                  globals.checkConnection().then((status){
                    setState(() {
                      if (status == true) {
                        online = !online;  
                        globals.online = online;  
                      } else {
                        online = false;  
                        globals.online = online;
                      }
                    });
                  });
                }*/
              )
            )
          ],
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body: bodyFunc(),
      );
  }
}
