import 'dart:async';
import 'receive.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import './app.dart';
import '../api/endpoints.dart';
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
  State createState() => HomeComponentState();
}

class HomeComponentState extends State<HomeComponent> with SingleTickerProviderStateMixin {
  DatabaseHelper databaseHelper = DatabaseHelper();
  final formatCurrency = new NumberFormat.currency(symbol: 'PHP ');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  ScrollController _scrollController = ScrollController();
  TabController _tabController;
  String path = "/home";
  String storedUdid;
  String freshUdid;
  String initialAmount;
  bool online = globals.online;
  bool syncing = globals.syncing;
  bool isOffline = false;
  bool _executeFuture = false;
  bool _popDialog = false;
  int transactionLenght;
  int balancesLenght;
  int page = 1;

  void initState()  {
    super.initState();
    // Subscribe to Notifier Stream from ConnectionStatusSingleton class in globals.dart
    // Fires whenever connectivity state changes
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    connectionStatus.connectionChange.listen(connectionChanged);

    ReceiveComponentState comp = ReceiveComponentState();

    comp.getAccounts();
    // Generate unique device ID
    _checkUdid();
    // For Firebase dynamic link/deep link
    initDynamicLinks();
    // For Firebase push notification
    setupPushNotification();
    // For TabController
    _tabController = TabController(vsync: this, length: 2);
    // For ScrollController
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData(page);
        page += 1;
      }
    });
  }

  void setupPushNotification() async {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showSimpleNotification(
          Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.notifications_active, color: Colors.red,),
                      SizedBox(width: 10.0,),
                      Text(
                        message['notification']['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ]
                  ),
                  SizedBox(height: 8.0,),
                  Text(
                    message['notification']['body'],
                    style: TextStyle(color: Colors.black,),
                  ),
                ],
              ),
            ),
          ),
          background: Colors.white,
          autoDismiss: false,
          slideDismiss: true,
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        //showPushNotificationDialog(context, message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        //showPushNotificationDialog(context, message);
      },
    );
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
        // Get the value of transferAccount and assign to variable _accountId
        var _accountId = deepLink.path.split("/")[3];
        print(_accountId);
        var _amount = deepLink.path.split("/")[4];
        print(_amount);
        // Store the value in shared preferences
        // This will be used in sendLink page as destinationAccountId
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('transferAccountId', _accountId);
        await prefs.setString('transferAmount', _amount);

        Application.router.navigateTo(context, "/sendlink");
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        // Get the value of transferAccount and assign to variable _accountId
        var _transferAccountId = deepLink.path.split("/")[3];
        print(_transferAccountId);
        var _amount = deepLink.path.split("/")[4];
        print(_amount);
        var _merchantOrderId = deepLink.path.split("/")[5];
        print(_merchantOrderId);
        // Store the value in shared preferences
        // This will be used in sendLink page as destinationAccountId
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('transferAccountId', _transferAccountId);
        await prefs.setString('transferAmount', _amount);
        await prefs.setString('merchantOrderId', _merchantOrderId);

        Application.router.navigateTo(context, "/sendlink");
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
      // Check if balance in Accounts tab is empty
      if (balancesLenght == null) {
        getOnlineBalances();
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

  _getMoreData(page) {
    getOnlineTransactions(page += 1);
  }

  // String _formatMode(String mode) {
  //   String formattedMode;
  //   if (mode == 'receive') {
  //     formattedMode = 'Received';
  //   }
  //   if (mode == 'send') {
  //     formattedMode = 'Sent';
  //   }
  //   return formattedMode;
  // }

  // _showProof(List<Transaction> transaction, BuildContext context, int index) async {
  //   Dialog transacDialog = Dialog(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  //     child: Container(
  //       height: 500.0,
  //       width: 400.0,

  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           QrImage(
  //             data: transaction[transaction.length - index -1].paymentProof,
  //             size: 250.0
  //           ),

  //           Padding(
  //             padding:  EdgeInsets.all(10.0),
  //             child: Text("${formatCurrency.format(
  //             transaction[transaction.length - index - 1]
  //                 .amount)}", style: TextStyle(fontSize: 20.0),
  //             ),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.all(5.0),
  //             child: Text("${transaction[transaction.length - index -
  //                 1].time}", style: TextStyle(fontSize: 20.0),
  //             ),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.all(5.0),
  //             child: Text("ID: ${transaction[transaction.length -
  //                 index - 1].txnID}", style: TextStyle(fontSize: 20.0),
  //             ),
  //           ),
  //           Padding(padding: EdgeInsets.only(top: 20.0)),
  //           FlatButton(onPressed: (){
  //             Navigator.of(context).pop();
  //           },
  //               child: Text('Back', style: TextStyle(color: Colors.red, fontSize: 18.0),))
  //         ],
  //       ),
  //     ),
  //   );

  //   if(transaction[transaction.length - index - 1].mode == "send") {
  //     showDialog(context: context, builder: (BuildContext context) => transacDialog);
  //   }
  // }

  // Icon _getModeIcon(String mode) {
  //   Icon icon;
  //   if (mode == 'receive') {
  //     icon = Icon(
  //       Icons.add,
  //       size: 30.0,
  //       color: Colors.green,
  //     );
  //   }
  //   if (mode == 'send') {
  //     icon = Icon(
  //       Icons.remove,
  //       size: 30.0,
  //       color: Colors.red,
  //     );
  //   }
  //   return icon;
  // }

  @override
  void dispose() {
   // _connectivitySubscription.cancel();
    super.dispose();
    _tabController.dispose();
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
                child: globals.online ? Icon(Icons.wifi): Icon(Icons.signal_wifi_off),
              )
            )
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "Accounts",),
              Tab(text: "Transactions",),
            ]
          ),
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body:  TabBarView(
          controller: _tabController,
          children: [
            // accountsTab,
            Builder(builder: (BuildContext context) {
              return Container(
                alignment: Alignment.center,
                child: FutureBuilder(
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
                              balancesLenght = snapshot.data.balances.length;
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
                          return Container();
                        }
                      case ConnectionState.none:
                        {
                          break;
                        }
                    }
                    return null;
                  }
                )
              );
            }),
            // transactionsTab
            Builder(builder: (BuildContext context) {
              page = 1;
              return Container(
                alignment: Alignment.center,
                child: FutureBuilder(
                  future: globals.online ? getOnlineTransactions(page) : getOffLineTransactions(),
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
                              return Text('No transactions to display');  
                            }
                          } else {
                            return Text('No transactions to display');
                          }
                          return Container();
                        }
                      case ConnectionState.none:
                        {
                          break;
                        }
                    }
                    return null;
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