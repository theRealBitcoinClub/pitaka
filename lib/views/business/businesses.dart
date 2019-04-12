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
      'type': 'corporation',
      'tin': '920-029-093-000',
      'linkedaccount': 'None'
    },
    {
      'title': 'Business 2',
      'address': 'address 2',
      'type': 'corporation',
      'tin': '920-029-093-000',
      'linkedaccount': 'None'
    },
    {
      'title': 'Business 3',
      'address': 'address 3',
      'type': 'corporation',
      'tin': '920-029-093-000',
      'linkedaccount': 'None'
    }
  ];

  Widget buildBody(BuildContext context, int index) {

    return Card(
      color: Colors.white,
      elevation: 2.0,
      child:
          ExpansionTile(
            leading: const Icon(Icons.business),
            title: Text(
              "${tools[index]['title']}",
              textAlign: TextAlign.center
            ),
            children: <Widget>[
              ListTile(
                leading: Padding(
                  padding: EdgeInsets.only(top:4.0),
                  child:Text(
                  "Address : ",
                  )
                ),
                title: Text(
                  "${tools[index]['address']}",
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
              ListTile(
                leading: Padding(
                  padding: EdgeInsets.only(top:4.0),
                  child:Text(
                  "Type : ",
                  )
                ),
                title: Text(
                  "${tools[index]['type']}",
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
              ListTile(
                leading: Padding(
                  padding: EdgeInsets.only(top:4.0),
                  child:Text(
                  "TIN : ",
                  )
                ),
                title: Text(
                  "${tools[index]['tin']}",
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
              ListTile(
                leading: Padding(
                  padding: EdgeInsets.only(top:4.0),
                  child:Text(
                  "Linked Account : ",
                  )
                ),
                title: Text(
                  "${tools[index]['linkedaccount']}",
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
            // onTap: (){
            //   // Application.router.navigateTo(context, "${tools[index]['path']}");
            // },
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
