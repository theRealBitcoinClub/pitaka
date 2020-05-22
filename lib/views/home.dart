import 'dart:async';
import 'receive.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import '../api/endpoints.dart';
import './app.dart';
import '../utils/helpers.dart';
import '../utils/dialogs.dart';
import '../utils/globals.dart';
import '../utils/database_helper.dart';
import '../utils/globals.dart' as globals;
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import '../components/homeTabs.dart' as hometabs;


class HomeComponent extends StatefulWidget {
  @override
  State createState() => new HomeComponentState();
}

class HomeComponentState extends State<HomeComponent> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  StreamSubscription _connectionChangeStream;
  final formatCurrency = new NumberFormat.currency(symbol: 'PHP ');
  String path = "/home";
  String storedUdid;
  String freshUdid;
  bool online = globals.online;
  bool syncing = globals.syncing;
  bool isOffline = false;
  bool _executeFuture = false;
  bool _popDialog = false;

  void initState()  {
    super.initState();
    // Subscribe to Notifier Stream from ConnectionStatusSingleton class in globals.dart
    // Fires whenever connectivity state changes
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);

    ReceiveComponentState comp = new ReceiveComponentState();

    comp.getAccounts();

    _checkUdid();

    initDynamicLinks();
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! $deepLink !!!!!!!!!!!!!!!!!!!!!!!");

    if (deepLink != null) {
      //Navigator.pushNamed(context, deepLink.path);
      Application.router.navigateTo(context, "/send");
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@ $deepLink @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
      print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ${deepLink.path} @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

      if (deepLink != null) {
        Application.router.navigateTo(context, "/send");
        // Navigator.pushNamed(context, "/userprofile");
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  void _checkUdid() async {
    storedUdid = await globals.storage.read(key: "udid");
    freshUdid = await FlutterUdid.consistentUdid;
    print("The value of UDID in _checkUdid() in home.dart is: $freshUdid");
    //freshUdid = '14490a8175339cb79cca9cb169644cb75354c2706e528d70c6c646621829a655';
    // If storedUdid does not match with freshUdid, show undismissible dialog
    if (storedUdid != freshUdid) {
      showUnregisteredUdidDialog(context);
    }
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

  void reLogin() async {
    // Read public and private key from global storage
    // To be use to re-login user when session expires
    String publicKey = await globals.storage.read(key: "publicKey");
    String privateKey = await globals.storage.read(key: "privateKey");
    // Re-login
    String loginSignature =
      await signTransaction("hello world", privateKey);
    var loginPayload = {
      "public_key": publicKey,
      "session_key": "hello world",
      "signature": loginSignature,
    };
    loginUser(loginPayload);
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
                  // Added condition, when both syncing and online are true get offline balances
                  future: globals.syncing && globals.online ? getOffLineBalances() : globals.online == false ? getOffLineBalances() : getOnlineBalances(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    // To show progress loading view add switch statment to handle connnection states.
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        {
                          // Show loading view in waiting state.
                          return loadingView();
                        }
                      case ConnectionState.active:
                        {
                          break;
                        }
                      case ConnectionState.done:
                        {
                          if (snapshot.hasData) {
                            if (snapshot.data != null) {
                              print("The value of snapshot.data.error is: ${snapshot.data.error}");
                              var balances = snapshot.data.balances;
                              if (snapshot.data.success) {
                                return hometabs.buildBalancesList(balances);
                              } 
                              // If error is unauthorized, re-login
                              else if (snapshot.data.error == 'unauthorized') {
                                reLogin();
                              }
                              // When connect timeout error, show message
                              // ANDing with globals.online prevents showing the dialog 
                              // during manually swithing to airplane mode
                              else if (snapshot.data.error == 'connect_timeout' && globals.online) {
                                //print("The value of snapshot.data in getting balances is: ${snapshot.data.error}");
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
                              // When invalid device ID error, show dialog
                              // ANDing with globals.online prevents showing the dialog 
                              // during manually swithing to airplane mode
                              else if (snapshot.data.error == 'invalid_device_id' && globals.online) {
                                Future.delayed(Duration(milliseconds: 100), () async {
                                  _executeFuture = true;
                                  if(_executeFuture){
                                    showUnregisteredUdidDialog(context);
                                  }
                                });
                              } 
                              else {
                                return noDataView("No data found");
                              }
                            } else {
                                return noDataView("No data found");
                            }
                          } else {
                            return noDataView("No data found");
                          }
                          return new Container();
                        }
                      case ConnectionState.none:
                        {
                          break;
                        }
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
                  future: globals.online ? getOnlineTransactions() : getOffLineTransactions(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    // To show progress loading view add switch statment to handle connnection states.
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        {
                          // Show loading view in waiting state.
                          return loadingView();
                        }
                      case ConnectionState.active:
                        {
                          break;
                        }
                      case ConnectionState.done:
                        {
                          if (snapshot.hasData) {
                            if (snapshot.data != null) {
                              if (snapshot.data.transactions.length > 0) {
                                return hometabs.buildTransactionsList(snapshot.data.transactions);
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
                              // When invalid device ID error, show dialog
                              // ANDing with globals.online prevents showing the dialog 
                              // during manually swithing to airplane mode
                              else if (snapshot.data.error == 'invalid_device_id' && globals.online) {
                                Future.delayed(Duration(milliseconds: 100), () async {
                                  _executeFuture = true;
                                  if(_executeFuture){
                                    showUnregisteredUdidDialog(context);
                                  }
                                });
                              } 
                              else {
                                return Text('No transactions to display');
                              }
                            } else {
                              return noDataView("No data found");  
                            }
                          } else {
                            return noDataView("No data found");
                          }
                          return new Container();
                        }
                      case ConnectionState.none:
                        {
                          break;
                        }
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

  // Progress indicator widget to show loading.
  Widget loadingView() => Center(
        child: CircularProgressIndicator(), 
      );

  // View to empty data message
  Widget noDataView(String msg) => Center(
        child: Text(
          msg,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      );
}