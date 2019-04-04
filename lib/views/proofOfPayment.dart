import 'package:flutter/material.dart';
import '../views/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';


class ProofOfPaymentComponent extends StatefulWidget {
  @override
  ProofOfPaymentComponentState createState() => new ProofOfPaymentComponentState();
}

class ProofOfPaymentComponentState extends State<ProofOfPaymentComponent> {

  Future<String> getVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("_txnQrCode");
  }


  List<Widget> _buildAccountForm(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
      MediaQuery.of(context).viewInsets.bottom;
    Form form = new Form(
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new SizedBox(
            height: 30.0,
          ),
          FutureBuilder(
            future: getVal(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasData) {
                return QrImage(
                  data: snapshot.data,
                  size: 0.6 * bodyHeight,
                );
              }
            }),
          new RaisedButton(
            onPressed: () {
              Application.router.navigateTo(context, '/home');
              },
            child: new Text('Continue'),
          )
        ],
      )
    );
    var ws = new List<Widget>();
    ws.add(form);

    return ws;
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        appBar: AppBar(
          title: Text('Proof Of Payment'),
          centerTitle: true,
          automaticallyImplyLeading: false
        ),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildAccountForm(context));
        })
      );
  }
}
