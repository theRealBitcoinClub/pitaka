import 'package:flutter/material.dart';
import '../../components/drawer.dart';
import '../../views/app.dart';


class BusinessToolsComponent extends StatefulWidget {
  @override
  BusinessToolsComponentState createState() => new BusinessToolsComponentState();
}

class BusinessToolsComponentState extends State<BusinessToolsComponent> {

  List<Map<String, dynamic>> tools = [
    {
      'title': 'Businesses',
      'subtitle': 'List of businesses',
      'path': '/businesses'
    },
    {
      'title': 'Register Business',
      'subtitle': 'Apply for business registration',
      'path': '/registerbusiness'
    },
    {
      'title': 'Set Business Account',
      'subtitle': 'Link a registered business to an account',
      'path': '/setbusinessaccount'
    }
  ];

  Widget buildBody(BuildContext context, int index) {
    return Card(
      color: Colors.white,
      elevation: 2.0,
      child: ListTile(
        title: Text("${tools[index]['title']}"),
        subtitle: Text("${tools[index]['subtitle']}"),
        onTap: (){
          Application.router.navigateTo(context, "${tools[index]['path']}");
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Business Tools'),
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body: new ListView.builder
          (
            itemCount: tools.length,
            itemBuilder: (BuildContext ctxt, int index) => buildBody(ctxt, index)
          ),
      );
  }
}
