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
  bool online = globals.online;


  @override
  void initState() {
    super.initState();
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
                  onTap: (){
                    setState(() {
                      online = !online;  
                      globals.online = online;
                      globals.triggerInternet(online);
                    });
                    
                  }
                ) 
              )
            ]
            ,
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
