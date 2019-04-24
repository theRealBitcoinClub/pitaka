import 'package:flutter/material.dart';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import '../components/homeTabs.dart';
import 'globals.dart' as globals;


class HomeComponent extends StatefulWidget {
  @override
  State createState() => new HomeComponentState();
}

class HomeComponentState extends State<HomeComponent> {
  String path = "/home";
  bool online = true;  
  
  @override
  void initState() {
    super.initState();
    globals.checker(HomeComponentState);
  }

  @override
  build(BuildContext context) {
    return DefaultTabController (
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Paytaca'),
            actions: globals.netWorkIndentifier,
            bottom: TabBar(tabs: [
              Tab(
                text: "Accounts",
              ),
              Tab(text: "Transactions"),
            ]),
            centerTitle: true,
          ),
          drawer: buildDrawer(context),
          body: TabBarView(
            children: [
              accountsTab,
              transactionsTab,
            ],
          ),
          bottomNavigationBar: buildBottomNavigation(context, path),
        ));
  }

  
}
