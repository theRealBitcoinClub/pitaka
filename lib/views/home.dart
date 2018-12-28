import 'package:flutter/material.dart';
import '../components/drawer.dart';
import '../components/bottomNavigation.dart';
import '../components/homeTabs.dart';

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
        child: Scaffold(
          appBar: AppBar(
            title: Text('Paytaca'),
            bottom: TabBar(tabs: [
              Tab(
                text: "Balance",
              ),
              Tab(text: "Transactions"),
            ]),
            centerTitle: true,
          ),
          drawer: buildDrawer(context),
          body: TabBarView(
            children: [
              balanceTab,
              transactionsTab,
            ],
          ),
          bottomNavigationBar: buildBottomNavigation(context, path),
        ));
  }
}
