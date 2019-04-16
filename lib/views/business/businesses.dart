// SetBusinessAccountComponent

import 'package:flutter/material.dart';
import '../../api/endpoints.dart';
// import '../../views/app.dart';
import 'package:flutter_keychain/flutter_keychain.dart';

class FormAccount {
  String paytacaAccount;
  String businessAccount;
}

class BusinessesComponent extends StatefulWidget {
  @override
  BusinessesComponentState createState() => new BusinessesComponentState();
}

class BusinessesComponentState extends State<BusinessesComponent> {
  List businesses = List();
  bool hasData = false;

  Future<String> getList() async {
    var data = await getBusinessList();
    setState(() {
      businesses = data;
      hasData = true;
    });
    print(data);
    return 'Success';
  }

  @override
  void initState() {
    super.initState();
    this.getList();
  }

  Widget buildBody(BuildContext context, int index) {

    return Card(
      color: Colors.white,
      elevation: 2.0,
      child:
          ExpansionTile(
            leading: const Icon(Icons.business),
            title: Text(
              "${businesses[index]['title']}",
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
                  "${businesses[index]['address']}",
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
                  "${businesses[index]['type']}",
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
                  "${businesses[index]['tin']}",
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
                  "${businesses[index]['linkedaccount']}",
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
        body: Container(
          child: 
            new ListView.builder
              (
                itemCount: businesses.length,
                itemBuilder: (BuildContext ctxt, int index) =>
                    buildBody(ctxt, index)
              )
        ),
      );
  }
}
