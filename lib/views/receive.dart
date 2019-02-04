import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:swipedetector/swipedetector.dart';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import '../api/responses.dart';

class ReceiveComponent extends StatefulWidget {
  @override
  ReceiveComponentState createState() => new ReceiveComponentState();
}

class ReceiveComponentState extends State<ReceiveComponent> {
  String path = "/receive";

  int accountIndex = 0;

  Future<List<Account>> getAccountsFromKeychain() async {
    String accounts = await FlutterKeychain.get(key: "accounts");
    List<Account> _accounts = [];
    for (final acct in accounts.split(',')) {
      var acctObj = new Account();
      acctObj.accountName = acct.split('|')[0];
      acctObj.accountId = acct.split('|')[1];
      _accounts.add(acctObj);
    }
    return _accounts;
  }

  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
        appBar: AppBar(
          title: Text('Receive'),
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body: new FutureBuilder(
            future: getAccountsFromKeychain(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return SwipeDetector(
                    onSwipeLeft: () {
                      setState(() {
                        if (accountIndex < (snapshot.data.length - 1)) {
                          accountIndex += 1;
                        }
                      });
                    },
                    onSwipeRight: () {
                      setState(() {
                        if (accountIndex > 0) {
                          accountIndex -= 1;
                        }
                      });
                    },
                    swipeConfiguration: SwipeConfiguration(
                        horizontalSwipeMaxHeightThreshold: 50.0,
                        horizontalSwipeMinDisplacement: 50.0,
                        horizontalSwipeMinVelocity: 200.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            snapshot.data[accountIndex].accountName,
                            style: new TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          QrImage(
                            data: snapshot.data[accountIndex].accountId,
                            size: 0.6 * bodyHeight,
                          )
                        ]));
              } else {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[new CircularProgressIndicator()]);
              }
            }),
        bottomNavigationBar: buildBottomNavigation(context, path));
  }
}
