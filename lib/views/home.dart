import 'dart:async';

import 'package:flutter/material.dart';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import '../components/homeTabs.dart' as hometabs;
import 'package:intl/intl.dart';
import '../api/endpoints.dart';
import '../utils/globals.dart' as globals;
import '../utils/database_helper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import '../utils/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeComponent extends StatefulWidget {
  @override
  State createState() => new HomeComponentState();
}

class HomeComponentState extends State<HomeComponent> {
  String path = "/home";
  bool online = globals.online;
  bool syncing = globals.syncing;
  final formatCurrency = new NumberFormat.currency(symbol: 'PHP ');
  DatabaseHelper databaseHelper = DatabaseHelper();
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;
  bool maxOfflineTime = globals.maxOfflineTime;
  int offlineTime = globals.offlineTime;
  

  @override
  void initState()  {
    super.initState();
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
    /*globals.checkConnection().then((status){
      setState(() {
        if (status == false) {
          online = false;  
          globals.online = online;
          print('Offline');
        } else {
          globals.online = online;
          print('Online');
        }
      });
    });*/
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

        Future.delayed(Duration(milliseconds: 100), () async {
          // Set offlineTime to zero
          globals.offlineTime = 0;
          _save(globals.offlineTime);
          var val = await _read();
          print("It's online, offline timestamp is: $val");
        });

      } else {
        online = false;
        globals.online = online;
        syncing = false;
        globals.syncing = false;
        print("Offline");

        // Wrap arround Future to get the value of previous timestamp
        Future.delayed(Duration(milliseconds: 100), () async {
          // Read the previous value of offlineTime
          var prevTime = await _read();
          print("Previous offline timestamp is: $prevTime");
          if (prevTime == 0) {
            // Get timestamp and save
            globals.offlineTime = DateTime.now().millisecondsSinceEpoch;
            _save(globals.offlineTime);
            var val = await _read();
            print("Get and save a new timestamp: $val");
            globals.timeDiff = 0;
            startTimer();
          }
        });
      }
    });
  }

  // Timer for maximum offline timeout
  Timer _timer;
  int _start = 0;
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
          //if (_start >= 21600 || online == true) {  // 6 hours
          if (_start >= 60 - globals.timeDiff) { // 1 minute
            timer.cancel();
            globals.maxOfflineTime = true;
          } else {
            _start = _start + 1;
            print(_start);
            globals.maxOfflineTime = false;
          }
        }));
  }

  _read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'offlineTimeKey';
    final value = prefs.getInt(key) ?? 0;
    return value;
  }

  _save(val) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'offlineTimeKey';
    final value = val;
    prefs.setInt(key, value);
  }

  @override
  void dispose() {
   // _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    return DefaultTabController (
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Paytaca'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                child: online ? new Icon(Icons.wifi): new Icon(Icons.signal_wifi_off),
             /*   onTap: (){
                  if (globals.syncing == false) {
                    globals.checkConnection().then((status){
                      setState(() {
                        if (status == true) {
                          online = !online;  
                          globals.online = online;
                          syncing = true;
                          globals.syncing = true;
                          print('Online mode');

                        } else {
                          online = false;  
                          globals.online = online;
                          syncing = false;
                          globals.syncing = false;
                          print('Offline mode');
                        }
                      });
                    });
                  }
                }*/
              )
            )
          ],
          bottom: TabBar(tabs: [
            Tab(
              text: "Accounts",
            ),
            Tab(text: "Transactions"),
          ]),
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body:  TabBarView(
          children: [
            // accountsTab,
            new Builder(builder: (BuildContext context) {
              return new Container(
                alignment: Alignment.center,
                child: new FutureBuilder(
                  future: globals.online == false ? getOffLineBalances() :  getOnlineBalances(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        if (snapshot.data.success) {
                          var balances = snapshot.data.balances;
                          return hometabs.buildBalancesList(balances);
                        } else {
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
            }),
            // transactionsTab
            new Builder(builder: (BuildContext context) {
              return new Container(
                alignment: Alignment.center,
                child: new FutureBuilder(
                  future: globals.online ?  getOnlineTransactions() : getOffLineTransactions(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        if (snapshot.data.transactions.length > 0) {
                          return hometabs.buildTransactionsList(snapshot.data.transactions);
                        } else {
                          return Text('No transactions to display');
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
            })
          ],
        ),
        bottomNavigationBar: buildBottomNavigation(context, path),
      )
    );
  }
}