import 'package:flutter/material.dart';
import '../components/drawer.dart';

class BusinessRegistrationComponent extends StatefulWidget {
  @override
  BusinessRegistrationComponentState createState() => new BusinessRegistrationComponentState();
}

class BusinessRegistrationComponentState extends State<BusinessRegistrationComponent> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Business Registration'),
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        );
  }
}
