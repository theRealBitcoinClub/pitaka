import 'package:flutter/material.dart';
import '../../components/drawer.dart';
import '../../views/app.dart';
import '../../api/endpoints.dart';


class BusinessToolsComponent extends StatefulWidget {
  @override
  BusinessToolsComponentState createState() => new BusinessToolsComponentState();
}

class BusinessToolsComponentState extends State<BusinessToolsComponent> {
  bool _loading = true;

  Future<String> getReferences() async {
    await getBusinesReferences();
    setState(() {
      _loading = false;
    });
    return 'Success';
  }

  @override
  void initState() {
    super.initState();
    this.getReferences();
  }

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

  Widget bodyFunc() {
    if (_loading == true) {
      return new Center(child: CircularProgressIndicator());
    } else {
      return new ListView.builder
      (
        itemCount: tools.length,
        itemBuilder: (BuildContext ctxt, int index) => buildBody(ctxt, index)
      );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Business Tools'),
          centerTitle: true,
        ),
        drawer: buildDrawer(context),
        body: bodyFunc(),
      );
  }
}
