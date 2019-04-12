// SetBusinessAccountComponent

import 'package:flutter/material.dart';
import '../../api/endpoints.dart';
import '../../views/app.dart';

class FormAccount {
  String paytacaAccount;
  String businessAccount;
}

class BusinessesComponent extends StatefulWidget {
  @override
  BusinessesComponentState createState() => new BusinessesComponentState();
}

class BusinessesComponentState extends State<BusinessesComponent> {
  List<Map<String, dynamic>> tools = [
    {
      'title': 'Business 1',
      'address': 'address 1',
    },
    {
      'title': 'Business 2',
      'address': 'address 2',
    },
    {
      'title': 'Business 3',
      'address': 'address 3',
    }
  ];

  Widget buildBody(BuildContext context, int index) {

    return Card(
      color: Colors.white,
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: (
          ListTile(
            leading: const Icon(Icons.business),
            title: Text("${tools[index]['title']}"),
            subtitle: Text("${tools[index]['address']}"),
            onTap: (){
              // Application.router.navigateTo(context, "${tools[index]['path']}");
            },
          )
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Businesses'),
          centerTitle: true,
        ),
        body: new ListView.builder
          (
            itemCount: tools.length,
            itemBuilder: (BuildContext ctxt, int index) => buildBody(ctxt, index)
          ),
      );
  }
}
