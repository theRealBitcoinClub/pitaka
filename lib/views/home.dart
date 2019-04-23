import 'package:flutter/material.dart';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import '../components/homeTabs.dart';
// import 'package:pitaka/models/balance.dart';
// import 'package:pitaka/utils/database_helper.dart';


class HomeComponent extends StatefulWidget {
  @override
  State createState() => new HomeComponentState();
}

class HomeComponentState extends State<HomeComponent> {
  String path = "/home";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Paytaca'),
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
