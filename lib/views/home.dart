import 'dart:async';
import 'package:flutter/material.dart';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import '../components/homeTabs.dart' as hometabs;
import 'package:intl/intl.dart';
import '../api/endpoints.dart';
import '../utils/globals.dart' as globals;
import '../utils/database_helper.dart';
import '../utils/globals.dart';
import 'receive.dart';
import 'package:easy_dialog/easy_dialog.dart';


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
  bool _executeFuture = false;


  @override
  void initState()  {
    super.initState();
    // Subscribe to Notifier Stream from ConnectionStatusSingleton class in globals.dart
    // Fires whenever connectivity state changes
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);

    ReceiveComponentState comp = new ReceiveComponentState();

    comp.getAccounts();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      if(isOffline == false) {
        online = !online;
        globals.online = online;
        syncing = true;
        globals.syncing = true;
        print("Online");
      } else {
        online = false;
        globals.online = online;
        syncing = false;
        globals.syncing = false;
        print("Offline");
        // For dismissing the dialog
        _executeFuture = false; // Kill or stop the future
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
   // _connectivitySubscription.cancel();
    super.dispose();
  }

  // Alert dialog for slow internet speed connection
  // This is called during build and when there is connection timeout error response
  showAlertDialog() {
    EasyDialog(
      title: Text(
        "Slow Internet Connection!",
        style: TextStyle(fontWeight: FontWeight.bold),
        textScaleFactor: 1.2,
      ),
      description: Text(
        "Your internet speed connection is too slow. Switch to Airplane mode to continue making transaction.",
        textScaleFactor: 1.1,
        textAlign: TextAlign.center,
      ),
      height: 120,
      closeButton: false,  
    ).show(context);
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
                child: globals.online ? new Icon(Icons.wifi): new Icon(Icons.signal_wifi_off),
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
                  future: globals.online == false ? getOffLineBalances() : getOnlineBalances(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data != null) {
                        var balances = snapshot.data.balances;
                        if (snapshot.data.success) {
                          return hometabs.buildBalancesList(balances);
                        } 
                        // When connect timeout error, show dialog
                        // ANDing with globals.online prevents showing the dialog 
                        // during manually swithing to airplane mode
                        else if (snapshot.data.error == 'connect_timeout' && globals.online) {
                          Future.delayed(Duration(milliseconds: 100), () async {
                            _executeFuture = true;
                            if(_executeFuture){
                              showAlertDialog();
                            }
                          });
                          // Return hometabs to show the balance 
                          return hometabs.buildBalancesList(balances);
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
                        }
                        // When connect timeout error, show dialog
                        // ANDing with globals.online prevents showing the dialog 
                        // during manually swithing to airplane mode 
                        else if (snapshot.data.error == 'connect_timeout' && globals.online) {
                          Future.delayed(Duration(milliseconds: 100), () async {
                            _executeFuture = true;
                            if(_executeFuture){
                              showAlertDialog();
                            }
                          });
                          // Return hometabs to show the balance 
                          return hometabs.buildTransactionsList(snapshot.data.transactions);
                        } 
                        else {
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