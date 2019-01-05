import 'package:flutter/material.dart';
import '../components/drawer.dart';

class AccountComponent extends StatefulWidget {
  @override
  AccountComponentState createState() => new AccountComponentState();
}

class AccountComponentState extends State<AccountComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create Account'),
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body: Center(child: Text("Account")));
  }
}
